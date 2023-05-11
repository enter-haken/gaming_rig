data "external" "all_necessary_commands_are_available" {
  program = ["${path.module}/scripts/all_necessary_commands_are_available.sh"]
  lifecycle {
    postcondition {
      condition     = self.result.jq && self.result.wget && self.result.curl && self.result.tar && self.result.awk
      error_message = <<-EOT
      Some of neccessary commands can not be found.

      You will need

      * aws
      * terraform
      * jq
      * wget
      * curl
      * tar
      * awk

      to proceed.

      Hint: `aws`, `terraform` and `jq` can be installed with `asdf install`.
      EOT
    }
  }
}

data "external" "your_location" {
  program = ["curl", "https://ipinfo.io"]
  lifecycle {
    postcondition {
      condition     = can(regex(local.ip_regex, self.result.ip))
      error_message = <<-EOT
      A call to **curl https://ipinfo.io** was not successful.

      The **IP address** is needed to set up the allowed IP address that is allowed for rdp.
      EOT
    }
  }
}

data "aws_iam_policy" "nvidia_driver_get_object_policy" {
  arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

#
# Check the availabilitiy for g5 instances within a region
#
data "aws_ec2_instance_type_offerings" "offerings" {
  filter {
    name   = "instance-type"
    values = [var.instance_type]
  }

  location_type = "availability-zone"

  lifecycle {
    postcondition {
      condition     = length(self.locations) > 0
      error_message = <<-EOT
      You need at least one availability_zone where the ${var.instance_type} instance is available.
      EOT
    }
  }
}

#
# Gets the spot prices for each availability zone, where g5 instances are available
#
data "aws_ec2_spot_price" "spot_prices" {
  for_each          = toset(data.aws_ec2_instance_type_offerings.offerings.locations)
  instance_type     = var.instance_type
  availability_zone = each.value

  filter {
    name   = "product-description"
    values = ["Windows"]
  }

  lifecycle {
    postcondition {
      condition     = length(keys(self)) > 0
      error_message = "There should be at least one price."
    }
  }
}

#data "aws_ebs_snapshot" "rig_snapshot" {
#  most_recent = true
#  owners      = ["self"]
#
#  filter {
#    name   = "tag:App"
#    values = [var.app_tag]
#  }
#  lifecycle {
#    postcondition {
#      # when you are provisioning the system, there is no snapshot in place
#      condition     = try(self.state == "completed", true)
#      error_message = <<-EOT
#      The current snapshot has not the state "completed"
#      EOT
#    }
#  }
#}

data "aws_ami" "aws_windows_ami" {
  count       = var.use_own_ami ? 0 : 1
  most_recent = true
  filter {
    name   = "name"
    values = ["Windows_Server-2022-English-Full-Base-2022.*"]
  }
}

data "aws_ami" "rig_ami" {
  count       = var.use_own_ami ? 1 : 0
  most_recent = true

  owners = ["self"]

  filter {
    name   = "name"
    values = [var.rig_ami_name]
  }
}
