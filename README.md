# Relira Images Builder

Distro image builder for [Relira](https://relira.pages.dev).

## Build

> [!TIP]
> Use GitHub Actions if you don't have a local ARM64 Docker environment.

```sh
./build.sh FOLDER   # requires Docker on ARM64
```

Output: `out/FOLDER.simg.zst` and `out/FOLDER.sha256`.
