# Fedora ACS kernel builder

The aim of this project is to produce automated rpm files for the latest available Fedora kernel

## Prerequisites
- bash on Linux (or having `/proc/cpuinfo` in any case)
- Python 3 (any? 3.x version)
- Docker
- User allowed to execute docker without sudo

## How it works

It's a simple BASH script which does the following actions:

1. [latest_kernel.py](./latest_kernel.py): searches for the latest kernel available for the target Fedora version in bodhi
2. [build.sh](./build.sh): builds a local docker image to build the kernel with
3. [entrypoint.sh](./docker/entrypoint.sh): downloads the kernel sources
4. [entrypoint.sh](./docker/entrypoint.sh): downloads and injects into the spec file the [some-natalie acs kernel patch](https://github.com/some-natalie/fedora-acs-override/blob/main/acs/add-acs-override.patch)
5. [entrypoint.sh](./docker/entrypoint.sh): builds the kernel
6. If no error happens, the new rpm files will show up in output/(S)RPMS/

## How to run the script

```bash
./build.sh [--fedora-version=41] [--num-cpu=$(grep -c processor /proc/cpuinfo)]
```

🙃

## Supported Fedora versions

For now, Fedora 41 (current version) is the target of this project.

## Make your own repository

If you want, you can download or clone the repository and go to the [repo-builder](./repo-builder) folder. There you'll find `start-repo.sh` and `update-repo.sh`.

### One-time actions (setup)

1. Generate a new gpg key via `gpg --full-generate-key` and take note of its ID
2. Copy `.env.example` into `.env`
   - `REPO_GPG_KEY`: set it with the previously generated GPG key's ID
   - `REPO_URL`: leave it to localhost:8080 if you want to make a local repository, otherwise change it accordingly. If using a reverse proxy (i.e. https://myrepo.mydomain.com), you should set it here.
3. To keep the repository updated, use a scheduler like cronjob. An example of crontab is available [here](./repo-builder/crontab.example).

### Start the repository

`cd /path/to/cloned/git/repo/repo-builder && ./start-repo.sh [--port=8080]`

## Credits

- [Natalie Somersall](https://github.com/some-natalie) (and relative contributors) for her incredible work creating and maintaining the [fedora-acs-override](https://github.com/some-natalie/fedora-acs-override) GitHub repository, from which I take her patch and from which I wrote the build steps.
