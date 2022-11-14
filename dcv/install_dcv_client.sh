#!/usr/bin/env bash

set -e

check_linux_version() {
  if [ -z "$(uname -a | grep 20.04)" ]; then
    echo ""
    echo "You are not running Ubuntu 20.04."
    echo ""
    echo "This script downloads the dcv client for Ubuntu 20.04."
    echo "Check out the client list on"
    echo ""
    echo "https://download.nice-dcv.com/"
    echo ""
    echo "Installation aborted."
    exit -1;
  fi
}

download_dcv_client() {
  # Ubuntu 20.04 (x86_64)
  wget https://d1uj6qtbmh3dt5.cloudfront.net/2022.1/Clients/nice-dcv-viewer_2022.1.4251-1_amd64.ubuntu2004.deb
}

install_dcv_client() {
  sudo dpkg -i nice-dcv-viewer_2022.1.4251-1_amd64.ubuntu2004.deb
}

cleanup() {
  rm nice-dcv-viewer_2022.1.4251-1_amd64.ubuntu2004.deb
}

success() {
  echo ""
  echo "The Nice DCV client has been installed."
  echo "You can start the client with"
  echo ""
  echo $(command -v dcvviewer)
  echo ""
}

check_linux_version
download_dcv_client
install_dcv_client
cleanup
success
