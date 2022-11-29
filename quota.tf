# 
# Checks the vCPU quota for requesting spot instances
#
data "aws_servicequotas_service_quota" "spot_instance_quota" {
  count        = var.use_spot_instance ? 1 : 0
  quota_name   = "All G and VT Spot Instance Requests"
  service_code = "ec2"
  lifecycle {
    postcondition {
      condition     = self.value > 3
      error_message = <<-EOT
      You need at least a quota for 4vCPUs to make a g5.xlarge spot instance request

      You can increase your current quota of ${self.value} vCPUs by requesting a increase:

      see

      https://docs.aws.amazon.com/general/latest/gr/aws_service_limits.html

      for more information.

      You can open the "Service Quota Console", choose "Amazon Elastic Compute Cloud (Amazon EC2)",
      and search for "All G and VT Spot Instance Requests".

      From here you can "Request quota increase".
      EOT
    }
  }
}

#
# Checks the vCPU quota for requesting ondemand ec2 instances
#
data "aws_servicequotas_service_quota" "on_demand_instance_quota" {
  count        = var.use_spot_instance ? 0 : 1
  quota_name   = "Running On-Demand G and VT instances"
  service_code = "ec2"
  lifecycle {
    postcondition {
      condition     = self.value > 3
      error_message = <<-EOT
      You need at least a quota for 4vCPUs to start a g5.xlarge instance. 

      You can increase your current quota of ${self.value} vCPUs by requesting a increase:

      see

      https://docs.aws.amazon.com/general/latest/gr/aws_service_limits.html

      for more information.

      You can open the "Service Quota Console", choose "Amazon Elastic Compute Cloud (Amazon EC2)",
      and search for "Running On-Demand G and VT instances".

      From here you can "Request quota increase".
      EOT
    }
  }
}

