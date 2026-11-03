# openSUSE Leap 16.0 base rootfs for Relira
# Copyright (C) 2026 Tieu Long <long025733@gmail.com>

FROM opensuse/leap:16.0

ENV TERM="xterm-256color"

RUN <<EOF
set -e
zypper -n refresh
zypper -n update
zypper -n install --no-recommends \
    systemd \
    udev \
    dbus-1 \
    NetworkManager \
    iproute2 \
    iputils \
    usbutils \
    kmod \
    procps \
    util-linux \
    gawk \
    shadow \
    hostname \
    findutils \
    bash-completion \
    glibc-locale-base \
    ca-certificates \
    ca-certificates-mozilla \
    curl \
    wget \
    sudo \
    system-group-wheel \
    timezone \
    terminfo \
    nano \
    less \
    tar \
    gzip \
    unzip \
    xz \
    zstd \
    ncurses-utils \
    which \
    file \
    lsof

echo LANG=en_US.UTF-8 > /etc/locale.conf
ln -sf /usr/share/zoneinfo/UTC /etc/localtime

zypper -n clean -a
rm -f /etc/machine-id
find /var/log -type f -delete

# Remove the container image's tweaks so zypper behaves like a normal install
rm -f /etc/zypp/zypp.conf
EOF

COPY <<EOF /etc/systemd/journald.conf.d/relira.conf
[Journal]
#Storage=volatile
RuntimeMaxUse=64M
SystemMaxUse=64M
EOF

# eth0 alone: with the host's network, the others are the root's. The host keeps
# the hostname and /etc/resolv.conf. Relira gives eth0 its address before boot,
# which NetworkManager keeps as it is (an external connection): no profile.
COPY <<EOF /etc/NetworkManager/conf.d/relira.conf
[main]
no-auto-default=*
dns=none
rc-manager=unmanaged
hostname-mode=none

[keyfile]
unmanaged-devices=except:interface-name:eth0
EOF

# Mask unneeded services
RUN <<EOF
systemctl enable NetworkManager.service
systemctl mask \
    NetworkManager-wait-online.service \
    systemd-firstboot.service \
    watchdog-mux.service
EOF

ARG USERNAME=opensuse
RUN <<EOF
set -e
mkdir -p /etc/sudoers.d
useradd -m -u 1000 -s /bin/bash -G wheel $USERNAME
echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/$USERNAME
EOF

USER $USERNAME
WORKDIR /home/$USERNAME
CMD ["/bin/bash", "-il"]
