#!/usr/bin/env bash

set -e

fedora_ver=41
num_cpu=$(grep -c processor /proc/cpuinfo)

while [[ "$#" -gt 0 ]]; do
    case $1 in
        --fedora-version=*) 
            fedora_ver="${1#*=}"
            if ! [[ "$fedora_ver" =~ ^[0-9]+$ ]]; then
                echo "Invalid fedora version, must be numeric"
                exit 1
            fi
            ;;
        --num-cpu=*)
            num_cpu="${1#*=}"
            if ! [[ "$num_cpu" =~ ^[0-9]+$ ]]; then
                echo "Invalid number of CPU, must be numeric"
                exit 1
            fi
    esac
    shift
done
latest_version=$(python3 latest_kernel.py "${fedora_ver}")

if [ -n "$(find output/RPMS -name "*${latest_version}*")" ]; then
    echo "Kernel ${latest_version} already built."
    exit 0
fi

pushd "docker" || (echo "Unable to push directory" && exit 1)
docker build \
    -t "fedora-acs-kernel-builder:fc${fedora_ver}" \
    --build-arg "fedora_ver=${fedora_ver}" \
    --build-arg "uid=$(id -u)" \
    --build-arg "gid=$(id -g)" \
    -f Dockerfile .
popd

mkdir -p output/RPMS
mkdir -p output/SRPMS
docker run --rm \
    --volume "$(pwd)/output/RPMS":/home/builder/rpmbuild/RPMS \
    --volume "$(pwd)/output/SRPMS":/home/builder/rpmbuild/SRPMS \
    --cpus="${num_cpu}" \
    "fedora-acs-kernel-builder:fc${fedora_ver}" \
    "${latest_version}"
