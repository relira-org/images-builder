#!/usr/bin/env bash
# Builds a Relira base disk: DISTRO/Dockerfile -> rootfs -> sparse ext4 image -> out/NAME.simg.zst
# Usage: ./build.sh debian_13

set -euo pipefail

here=$(cd "$(dirname "$0")" && pwd -P)
DISTRO=$(basename "${1:?usage: $0 DISTRO (a folder with a Dockerfile, e.g. debian_13)}")
[ -f "$here/$DISTRO/Dockerfile" ] || { echo "no $DISTRO/Dockerfile" >&2; exit 1; }
SIZE="${SIZE:-100G}"
NAME="${NAME:-$DISTRO}"
OUT="$here/out"
TAG="relira-rootfs:$NAME"

docker build --platform linux/arm64 -t "$TAG" "$here/$DISTRO"

mkdir -p "$OUT"
rm -f "$OUT/$NAME.img" "$OUT/$NAME.simg.zst" "$OUT/$NAME.sha256"
cid=$(docker create --platform linux/arm64 "$TAG")
trap 'docker rm -f "$cid" >/dev/null' EXIT

# Extracted as root in Linux so ownership and modes survive
docker export "$cid" > "$OUT/$NAME.tar"

docker run --rm -i --platform linux/arm64 -v "$OUT:/out" \
    -e DEBIAN_FRONTEND=noninteractive -e NAME="$NAME" -e SIZE="$SIZE" -e OWNER="$(id -u):$(id -g)" \
    debian:13-slim bash -euo pipefail -s <<'BUILD'
apt-get update -qq
apt-get install -y -qq --no-install-recommends e2fsprogs zstd android-sdk-libsparse-utils libcap2-bin >/dev/null
mkdir /r
# --xattrs: file capabilities live in xattrs
tar -x -p --numeric-owner --xattrs --xattrs-include='*' -C /r -f "/out/$NAME.tar"
rm -f "/out/$NAME.tar"

# prevent being detected as a docker container
[ -f /r/.dockerenv ] && rm /r/.dockerenv

echo "localhost" >> /r/etc/hostname

cat > /r/etc/hosts <<'HOSTS'
127.0.0.1   localhost
::1         localhost ip6-localhost ip6-loopback
ff02::1     ip6-allnodes
ff02::2     ip6-allrouters
HOSTS

cat > /r/etc/profile.d/relira-first-login.sh <<'FIRST_LOGIN'
MARKER="$HOME/.first-login-done"
if [ ! -e "$MARKER" ]; then
    [ 0 != "$(id -u)" ] && {
        printf '%s\n' "Passwordless sudo is activated."
        printf '%s\n' "To set password: sudo passwd $(id -un)"
        printf '%s\n'
    }
    : > "$MARKER"
fi
FIRST_LOGIN

echo "rootfs: $(du -sh /r | cut -f1)"
mkfs.ext4 -q -L relira-root -m 1 -E root_owner=0:0,assume_storage_prezeroed=1 -d /r "/tmp/$NAME.img" "$SIZE"
e2fsck -fn "/tmp/$NAME.img" >/dev/null 2>&1 || { echo "e2fsck found problems" >&2; exit 1; }

# -s: skip the holes instead of reading SIZE of zeros
img2simg -s "/tmp/$NAME.img" "/tmp/$NAME.simg"
zstd -q -19 -T0 -c "/tmp/$NAME.simg" > "/out/$NAME.simg.zst"

chown "$OWNER" "/out/$NAME.simg.zst"
BUILD

(cd "$OUT" && shasum -a 256 "$NAME.simg.zst" > "$NAME.sha256")
ls -lsh "$OUT"
