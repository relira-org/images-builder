# Rocky Linux 8 (Green Obsidian) base rootfs for Relira
# Copyright (C) 2026 Tieu Long <long025733@gmail.com>

# The image is only the build host: as debootstrap, dnf installs into an empty root
FROM rockylinux:8 AS build

RUN <<EOF
set -e
mkdir /r
rpm --root /r --initdb
rpm --root /r --import /etc/pki/rpm-gpg/RPM-GPG-KEY-rockyofficial
dnf -y --installroot=/r --releasever=8 --setopt=reposdir=/etc/yum.repos.d --setopt=varsdir=/etc/dnf/vars \
    --nodocs --setopt=install_weak_deps=False install \
    rocky-release \
    dnf \
    systemd \
    systemd-udev \
    dbus \
    NetworkManager \
    iproute \
    iputils \
    usbutils \
    kmod \
    procps-ng \
    util-linux \
    gawk \
    shadow-utils \
    hostname \
    rootfiles \
    findutils \
    bash-completion \
    glibc-langpack-en \
    ca-certificates \
    curl \
    wget \
    sudo \
    nano \
    less \
    tar \
    gzip \
    unzip \
    xz \
    zstd \
    ncurses \
    which \
    file \
    lsof \
    passwd
rm -rf /r/var/cache/dnf /r/var/cache/libdnf5 /r/var/log/*
rm -f /r/etc/machine-id
EOF

FROM scratch
COPY --from=build /r/ /

ENV TERM="xterm-256color"

RUN <<EOF
set -e
echo LANG=en_US.UTF-8 > /etc/locale.conf
ln -sf /usr/share/zoneinfo/UTC /etc/localtime
# Failed under the installroot; else the first boot builds it
systemd-hwdb update
touch /var/log/lastlog
EOF

COPY <<EOF /etc/systemd/journald.conf.d/relira.conf
[Journal]
#Storage=volatile
RuntimeMaxUse=64M
SystemMaxUse=64M
EOF

# eth0 alone: with the host's network, the others are the root's. The host keeps
# the hostname and /etc/resolv.conf. An address from a router advertisement must
# not make it assume eth0 is configured: no DHCP then.
COPY <<EOF /etc/NetworkManager/conf.d/relira.conf
[main]
no-auto-default=*
dns=none
rc-manager=unmanaged
hostname-mode=none

[device]
keep-configuration=no

[keyfile]
unmanaged-devices=except:interface-name:eth0
EOF

COPY --chmod=0600 <<EOF /etc/NetworkManager/system-connections/eth0.nmconnection
[connection]
id=eth0
type=ethernet
interface-name=eth0

[ipv4]
method=auto

[ipv6]
method=auto
EOF

# NetworkManager leaves veths to whoever made them, but eth0 is one
COPY <<EOF /etc/udev/rules.d/86-nm-unmanaged.rules
ENV{ID_NET_DRIVER}=="veth", ENV{NM_UNMANAGED}="0"
EOF

# Mask unneeded services
RUN <<EOF
systemctl mask \
    NetworkManager-wait-online.service \
    systemd-firstboot.service \
    watchdog-mux.service
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
