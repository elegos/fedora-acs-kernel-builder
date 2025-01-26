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

repo_url="${REPO_URL:-http://localhost:8080}"
port_number="8080" # Changed via --port parameter
repo_dir="$(pwd)/../output" # This should not be changed

while [[ "$#" -gt 0 ]]; do
    case $1 in
        --port=*) 
            port_number="${1#*=}"
            if ! [[ "$port_number" =~ ^[1-9][0-9]?[0-9]?[0-9]?$ ]] || [ "$port_number" -le 1 ] || [ "$port_number" -ge 65535 ]; then
                echo "Invalid port number, must be numeric and between 1 and 65535"
                exit 1
            fi
            ;;
    esac
    shift
done

./update-repo.sh

# Repo file to be imported via:
# sudo dnf config-manager addrepo --from-repofile=REPO_URL/acs-kernel.repo
echo "[acs-kernel]
name=Fedora ACS kernel
baseurl=${repo_url}
enabled=1
gpgcheck=1
gpgkey=${repo_url}/acs-kernel.gpg.key" > "${repo_dir}/acs-kernel.repo"

# In case of SSL/TLS certificate (https), it needs to be handled
# Not required if using a reverse proxy (which will handle it instead of here)
docker run --rm \
        --volume "${repo_dir}":"/usr/share/nginx/html" \
        --name acs-kernel-repo \
        -p "${port_number}:80" \
        -d \
        nginx:latest
