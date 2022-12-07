#!/usr/bin/env bash

# After an instance is terminated, a snapshot and an ami is beeing created.
# If you want to reset the gaming rig, you can use this script 
# to delete all resources, not beeing covered by terraform

ami_id_to_delete=$(aws ec2 describe-images --owners self --query "Images[] | [? starts_with(Description, 'gaming-rig')].ImageId" | jq -r ".[0]")
snapshot_id_to_delete=$(aws ec2 describe-snapshots --filters "Name=tag:App,Values=gaming-rig" --query "Snapshots[].SnapshotId" | jq -r ".[0]")
volume_id_to_delete=$(aws ec2 describe-volumes --filters "Name=tag:App,Values=gaming-rig" --query "Volumes[].VolumeId" | jq -r ".[0]")

echo "Deleting"
echo "Ami: $ami_id_to_delete"
echo "Snapshot: $snapshot_id_to_delete"
echo "Volume: $volume_id_to_delete"

aws ec2 deregister-image --image-id $ami_id_to_delete
aws ec2 delete-snapshot  --snapshot-id $snapshot_id_to_delete
aws ec2 delete-volume --volume-id $volume_id_to_delete
