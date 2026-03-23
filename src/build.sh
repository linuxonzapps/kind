#!/bin/bash
set -e -o pipefail
read -ra arr <<< "$@"
version=${arr[1]}
trap 0 1 2 ERR
# Extract DISTRO details for tagging
if [ -f /etc/os-release ]; then
    . /etc/os-release
    DISTRO="$ID-$VERSION_ID"
    if [ "$VERSION_CODENAME" != "" ]; then
        DISTRO="$ID-$VERSION_CODENAME"
    fi
fi
current_dir="$PWD"
echo $DISTRO > .distro_zab.txt
# Ensure sudo is installed
apt-get update && apt-get install sudo jq -y
bash /tmp/linux-on-ibm-z-scripts/Kind/${version}/build_kind.sh -y
tar cvfz kind-${version}-linux-s390x.tar.gz kind/bin/kind
# Create container image - script above will have already created the image
docker save -o kind-${version}-linux-s390x.container.tar kindest/base
exit 0
