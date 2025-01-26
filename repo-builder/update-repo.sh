#!/usr/bin/env bash

set -e

script_dir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
cd "${script_dir}"

if [ ! -f "${script_dir}/.env" ]; then
    echo "No .env file found. Exiting."
    exit 1
fi

# shellcheck source=/dev/null
source "${script_dir}/.env"

if [ -z "${REPO_GPG_KEY}" ]; then
    echo "GPG key is not set. Exiting."
    exit 2
fi

gpg_key="${REPO_GPG_KEY}"
repo_dir="../output"
mkdir -p "${repo_dir}"


if ! gpg --list-secret-keys --keyid-format=long | grep -q "${gpg_key}"; then
    echo "GPG key ${gpg_key} not found. Exiting."
    exit 3
fi


pushd build-script
./build.sh --num-cpu=1
echo
popd

echo "Exporting public GPG key"
gpg --armor --export "${gpg_key}" > "${repo_dir}/acs-kernel.gpg.key"
echo

echo "Signing the rpms"
find "${repo_dir}/" -name "*.rpm" -exec rpm --addsign --define "_signature gpg" --define "_gpg_name ${gpg_key}" {} \;
echo

echo "Updating repostiory"
createrepo --update "${repo_dir}"
echo

echo "Signing repomd.xml"
gpg --yes --default-key "${gpg_key}" --detach-sign --armor "${repo_dir}/repodata/repomd.xml"