from chalice import Chalice
import boto3

app = Chalice(app_name='rig_snapshot')

@app.on_cw_event({"source": ["aws.ec2"], "detail": {"state": ["terminated"]}})
def on_ec2_terminate(event):
    ec2 = boto3.resource("ec2")
    client = boto3.client('ec2')
   
    # TODO: right tag?
    root_volume = client.describe_volumes(Filters=[{"Name": "tag:App", "Values" : ["lambda_test"]}])
    root_volume_id = root_volume['Volumes'][0]['VolumeId']
    app.log.info(f'found root_volume {root_volume_id}.')

    # TODO: check, if more than one snapshot is found
    # this indicates, that currently a snapshot is running

    res = ec2.create_snapshot(VolumeId=root_volume_id, Description='gaming rig snapshot')
    app.log.info('snapshot created.')

    # TODO: delete old snapshot

    res = client.delete_volume(VolumeId=root_volume_id)
    app.log.info(f'volume {root_volume_id} deleted.')
