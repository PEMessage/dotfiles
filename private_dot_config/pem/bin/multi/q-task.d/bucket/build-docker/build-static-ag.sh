#!/bin/sh
# Credit: https://www.gkbrk.com/static-zstd-binary
docker run -t \
    -e UID="$(id -u)" \
    -e GID="$(id -g)" \
    -v "$PWD":/w \
    -w /tmp \
    --rm \
    -it \
    alpine:3.18 \
    sh -c "
    set -e
    apk add musl-dev gcc git make autoconf automake &&
    apk add pcre-dev pcre &&
    apk add zlib-dev zlib-static xz-dev xz-static &&
    

    mkdir -p /build &&
    cd /build &&
    git clone -b master https://github.com/satanson/the_silver_searcher  . &&

    aclocal &&
    autoconf &&
    autoheader &&
    automake --add-missing


    export CFLAGS='-fPIC -static -flto -O2'
    ./configure

    make &&

    chown "$UID:$GID" ag &&
    chmod +x ag &&
    mv ag /w/"
