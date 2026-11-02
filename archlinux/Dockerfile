# Arch Linux base rootfs for Relira
# Copyright (C) 2026 Tieu Long <long025733@gmail.com>

# No official image for arm64: Arch Linux ARM's tarball, as lxc-ci's archlinux.yaml
FROM alpine:3.24 AS fetch
COPY alarm-key.asc /
RUN <<EOF
set -e
apk add gnupg tar gzip curl
b=http://os.archlinuxarm.org/os/ArchLinuxARM-aarch64-latest.tar.gz
curl -fsSL -o /t.tar.gz $b
curl -fsSL -o /t.sig $b.sig
gpg -q --import /alarm-key.asc
gpg --status-fd 1 --verify /t.sig /t.tar.gz \
    | grep -q '^\[GNUPG:\] VALIDSIG 68B3537F39A313B3E574D06777193F152BDBE6A6 '
mkdir /r
tar -xpf /t.tar.gz -C /r --numeric-owner --xattrs --xattrs-include='*'
rm -f /r/etc/resolv.conf
EOF

FROM scratch AS host-arm64
COPY --from=fetch /r/ /

FROM archlinux:latest AS host-amd64

# Only the build host: as pacstrap, which needs mounts a build has not, pacman
# installs into an empty root
FROM host-${TARGETARCH} AS build
RUN <<EOF
set -e
# Docker's seccomp filter refuses pacman's sandbox (Landlock), in the build only
P="pacman --noconfirm --disable-sandbox"
# As the other images: no docs or translations; what is installed later has them
sed -i -e '/^NoExtract/d' -e '/^\[options\]/a NoExtract = usr/share/man/* usr/share/doc/* usr/share/info/* usr/share/help/* usr/share/gtk-doc/* usr/share/locale/*/*' /etc/pacman.conf

pacman-key --init
pacman-key --populate
K=$(pacman -Qq | grep -E '^archlinuxarm-keyring$' || true)
$P -Sy --needed archlinux-keyring $K

mkdir -p /r/var/lib/pacman
$P --root /r -Sy --needed $K \
    base \
    inetutils \
    usbutils \
    bash-completion \
    curl \
    wget \
    sudo \
    nano \
    less \
    unzip \
    xz \
    zstd \
    which \
    file \
    lsof

cp /etc/pacman.d/mirrorlist /r/etc/pacman.d/mirrorlist
# The kernel has no Landlock: pacman cannot download without this
sed -i 's/^#DisableSandboxFilesystem/DisableSandboxFilesystem/' /r/etc/pacman.conf
# No two distros may share a keyring's private key: each makes its own
rm -rf /r/etc/pacman.d/gnupg /r/var/cache/pacman/pkg/* /r/var/lib/pacman/sync/* /r/var/log/*
rm -f /r/etc/machine-id /r/etc/resolv.conf
EOF

FROM scratch
COPY --from=build /r/ /

ENV TERM="xterm-256color"

RUN <<EOF
set -e
# What pacman's hooks could not do without /proc and /dev
ldconfig
systemd-sysusers
systemd-tmpfiles --create --exclude-prefix=/dev --exclude-prefix=/proc --exclude-prefix=/sys --exclude-prefix=/run --exclude-prefix=/tmp || true
systemd-hwdb --usr update
journalctl --update-catalog

sed -i 's/^#\(en_US.UTF-8 UTF-8\)/\1/' /etc/locale.gen
locale-gen
echo LANG=en_US.UTF-8 > /etc/locale.conf
ln -sf /usr/share/zoneinfo/UTC /etc/localtime
EOF

COPY <<EOF /etc/systemd/system/pacman-init.service
[Unit]
Description=Initializes the pacman keyring
Before=archlinux-keyring-wkd-sync.service
ConditionPathIsDirectory=!/etc/pacman.d/gnupg

[Service]
Type=oneshot
ExecStart=/usr/bin/pacman-key --init
ExecStart=/usr/bin/pacman-key --populate

[Install]
WantedBy=multi-user.target
EOF

COPY <<EOF /etc/systemd/journald.conf.d/relira.conf
[Journal]
#Storage=volatile
RuntimeMaxUse=64M
SystemMaxUse=64M
EOF

COPY <<EOF /etc/systemd/network/eth0.network
[Match]
Name=eth0

[Network]
DHCP=yes
EOF

# Mask unneeded services
RUN <<EOF
systemctl enable pacman-init.service systemd-networkd.service
systemctl mask \
    systemd-firstboot.service \
    systemd-networkd-wait-online.service \
    watchdog-mux.service
EOF

ARG USERNAME=arch
RUN <<EOF
set -e
useradd -m -u 1000 -s /bin/bash -G wheel $USERNAME
echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/$USERNAME
EOF

USER $USERNAME
WORKDIR /home/$USERNAME
CMD ["/bin/bash", "-il"]
