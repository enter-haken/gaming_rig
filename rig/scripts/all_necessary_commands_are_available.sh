#!/usr/bin/env bash

function exists {
  if [ -z $(command -v $1) ]; then
    echo "false"
  else
    echo "true"
  fi
}

cat << JSON_OUTPUT_FOR_TERRAFORM
{
  "jq": "$(exists 'jq')",
  "wget": "$(exists 'wget')",
  "curl": "$(exists 'curl')",
  "tar": "$(exists 'tar')",
  "awk": "$(exists 'awk')",
  "dcvviewer": "$(exists 'dcvviewer')"
}
JSON_OUTPUT_FOR_TERRAFORM
