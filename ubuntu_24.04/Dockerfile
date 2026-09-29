# Ubuntu 24.04 LTS (noble) base rootfs for Relira
# Copyright (C) 2026 Tieu Long <long025733@gmail.com>

FROM ubuntu:24.04

ARG DEBIAN_FRONTEND=noninteractive
ENV TERM="xterm-256color"

RUN <<EOF
set -e
apt-get update
apt-get install -y --no-install-recommends \
    systemd-sysv \
    udev \
    kmod \
    dbus \
    libpam-systemd \
    bash-completion \
    iproute2 \
    iputils-ping \
    locales \
    procps \
    xz-utils \
    unzip \
    nano \
    less \
    busybox \
    ca-certificates \
    curl \
    sudo \
    whiptail

locale-gen en_US.UTF-8
ln -sf /usr/share/zoneinfo/UTC /etc/localtime

apt-get autoremove -y
apt-get clean
rm -rf /var/lib/apt/lists/*
rm /.dockerenv
rm /etc/machine-id
rm /var/lib/dbus/machine-id
find /var/log -type f -delete
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

COPY <<EOF /etc/hosts
127.0.0.1   localhost
::1         localhost ip6-localhost ip6-loopback
ff02::1     ip6-allnodes
ff02::2     ip6-allrouters
EOF

RUN <<EOF
set -e
#useradd -m -u 1000 -s /bin/bash -G sudo ubuntu
echo "ubuntu ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/ubuntu
EOF

USER ubuntu
WORKDIR /home/ubuntu
CMD ["/bin/bash", "-il"]
