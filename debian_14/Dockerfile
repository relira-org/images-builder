# Debian 14 (forky) base rootfs for Relira
# Copyright (C) 2026 Tieu Long <long025733@gmail.com>

FROM debian:forky-slim

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
    zstd \
    nano \
    less \
    busybox \
    ca-certificates \
    curl \
    sudo \
    whiptail

sed -i 's/^# *\(en_US.UTF-8 UTF-8\)/\1/' /etc/locale.gen
locale-gen

apt-get autoremove -y
apt-get clean
rm -rf /var/lib/apt/lists/*
rm /etc/machine-id
rm /var/lib/dbus/machine-id
find /var/log -type f -delete

# Let services start automatically after apt install
rm -f /usr/sbin/policy-rc.d

# Fix apt install bash completion
rm -f /etc/apt/apt.conf.d/docker-clean
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

ARG USERNAME=deb
RUN <<EOF
set -e
useradd -m -u 1000 -s /bin/bash -G sudo $USERNAME
echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/$USERNAME
EOF

USER $USERNAME
WORKDIR /home/$USERNAME
CMD ["/bin/bash", "-il"]
