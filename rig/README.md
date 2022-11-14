<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |
| <a name="provider_external"></a> [external](#provider\_external) | n/a |
| <a name="provider_local"></a> [local](#provider\_local) | n/a |
| <a name="provider_tls"></a> [tls](#provider\_tls) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_iam_instance_profile.windows_instance_profile](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_role.windows_instance_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.nvidia_driver_get_object_policy_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_key_pair.key_pair](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/key_pair) | resource |
| [aws_security_group.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_spot_instance_request.rig_instance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/spot_instance_request) | resource |
| [local_file.ssh_key](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [tls_private_key.key_pair](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |
| [aws_ami.aws_windows_ami](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_ami_ids.list_of_own_amis](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami_ids) | data source |
| [aws_ec2_instance_type_offerings.offerings](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ec2_instance_type_offerings) | data source |
| [aws_ec2_spot_price.spot_prices](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ec2_spot_price) | data source |
| [aws_iam_policy.nvidia_driver_get_object_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy) | data source |
| [external_external.all_necessary_commands_are_available](https://registry.terraform.io/providers/hashicorp/external/latest/docs/data-sources/external) | data source |
| [external_external.your_location](https://registry.terraform.io/providers/hashicorp/external/latest/docs/data-sources/external) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_availability_zone"></a> [availability\_zone](#input\_availability\_zone) | number in array of possible availability\_zones | `number` | `0` | no |
| <a name="input_force_reinstallation"></a> [force\_reinstallation](#input\_force\_reinstallation) | An existing snapshot is ignored.<br><br>This forces a reinstallation of the whole system.<br><br>All data will be lost. | `bool` | `false` | no |
| <a name="input_increase_bet_by"></a> [increase\_bet\_by](#input\_increase\_bet\_by) | increase the current bet by x (eg.: 0.2) | `number` | `0` | no |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | prefered instance type for the gaming rig | `string` | `"g5.xlarge"` | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | prefixing resources | `string` | `"rig"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_availability_zone"></a> [availability\_zone](#output\_availability\_zone) | Used availability zone for the instance |
| <a name="output_city"></a> [city](#output\_city) | n/a |
| <a name="output_instance_id"></a> [instance\_id](#output\_instance\_id) | The id for the gaming rig ec2 instance |
| <a name="output_instance_ip"></a> [instance\_ip](#output\_instance\_ip) | The external ip address for the gaming rig instance |
| <a name="output_instance_public_dns"></a> [instance\_public\_dns](#output\_instance\_public\_dns) | The dns entry for the gaming rig instance |
| <a name="output_instance_type"></a> [instance\_type](#output\_instance\_type) | Requested instance type |
| <a name="output_local_ip"></a> [local\_ip](#output\_local\_ip) | You current external ip address. |
| <a name="output_request_price"></a> [request\_price](#output\_request\_price) | Requested price configured for the spot instance request |
| <a name="output_spot_price"></a> [spot\_price](#output\_spot\_price) | Current spot price for the configured availability zone |
<!-- END_TF_DOCS -->