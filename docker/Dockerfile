ARG build_uid=1000
ARG build_gid=1000
ARG fedora_ver=41

FROM fedora:${fedora_ver}

ARG build_uid
ARG build_gid

RUN dnf update -y \
    && dnf install -y https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm \
    && dnf install -y fedpkg fedora-packager rpmdevtools ncurses-devel pesign bpftool

RUN groupadd -o -g ${build_gid} builder \
    && useradd -o -u ${build_uid} -g ${build_gid} -m builder \
    && echo "builder ALL=(ALL) NOPASSWD: /usr/bin/dnf builddep *" > /etc/sudoers.d/builder

USER builder

RUN rpmdev-setuptree

COPY --chown=builder:builder entrypoint.sh /home/builder/entrypoint.sh

WORKDIR /home/builder
ENTRYPOINT ["/home/builder/entrypoint.sh"]
