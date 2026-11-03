# Alpine 3.24 base rootfs for Relira
# Copyright (C) 2026 Tieu Long <long025733@gmail.com>

FROM alpine:3.24

ENV TERM="xterm-256color"

# The image is a minirootfs: alpine-base makes it what an install is
RUN <<EOF
set -e
apk update
apk add \
    alpine-base \
    logrotate \
    kmod \
    shadow \
    bash \
    bash-completion \
    iproute2 \
    iputils \
    usbutils \
    procps-ng \
    tzdata \
    xz \
    unzip \
    zstd \
    nano \
    less \
    ca-certificates \
    curl \
    wget \
    doas \
    doas-sudo-shim \
    newt

rm -rf /var/cache/apk/*
find /var/log -type f -delete
EOF

# As the LXC images (lxc-ci's alpine.yaml); no ttys, they are the root's here
RUN <<EOF
set -e
sed -i 's/^#\?rc_sys=.*/rc_sys="lxc"/' /etc/rc.conf
# Honor fstab
sed -i 's/-lxc//' /etc/init.d/localmount
sed -i -e '/^tty[0-9]::/d' -e '/^#ttyS0::/d' -e '/^# Put a getty on the serial port/d' \
    -e 's|^# Set up a couple of getty.s|&\n::respawn:/sbin/getty 38400 console|' /etc/inittab

for s in bootmisc syslog; do rc-update add $s boot; done
for s in networking crond; do rc-update add $s default; done
for s in killprocs savecache; do rc-update add $s shutdown; done
EOF

# No eth0: Relira gives it its address before boot
COPY <<EOF /etc/network/interfaces
auto lo
iface lo inet loopback
EOF

# user@host, as the other images; /etc/bash for a bash that is not a login shell
COPY <<'EOF' /etc/profile.d/prompt.sh
if [ -n "$BASH_VERSION" ] || [ -n "$BB_ASH_VERSION" ]; then
	PS1='\u@\h:\w\$ '
elif [ -n "$ZSH_VERSION" ]; then
	PS1='%n@%m:%~%# '
fi
EOF
RUN ln -s /etc/profile.d/prompt.sh /etc/bash/prompt.sh

# By group: a user the app renames or adds is in wheel
COPY --chmod=0400 <<EOF /etc/doas.d/wheel.conf
permit nopass :wheel
EOF

ARG USERNAME=alpine
RUN <<EOF
set -e
useradd -m -u 1000 -s /bin/bash -G wheel,video,audio,input $USERNAME
# No password, but not locked: sshd without PAM refuses a locked account's keys
usermod -p '*' $USERNAME
EOF

USER $USERNAME
WORKDIR /home/$USERNAME
CMD ["/bin/bash", "-il"]
