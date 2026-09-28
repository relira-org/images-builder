# Relira images builder

Base disk images for [Relira](https://relira.pages.dev): each distro is a sparse ext4 image,
shipped as `.simg.zst` (an Android sparse image, zstd), that runs under Relira as a system container.

| Folder | Distro |
|---|---|
| [`debian_13/`](debian_13) | Debian 13 (trixie) |
| [`ubuntu_24.04/`](ubuntu_24.04) | Ubuntu 24.04 (noble) |

Each folder has a `Dockerfile` and a `catalog.json`. `./build.sh FOLDER` (docker, arm64) 
builds it into `out/FOLDER.simg.zst` and `out/FOLDER.sha256`.