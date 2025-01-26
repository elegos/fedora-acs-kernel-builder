# Fedora ACS kernel builder

The aim of this project is to produce automated rpm files for the latest available Fedora kernel

## Prerequisites
- bash (tested on Linux, might work on Windows via cygwin, too)
- Python 3 (any? 3.x version)
- Docker
- User allowed to execute docker without sudo

## How it works

It's a simple BASH script which does the following actions:

1. [latest_kernel.py](./latest_kernel.py): searches for the latest kernel available for the target Fedora version in bodhi
2. [build.sh](./build.sh): builds a local docker image to build the kernel with
3. [entrypoint.fc41.sh](./docker/entrypoint.fc41.sh): downloads the kernel sources
4. [entrypoint.fc41.sh](./docker/entrypoint.fc41.sh): downloads and injects into the spec file the [some-natalie acs kernel patch](https://github.com/some-natalie/fedora-acs-override/blob/main/acs/add-acs-override.patch)
5. [entrypoint.fc41.sh](./docker/entrypoint.fc41.sh): builds the kernel
6. If no error happens, the new rpm files will show up in output/(S)RPMS/

## How to run the script

```bash
./build.sh
```

🙃

## Supported Fedora versions

For now, Fedora 41 (current version) is the target of this project.

## Credits

- [Natalie Somersall](https://github.com/some-natalie) (and relative contributors) for her incredible work creating and maintaining the [fedora-acs-override](https://github.com/some-natalie/fedora-acs-override) GitHub repository, from which I take her patch and from which I wrote the build steps.
