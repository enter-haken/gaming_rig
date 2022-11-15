#!/usr/bin/env bash

if [ ! -f "./awsping" ]; then
  wget -qO- https://github.com/ekalinin/awsping/releases/download/0.5.2/awsping.linux.amd64.tgz | tar xz
fi

region_with_minimal_latency=$(./awsping -verbose 1 -repeats 3 | head -n 2 | tail -n 1 | awk '{ print $2 }')

cat << JSON_OUTPUT_FOR_TERRAFORM
{
  "region": "${region_with_minimal_latency}"
}
JSON_OUTPUT_FOR_TERRAFORM
