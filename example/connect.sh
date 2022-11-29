#!/usr/bin/env bash

# TODO: take a look at the dcv config file
echo "waiting for instance..."
#nc -z $(terraform output -json gaming-rig | jq -r '.instance_ip') 8443

dcvviewer config.dcv
