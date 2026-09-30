# Rocky Linux 8 (Green Obsidian) base rootfs for Relira
# Copyright (C) 2026 Tieu Long <long025733@gmail.com>

FROM rockylinux:8

ENV TERM="xterm-256color"

RUN <<EOF
set -e
dnf -y update
dnf -y install --nodocs --setopt=install_weak_deps=False \
    systemd \
    systemd-udev \
    dbus \
    iproute \
    kmod \
    procps \
    bash-completion \
    glibc-langpack-en \
    glibc-locale-source \
    ca-certificates \
    findutils \
    wget \
    sudo \
    passwd \
    nano \
    unzip \
    xz \
    ncurses \
    which \
    file \
    lsof

localedef -i en_US -f UTF-8 en_US.UTF-8
ln -sf /usr/share/zoneinfo/UTC /etc/localtime

dnf clean all
rm -rf /var/cache/dnf
rm /etc/machine-id
find /var/log -type f -delete
rm /root/anaconda-ks.cfg /root/original-ks.cfg /root/anaconda-post.log
EOF

COPY <<EOF /etc/systemd/journald.conf.d/relira.conf
[Journal]
#Storage=volatile
RuntimeMaxUse=64M
EOF

# Mask unneeded services
RUN <<EOF
systemctl mask \
    systemd-networkd-wait-online.service \
    watchdog-mux.service
EOF

COPY <<EOF /etc/systemd/network/eth0.network
[Match]
Name=eth0

[Network]
DHCP=yes
EOF

ARG USERNAME=rocky
RUN <<EOF
set -e
useradd -m -u 1000 -s /bin/bash -G wheel $USERNAME
echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/$USERNAME
EOF

USER $USERNAME
WORKDIR /home/$USERNAME
CMD ["/bin/bash", "-il"]
