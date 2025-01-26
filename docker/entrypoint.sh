#!/usr/bin/env bash

f_version="$(rpm -E %fedora)"
k_version="$1"
patch_url="https://raw.githubusercontent.com/some-natalie/fedora-acs-override/refs/heads/main/acs/add-acs-override.patch"
patch_filename="add-acs-override.patch"
patch_absolute_url="${HOME}/rpmbuild/SOURCES/${patch_filename}"

set -e

# Download kernel source and build the dependencies
koji download-build --arch=src "kernel-${k_version}.fc${f_version}.src.rpm"
rpm -Uvh "kernel-${k_version}.fc${f_version}.src.rpm"
cd rpmbuild/SPECS/
sudo dnf builddep -y kernel.spec

# Download ACS patch
curl "${patch_url}" > "${patch_absolute_url}"

# Edit kernel.spec
spec_file="${HOME}/rpmbuild/SPECS/kernel.spec"
sed -i "s/.*define buildid .*/%define buildid .acs/" "${spec_file}"

# - define the ACS patch
sed -i '/%if !%{nopatches}/,/Patch999999/{/Patch999999/i\
'"Patch1000: add-acs-override.patch"'
}' "${spec_file}"

# - apply the ACS patch
sed -i '/# END OF PATCH APPLICATIONS/i\
ApplyPatch add-acs-override.patch' "${spec_file}"

# Build the kernel
rpmbuild -bb kernel.spec