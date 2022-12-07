#!/usr/bin/env bash

instance_ip=$(terraform output -json gaming-rig | jq -r '.instance_ip')
instance_password_initial=$(cat ./password.txt)
instance_password=$(aws ssm get-parameter --with-decryption --name rig-administrator-password | jq -r ".Parameter.Value")


cat <<EOT > config.dcv
# https://github.com/awsdocs/nice-dcv-user-guide/blob/master/doc_source/using-connection-file.md
[version]
format=1.0

[connect]
host=${instance_ip}
user=Administrator
#initial_password: ${instance_password_initial}
password=${instance_password}
certificatevalidationpolicy=accept-untrusted

[options]
fullscreen=false
useallmonitors=false
EOT

echo ""
echo "Dcv Viewer file has been created."
echo "When the server is up and provisioned, you can connect to your server by:"
echo ""
echo "dcvviewer config.dcv"
