output "city" {
  value = data.external.your_location.result.city
}

output "local_ip" {
  description = "You current external ip address."
  value       = data.external.your_location.result.ip
}

output "price" {
  value       = local.price
  description = "spot price for the configured availability zone"
}

output "availability_zone" {
  description = "used availability zone for the instance"
  value       = local.availability_zone
}

output "instance_type" {
  value       = var.instance_type
  description = "current spot instance price"
}

output "instance_id" {
  value       = aws_spot_instance_request.rig_instance.spot_instance_id
  description = "The id for the gaming rig ec2 instance"
}

output "instance_ip" {
  value       = aws_spot_instance_request.rig_instance.public_ip
  description = "The external ip address for the gaming rig instance"
}

output "instance_public_dns" {
  value       = aws_spot_instance_request.rig_instance.public_dns
  description = "The dns entry for the gaming rig instance"
}
