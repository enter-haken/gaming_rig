module "snapshot_lambda" {
  source                = "./on_ec2_termination/build"
  app_tag               = var.app_tag
  rig_ami_name          = var.rig_ami_name
  rig_ami_root_ebs_size = var.rig_ami_root_ebs_size
}

resource "tls_private_key" "key_pair" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "key_pair" {
  key_name   = "${var.prefix}-windows-key-pair"
  public_key = tls_private_key.key_pair.public_key_openssh
}

resource "local_file" "ssh_key" {
  filename = "${aws_key_pair.key_pair.key_name}.pem"
  content  = tls_private_key.key_pair.private_key_pem
}

resource "aws_security_group" "default" {
  name        = "${var.prefix}-sg"
  description = "Rules for ${var.prefix}"

  ingress {
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["${data.external.your_location.result.ip}/32"]
    description = "Allow rdp connection from one client"
  }

  ingress {
    from_port   = 8443
    to_port     = 8443
    protocol    = "udp"
    cidr_blocks = ["${data.external.your_location.result.ip}/32"]
    description = "NICE DCV QUIC (IPv4)"
  }

  ingress {
    from_port   = 8443
    to_port     = 8443
    protocol    = "tcp"
    cidr_blocks = ["${data.external.your_location.result.ip}/32"]
    description = "NICE DCV (IPv4)"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all traffic"
  }
}

resource "aws_iam_role" "windows_instance_role" {
  name = "${var.prefix}-instance-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "nvidia_driver_get_object_policy_attachment" {
  role       = aws_iam_role.windows_instance_role.name
  policy_arn = data.aws_iam_policy.nvidia_driver_get_object_policy.arn
}

resource "aws_iam_instance_profile" "windows_instance_profile" {
  name = "${var.prefix}-instance-profile"
  role = aws_iam_role.windows_instance_role.name
}

resource "aws_spot_instance_request" "rig_instance" {
  count                = var.use_spot_instance ? 1 : 0
  ami                  = var.use_own_ami ? data.aws_ami.rig_ami[0].image_id : data.aws_ami.aws_windows_ami[0].image_id
  spot_price           = local.request_price
  instance_type        = var.instance_type
  availability_zone    = local.availability_zone
  key_name             = aws_key_pair.key_pair.key_name
  security_groups      = [aws_security_group.default.name]
  wait_for_fulfillment = true
  get_password_data    = !var.use_own_ami
  user_data = var.use_own_ami ? null : templatefile("${path.module}/provisioning.tpl", {
    password_ssm_parameter = aws_ssm_parameter.password_ssm_parameter.name
  })
  spot_type                            = "one-time"
  iam_instance_profile                 = aws_iam_instance_profile.windows_instance_profile.id
  valid_until                          = timeadd(timestamp(), var.bet_valid_until)
  instance_initiated_shutdown_behavior = "terminate"

  root_block_device {
    delete_on_termination = false
    volume_size           = var.rig_ami_root_ebs_size
    volume_type           = "gp3"
    tags = {
      App = var.app_tag
    }
  }
}

resource "aws_instance" "rig_instance" {
  count             = var.use_spot_instance ? 0 : 1
  ami               = var.use_own_ami ? data.aws_ami.rig_ami[0].image_id : data.aws_ami.aws_windows_ami[0].image_id
  instance_type     = var.instance_type
  availability_zone = local.availability_zone
  key_name          = aws_key_pair.key_pair.key_name
  security_groups   = [aws_security_group.default.name]
  get_password_data = !var.use_own_ami
  user_data = var.use_own_ami ? null : templatefile("${path.module}/provisioning.tpl", {
    password_ssm_parameter = aws_ssm_parameter.password_ssm_parameter.name
  })
  iam_instance_profile                 = aws_iam_instance_profile.windows_instance_profile.id
  instance_initiated_shutdown_behavior = "terminate"

  root_block_device {
    delete_on_termination = false
    volume_size           = var.rig_ami_root_ebs_size
    volume_type           = "gp3"
    tags = {
      App = var.app_tag
    }
  }
}
