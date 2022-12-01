#!/usr/bin/env bash

instance_ip=$(terraform output -json gaming-rig | jq -r '.instance_ip')
instance_id=$(terraform output -json gaming-rig | jq -r '.instance_id')

instance_password_response=$(aws ec2 get-password-data \
  --instance-id $instance_id \
  --priv-launch-key ./rig-windows-key-pair.pem)

echo $instance_password_response | jq -r '.PasswordData' > password.txt

chmod 400 password.txt
