# Generates a secure private key and encodes it as PEM
# https://gmusumeci.medium.com/how-to-deploy-a-windows-server-ec2-instance-in-aws-using-terraform-dd86a5dbf731
# https://github.com/KopiCloud/terraform-aws-windows-ec2-instance

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

# TODO: get snapshot ami if exists
# TODO: create lambda for creating ami before termination
# - delete volume after snapshot -> reduce storage costs

resource "aws_spot_instance_request" "rig_instance" {
  ami                  = local.snapshot_exists ? "" : data.aws_ami.aws_windows_ami.image_id
  spot_price           = local.request_price
  instance_type        = var.instance_type
  availability_zone    = local.availability_zone
  key_name             = aws_key_pair.key_pair.key_name
  security_groups      = [aws_security_group.default.name]
  wait_for_fulfillment = true
  get_password_data    = true
  user_data = templatefile("${path.module}/provisioning.tpl", {

  })
  spot_type            = "one-time"
  iam_instance_profile = aws_iam_instance_profile.windows_instance_profile.id
  valid_until          = timeadd(timestamp(), "10m")

  root_block_device {
    volume_size = "256"
    volume_type = "gp3"
  }
  lifecycle {
    postcondition {
      condition     = self.password_data != ""
      error_message = "could not retrieve password"
    }

    postcondition {
      condition     = self.public_ip != ""
      error_message = "The running container needs a public ip"
    }
  }
}
