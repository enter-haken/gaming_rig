# gaming rig

Cloud gaming provided by yourself.

With this terraform module, you can create a Windows instance with

* Nice DCV Server installed
* current NVIDIA Grid drivers
* and Steam

It uses **spot instances** in a **region next to you**.

When the instance is provisioned, you can start installing your games.

In best case

* spot instances are available
* instance price is high enough
* all necessary software is installed

you can **start with zero configuration**.

## before you start

you have to **create an AWS account** if none exists yet.

You need to install `awscli` and `terraform` to create the `gaming rig`.

### use asdf for the ease of use

You can use the tool version manager `asdf` for installing.

* awscli
* terraform
* terraform-docs
* jq

Install `asdf` according the [documentation][1]

For the **first time run** you need to add the needed **plugins** by

```
$ asdf plugin add awscli
$ asdf plugin add terraform
$ asdf plugin add terraform-docs
$ asdf plugin add jq
```

Then you can install the **needed plugins** by executing

```
$ asdf install
```

### other requirements

You also need

* wget
* curl
* tar
* awk

and the **DCV viewer** for accessing your instance

### install DCV viewer

In the `./example/dcv` folder you can find additional information about installing the viewer.

After the gameserver is provisioned, you can use the **DCV viewer** to connect to your gaming rig.

### instance credentials

You can get your **instance password** by calling

```
$ aws ec2 get-password-data \
  --instance-id <instance_id> \
  --priv-launch-key ./rig-windows-key-pair.pem
```

Login as `Administrator` and the provided password.

You can also use a [script][3], like it is used in the example folder.

## troubleshooting

When you getting errors during requesting a spot instance, you can
**increase your bet** by setting the `increase_bet_by` variable.

If no instance is available in your availability zone, you can
choose **an other availability_zone** by setting the `availability_zone` variable.
The availability zones are stored within an array.
The count of these vary from region to region.
The first zone found is taken as the default zone.

I had some **problems with the mouse** while playing.
There is a mouse setting available (Ctrl shift F8) to use the relative mouse position.

## possible instances

| Instance Size | GPU | GPU Memory (GiB) | vCPUs | Memory (GiB) | Storage (GB) | Network Bandwidth (Gbps) | EBS Bandwidth (Gbps) |
| ------------- | --- | ---------------- | ----- | ------------ | ------------ | ------------------------ | -------------------- |
| g5.xlarge     | 1   | 24               | 4     | 16           | 1x250        | Up to 10                 | Up to 3.5            |
| g5.2xlarge    | 1   | 24               | 8     | 32           | 1x450        | Up to 10                 | Up to 3.5            |
| g5.4xlarge    | 1   | 24               | 16    | 64           | 1x600        | Up to 25                 | 8                    |
| g5.8xlarge    | 1   | 24               | 32    | 128          | 1x900        | 25                       | 16                   |
| g5.16xlarge   | 1   | 24               | 64    | 256          | 1x1900       | 25                       | 16                   |

[Amazon EC2 G5 Instances][2]

## todo

### Snapshot

When you shutdown your server, all data is gone.
You could create a snapshot manually, but this can be automated.

[1]: https://asdf-vm.com/guide/getting-started.html#_5-install-a-version
[2]: https://aws.amazon.com/ec2/instance-types/g5/
[3]: example/create_nice_dcv_config_file.sh

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 4.39.0 |
| <a name="provider_external"></a> [external](#provider\_external) | 2.2.3 |
| <a name="provider_local"></a> [local](#provider\_local) | 2.2.3 |
| <a name="provider_tls"></a> [tls](#provider\_tls) | 4.0.4 |

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
