#!/bin/sh
# Credit: https://www.gkbrk.com/static-zstd-binary
ZSTD_VERSION=1.5.4
URL="https://github.com/facebook/zstd/releases/download"
docker run -t \
    -e UID="$(id -u)" \
    -e GID="$(id -g)" \
    -v "$PWD":/w \
    -w /tmp \
    --rm \
    -it \
    alpine \
    sh -c "
    $Q_TASK_HOOK
    apk add gcc musl-dev make wget &&
    apk add lz4-dev lz4-static zlib-dev zlib-static xz-dev &&

    URL=\"${URL}/v${ZSTD_VERSION}/zstd-${ZSTD_VERSION}.tar.gz\" &&

    wget -O zstd.tar.gz \"\${URL}\" &&
    tar -xzf zstd.tar.gz &&
    cd zstd-${ZSTD_VERSION} &&


    export CFLAGS=-flto
    export LDLAGS=\"-flto -static -static-libgcc -static-libstdc++\"
    export HAVE_LZ4=1
    export HAVE_ZLIB=1
    export HAVE_LZMA=1

    make zstd-release
    cd programs


    chown "$UID:$GID" zstd &&
    chmod +x zstd &&
    chmod +x zstdless &&
    mv zstd zstdless /w/"
