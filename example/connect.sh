#!/usr/bin/env bash

echo "waiting for instance..."
timeout 300 sh -c 'until nc -z $0 $1; do sleep 10; done' $(terraform output -json gaming-rig | jq -r '.instance_ip') 8443

dcvviewer config.dcv
