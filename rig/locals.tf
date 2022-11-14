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
  price = element(tolist([
    for k, v in data.aws_ec2_spot_price.spot_prices :
    {
      price             = v.spot_price,
      availability_zone = v.availability_zone
    }
  ]), var.availability_zone).price
  snapshot_exists = length(data.aws_ami_ids.list_of_own_amis.ids) > 0
}
