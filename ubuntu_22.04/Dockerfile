# Ubuntu 22.04 LTS (jammy) base rootfs for Relira
# Copyright (C) 2026 Tieu Long <long025733@gmail.com>

FROM ubuntu:22.04

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
    tzdata \
    procps \
    xz-utils \
    unzip \
    zstd \
    nano \
    less \
    busybox \
    ca-certificates \
    curl \
    wget \
    sudo \
    whiptail

locale-gen en_US.UTF-8
ln -sf /usr/share/zoneinfo/UTC /etc/localtime

apt-get autoremove -y
apt-get clean
rm -rf /var/lib/apt/lists/*
rm /etc/machine-id
rm /var/lib/dbus/machine-id
find /var/log -type f -delete

# Let services start automatically after apt install
rm -f /usr/sbin/policy-rc.d

# Remove Docker image tweaks so apt, dpkg and services behave like a normal install
rm -f /usr/sbin/policy-rc.d \
      /etc/apt/apt.conf.d/docker-* \
      /etc/dpkg/dpkg.cfg.d/docker-apt-speedup
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

COPY <<EOF /etc/systemd/network/ct_eth0.network
[Match]
Name=ct_eth0

[Network]
DHCP=yes
EOF

ARG USERNAME=ubuntu
RUN <<EOF
set -e
useradd -m -u 1000 -s /bin/bash -G sudo $USERNAME
echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/$USERNAME
EOF

USER $USERNAME
WORKDIR /home/$USERNAME
CMD ["/bin/bash", "-il"]
