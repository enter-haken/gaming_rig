provider "aws" {
  region = data.external.nearest_region.result.region
  default_tags {
    tags = {
      App = "gaming-rig"
    }
  }
}

data "external" "nearest_region" {
  program = ["./nearest_aws_region.sh"]
  lifecycle {
    postcondition {
      condition     = self.result.region != ""
      error_message = <<-EOT
      Could not determine a vailid region.
      
      The script ./nearest_aws_region.sh tries to determine the closest region,
      by pinging all of them.
      
      A sample invocation can look like
      
      $ ./awsping -verbose 1 -repeats 3
            Code            Region                                      Latency
          0 eu-central-1    Europe (Frankfurt)                         22.00 ms
          1 eu-west-2       Europe (London)                            32.09 ms
          2 eu-west-1       Europe (Ireland)                           42.02 ms
          3 us-east-1       US-East (Virginia)                        107.47 ms
          4 us-east-2       US-East (Ohio)                            116.17 ms
          5 ap-south-1      Asia Pacific (Mumbai)                     137.07 ms
          6 us-west-1       US-West (California)                      169.77 ms
          7 ap-southeast-1  Asia Pacific (Singapore)                  187.05 ms
          8 us-west-2       US-West (Oregon)                          187.93 ms
          9 sa-east-1       South America (São Paulo)                 229.03 ms
         10 ap-northeast-2  Asia Pacific (Seoul)                      242.71 ms
         11 ap-northeast-1  Asia Pacific (Tokyo)                      271.38 ms
         12 ap-southeast-2  Asia Pacific (Sydney)                     287.72 ms
      
      Try to execute the script outsite of terraform to get more information.
      EOT
    }
  }
}

module "gaming_rig" {
  source = "./.."
  #
  # Increase the current bet by 0.1 says, that you would pay 10 cent more
  # than the current spot price.
  #
  # This reduces the chance of beeing terminated.
  #
  increase_bet_by = 0.1
  #
  # eu-central-1 has three availability zones:
  #
  # * eu-central-1a
  # * eu-central-1b
  # * eu-central-1c
  #
  # The g5 instances can be found in 1b and 1c
  #
  # so you can choose between
  #
  # * 0 -> eu-central-1b
  # * 1 -> eu-central-1c
  #
  availability_zone     = 1
  rig_ami_root_ebs_size = 512
  use_spot_instance     = false
  use_own_ami           = false
  app_tag               = "gaming-rig"
}

output "gaming-rig" {
  value     = module.gaming_rig
  sensitive = true
}
