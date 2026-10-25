#!/usr/bin/env bash
# Builds a Relira base rootfs: DISTRO/Dockerfile -> rootfs -> out/NAME.tar.zst
# Usage: [ARCH=arm64|amd64] ./build.sh debian_13
# ARCH defaults to the host's; another one needs Docker able to run it (emulation).

set -euo pipefail

here=$(cd "$(dirname "$0")" && pwd -P)
DISTRO=$(basename "${1:?usage: $0 DISTRO (a folder with a Dockerfile, e.g. debian_13)}")
[ -f "$here/$DISTRO/Dockerfile" ] || { echo "no $DISTRO/Dockerfile" >&2; exit 1; }
case "${ARCH:-$(uname -m)}" in
    arm64|aarch64) ARCH=arm64 ;;
    amd64|x86_64) ARCH=amd64 ;;
    *) echo "ARCH must be arm64 or amd64, not ${ARCH:-$(uname -m)}" >&2; exit 1 ;;
esac
NAME="${NAME:-${DISTRO}_$ARCH}"
OUT="$here/out"
TAG="relira-rootfs:$NAME"

docker build --platform "linux/$ARCH" -t "$TAG" "$here/$DISTRO"

mkdir -p "$OUT"
rm -f "$OUT/$NAME.tar" "$OUT/$NAME.tar.zst" "$OUT/$NAME.sha256"
cid=$(docker create --platform "linux/$ARCH" "$TAG")
trap 'docker rm -f "$cid" >/dev/null' EXIT

# Extracted as root in Linux so ownership and modes survive
docker export "$cid" > "$OUT/$NAME.tar"

docker run --rm -i -v "$OUT:/out" \
    -e DEBIAN_FRONTEND=noninteractive -e NAME="$NAME" -e OWNER="$(id -u):$(id -g)" \
    debian:13-slim bash -euo pipefail -s <<'BUILD'
apt-get update -qq
apt-get install -y -qq --no-install-recommends zstd >/dev/null
mkdir /r
# --xattrs: file capabilities live in xattrs
tar -x -p --numeric-owner --xattrs --xattrs-include='*' -C /r -f "/out/$NAME.tar"
rm -f "/out/$NAME.tar"

# prevent being detected as a docker container
[ -f /r/.dockerenv ] && rm /r/.dockerenv

echo "localhost" > /r/etc/hostname

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
        printf '\n%s\n' "Passwordless sudo is activated."
        printf '%s\n' "To set password: sudo passwd $(id -un)"
        printf '%s\n'
    }
    : > "$MARKER"
fi
FIRST_LOGIN

echo "rootfs: $(du -sh /r | cut -f1)"

tar -c --numeric-owner --xattrs --xattrs-include='*' --acls \
    --sort=name -C /r . \
    | zstd -q -19 -T0 -c > "/out/$NAME.tar.zst"

chown "$OWNER" "/out/$NAME.tar.zst"
BUILD

(cd "$OUT" && shasum -a 256 "$NAME.tar.zst" > "$NAME.sha256")
ls -lsh "$OUT"
