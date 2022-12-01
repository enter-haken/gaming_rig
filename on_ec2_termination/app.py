from chalice.app import Chalice
from chalice.app import CloudWatchEvent

import boto3
import botocore
import logging
import json
import os

app = Chalice(app_name='ec2_listener')
APP_TAG = os.environ['APP_TAG']
RIG_AMI_NAME = os.environ['RIG_AMI_NAME']
RIG_AMI_ROOT_EBS_SIZE = os.environ['RIG_AMI_ROOT_EBS_SIZE']

app.log.setLevel(logging.DEBUG)

@app.on_cw_event({"source": ["aws.ec2"], "detail": {"state": ["terminated"]}})
def on_ec2_termination(event: CloudWatchEvent):
    app.log.info(event.to_dict())

    client = boto3.client('ec2')
    ec2 = boto3.resource("ec2")

    raw_volumes = client.describe_volumes(Filters=[{"Name": "tag:App", "Values" : [APP_TAG]}])
    app.log.info(str(raw_volumes))

    root_volume_id = max([x for x in raw_volumes["Volumes"]
        if x["State"] in ["available"]],key=lambda x: x["CreateTime"])['VolumeId']
    app.log.debug(f'Found {len(raw_volumes)} available volumes.')


    snapshot = client.create_snapshot(VolumeId=root_volume_id, Description='lambda snapshot', TagSpecifications=[
        {
            'ResourceType': 'snapshot',
            'Tags': [
                {
                    'Key': 'App',
                    'Value': APP_TAG
                    }
                ]
            }])
    app.log.info(f'create snapshot started. {str(snapshot)}')

@app.on_cw_event({"source": ["aws.ec2"], "detail": {"event": ["createSnapshot"], "result": ["succeeded"]}})
def on_ec2_snapshot_succeeded(event: CloudWatchEvent):
    client = boto3.client('ec2')

    snapshot_id = event.detail['snapshot_id'].split(":")[-1].split("/")[-1]
    volume_id = event.detail['source'].split(":")[-1].split("/")[-1]

    app.log.info(f'A snapshot {snapshot_id} has been created for volume {volume_id}')

    for ami in [x for x in client.describe_images(Owners=['self'])['Images'] if x['Name'] == RIG_AMI_NAME]:
        app.log.info(f'Deleting image {ami["ImageId"]}.')
        client.deregister_image(DryRun=False, ImageId=ami['ImageId'])

    old_snapshots_which_can_be_deleted = [x for x in client.describe_snapshots(OwnerIds=['self'])["Snapshots"]
            if x["State"] in ["completed"] 
            and APP_TAG in [y["Value"] for y in x["Tags"]] 
            and x["SnapshotId"] != snapshot_id]

    for old_snapshot_id in [x["SnapshotId"] for x in old_snapshots_which_can_be_deleted]:
        try:
            client.delete_snapshot(SnapshotId=old_snapshot_id)
            app.log.info(f'Snapshot {old_snapshot_id} has been deleted.')
        except Exception as err:
            app.log.warn(f'Can not delete snapshot {old_snapshot_id}.'
                    f'{err=}'
                    f'Skiping snapshot deletion for {old_snapshot_id}.')
            continue


    old_volumes_which_can_be_deleted = [x for x in client.describe_volumes(Filters=[{"Name": "tag:App", "Values" : [APP_TAG]}])["Volumes"] if x["State"] == "available"]

    for old_volume_id in [x['VolumeId'] for x in old_volumes_which_can_be_deleted]:
        client.delete_volume(VolumeId=old_volume_id)
        app.log.info(f'Old volume {old_volume_id} has been deleted')

    
    ami = client.register_image(
            Name=RIG_AMI_NAME,
            Description=f'{RIG_AMI_NAME} created by on_ec2_terminate lambda',
            BlockDeviceMappings=[
                {
                    'DeviceName': '/dev/sda1',
                    'Ebs': {
                        'DeleteOnTermination': False,
                        'SnapshotId': snapshot_id,
                        'VolumeSize': int(RIG_AMI_ROOT_EBS_SIZE),
                        'VolumeType': 'gp3'
                        }
                    }
                ],
            Architecture='x86_64',
            RootDeviceName='/dev/sda1',
            DryRun=False,
            VirtualizationType='hvm',
            EnaSupport=True)

    app.log.info(f'Created image {ami["ImageId"]}.')
