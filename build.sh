#!/usr/bin/env bash

set -e

latest_version=$(python3 latest_kernel.py)

pushd "docker" || (echo "Unable to push directory" && exit 1)
docker build \
    -t "fedora-acs-kernel-builder:fc41" \
    --build-arg "uid=$(id -u)" \
    --build-arg "gid=$(id -g)" \
    -f Dockerfile.fc41 .
popd

mkdir -p output/RPMS
mkdir -p output/SRPMS
docker run --rm \
    --volume "$(pwd)/output/RPMS":/home/builder/rpmbuild/RPMS \
    --volume "$(pwd)/output/SRPMS":/home/builder/rpmbuild/SRPMS \
    fedora-acs-kernel-builder:fc41 \
    "${latest_version}"
