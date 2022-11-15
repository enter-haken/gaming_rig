data "external" "all_necessary_commands_are_available" {
  program = ["${path.module}/scripts/all_necessary_commands_are_available.sh"]
  lifecycle {
    postcondition {
      condition     = self.result.jq && self.result.wget && self.result.curl && self.result.tar && self.result.awk && self.result.dcvviewer
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

# check, if g5.xlarge is available in a availability zone
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

# This is our base image for the installation.
# When there is no snapshot found, this image 
# will be taken.
data "aws_ami" "aws_windows_ami" {
  most_recent = true
  filter {
    name   = "name"
    values = ["Windows_Server-2022-English-Full-Base-2022.10.12"]
  }
}

# TODO: this call expects exactly one result
# When we start there is no snapshot.
# -> Find an other way to list custom amis / snapshots
data "aws_ami_ids" "list_of_own_amis" {
  owners = ["self"]
}
