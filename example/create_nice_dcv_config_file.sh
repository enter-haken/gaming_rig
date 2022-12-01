#!/usr/bin/env bash

instance_ip=$(terraform output -json gaming-rig | jq -r '.instance_ip')
instance_password=$(cat ./password.txt)

cat <<EOT > config.dcv
[version]
format=1.0

[connect]
host=${instance_ip}
user=Administrator
password=${instance_password}

[options]
fullscreen=false
useallmonitors=false
EOT

echo ""
echo "Dcv Viewer file has been created."
echo "When the server is up and provisioned, you can connect to your server by:"
echo ""
echo "dcvviewer config.dcv"
