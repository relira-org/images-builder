# Relira images builder

Base disk images for [Relira](https://relira.pages.dev): sparse ext4, shipped as `.simg.zst`
(Android sparse image, zstd), run as system containers.

| Folder | Distro |
|---|---|
| [`debian_12/`](debian_12) | Debian 12 (bookworm) |
| [`debian_13/`](debian_13) | Debian 13 (trixie) |
| [`debian_14/`](debian_14) | Debian 14 (forky) |
| [`ubuntu_22.04/`](ubuntu_22.04) | Ubuntu 22.04 (jammy) |
| [`ubuntu_24.04/`](ubuntu_24.04) | Ubuntu 24.04 (noble) |
| [`ubuntu_26.04/`](ubuntu_26.04) | Ubuntu 26.04 |
| [`rockylinux_9/`](rockylinux_9) | Rocky Linux 9 |

Each folder has a `Dockerfile` and `catalog.json`.

## Build

```sh
./build.sh FOLDER   # needs docker, arm64
```

Output: `out/FOLDER.simg.zst` and `out/FOLDER.sha256`.
