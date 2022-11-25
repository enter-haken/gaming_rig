output "city" {
  value = data.external.your_location.result.city
}

output "local_ip" {
  description = "You current external ip address."
  value       = data.external.your_location.result.ip
}

output "spot_price" {
  value       = local.spot_price
  description = "Current spot price for the configured availability zone"
}

output "request_price" {
  value       = local.request_price
  description = "Requested price configured for the spot instance request"
}

output "availability_zone" {
  description = "Used availability zone for the instance"
  value       = local.availability_zone
}

output "instance_type" {
  value       = var.instance_type
  description = "Requested instance type"
}

# output "spot_instance_id" {
#   value       = var.use_spot_instance ?  aws_spot_instance_request.rig_instance.*.spot_instance_id : ""
#   description = "The id for the gaming rig ec2 instance"
# }
# 
# output "spot_instance_ip" {
#   value       = var.use_spot_instance ?  aws_spot_instance_request.rig_instance.*.public_ip : ""
#   description = "The external ip address for the gaming rig instance"
# }
# 
# output "instance_id" {
#   value       = var.use_spot_instance ? "" : aws_instance.rig_instance.*.host_id
#   description = "The id for the gaming rig ec2 instance"
# }
# 
# output "instance_ip" {
#   value       = var.use_spot_instance ? "" : aws_instance.rig_instance.*.public_ip
#   description = "The external ip address for the gaming rig instance"
# }

output "use_spot_instance" {
  value       = var.use_spot_instance
  description = "inicates, if a spot instance should be used for the gaming rig"
}

output "instance" {
  value = aws_instance.rig_instance
  description = "whole rig instance"
}

output "instance_id" {
  value       = var.use_spot_instance ? one(aws_spot_instance_request.rig_instance[*].spot_instance_id) : one(aws_instance.rig_instance[*].id)
  description = "The id for the gaming rig ec2 instance"
}

output "instance_ip" {
  value       = var.use_spot_instance ? one(aws_spot_instance_request.rig_instance[*].public_ip) : one(aws_instance.rig_instance[*].public_ip)
  description = "The external ip address for the gaming rig instance"
}



