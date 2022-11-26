# TODO: take windows ami if no snapshot is found

locals {
  ip_regex = "^(?:[0-9]{1,3}\\.){3}[0-9]{1,3}$"
  availability_zone = element(tolist([
    for k, v in data.aws_ec2_spot_price.spot_prices :
    {
      price             = v.spot_price,
      availability_zone = v.availability_zone
    }
  ]), var.availability_zone).availability_zone
  spot_price = element(tolist([
    for k, v in data.aws_ec2_spot_price.spot_prices :
    {
      price             = v.spot_price,
      availability_zone = v.availability_zone
    }
  ]), var.availability_zone).price
  request_price   = tostring(tonumber(local.spot_price) + var.increase_bet_by)
  snapshot_exists = length(data.aws_ebs_snapshot_ids.rig_snapshots.ids) > 0
  #snapshot_id = element(data.aws_ebs_snapshot_ids.rig_snapshots.ids, 1)
  instance_id = var.use_spot_instance ? one(aws_spot_instance_request.rig_instance[*].spot_instance_id) : one(aws_instance.rig_instance[*].id)
  instance_ip = var.use_spot_instance ? one(aws_spot_instance_request.rig_instance[*].public_ip) : one(aws_instance.rig_instance[*].public_ip)
}
