output "city" {
  value = data.external.your_location.result.city
}

output "local_ip" {
  description = "You current external ip address."
  value       = data.external.your_location.result.ip
}

output "price" {
  value = local.price
}

output "availability_zone" {
  value = local.availability_zone
}

output "instance_type" {
  value = var.instance_type
}

output "instance_id" {
  value = aws_spot_instance_request.rig_instance.spot_instance_id
}

output "instance_ip" {
  value = aws_spot_instance_request.rig_instance.public_ip
}

output "instance_public_dns" {
  value = aws_spot_instance_request.rig_instance.public_dns
}
