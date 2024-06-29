#!/bin/sh
# Credit: https://gist.github.com/Saoneth/02f08d4714e6fc035e7017c74b3ef29a
docker run -t \
    -e UID="$(id -u)" \
    -e GID="$(id -g)" \
    -v "$PWD":/w \
    -w /tmp \
    --rm \
    alpine \
    sh -c '
    apk add gcc make musl-dev git perl &&
    git clone https://github.com/hoytech/vmtouch.git
    cd vmtouch &&
    CFLAGS="-static" make &&
    strip -s vmtouch &&
    chown "$UID:$GID" vmtouch &&
    chmod +x vmtouch &&
    mv vmtouch /w/'
