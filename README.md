# Relira Images Builder

Distro image builder for [Relira](https://relira.pages.dev): a root file system per
folder (its `Dockerfile` and `catalog.json`), for arm64 and amd64.

## Build

```sh
./build.sh FOLDER              # the host's arch
ARCH=amd64 ./build.sh FOLDER   # arm64 or amd64; another arch than the host's needs Docker to emulate it
```

Output: `out/FOLDER_ARCH.tar.zst` and `out/FOLDER_ARCH.sha256` (`NAME=` sets the name).

> [!TIP]
> GitHub Actions builds every folder for both arches, each on a runner of its own arch.

## Release

The workflow publishes every image and an `index.json` in one release, which the app
reads from `releases/latest/download/`:

```json
{"schema": 2, "generated": "2026-10-25T00:00:00Z", "images": [
  {"distro": "Debian", "version": "13", "codename": "trixie", "description": "Debian 13 base image",
   "tags": ["systemd"], "default_user": "deb",
   "arch": "amd64", "file": "debian_13_amd64.tar.zst", "sha256": "…", "size": 41943040}
]}
```

An entry is the folder's `catalog.json` plus `arch` (`arm64` or `amd64`), `file`, `sha256`
and `size`; each image has one entry per arch, and the app takes those of its own.
