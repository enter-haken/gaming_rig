# gaming rig

Cloud gaming provided by yourself.

With this terraform project, you can create a Windows instance with

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
* jq

Install `asdf` according the [documentation][1]

For the **first time run** you need to add the needed **plugins** by

```
$ asdf plugin add awscli
$ asdf plugin add terraform
$ asdf plugin add jq
```

Then you can install the needed **plugins** by executing

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

In the `./dcv` folder you can find additional information about installing the viewer.

After the gameserver is provisioned, you can use the **DCV viewer** to connect to your gaming rig.

## start the rig

You can start the rig by

```
$ make up config
```

After about **2 minutes** the instance should be reachable via **rdp**.
About **10 minutes** later, the instance should be provisioned.

Now you can use the DCV client to connect.

A `./config.dcv` file is generated with all necessary information to
connect to the instance.

```
$ make connect
```

will connect you to the instance.

On the desktop you will find a `$home\Desktop\provisioning` folder that contains some log files about the deployment. 
You can simply delete this folder if you want.

## troubleshooting

When you getting errors during requesting a spot instance, you can
**increase your bet** by setting the `increase_bet_by` variable.

If no instance is available in your availability zone, you can
choose **an other availability_zone** by setting the `availability_zone` variable.
The availability zones are stored within an array.
The count of these vary from region to region.
The first zone found is taken as the default zone.

I have some **problems with the mouse** while playing.
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
