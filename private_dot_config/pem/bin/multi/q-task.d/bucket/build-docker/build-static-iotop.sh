#!/bin/sh
# Credit: https://gist.github.com/Saoneth/02f08d4714e6fc035e7017c74b3ef29a
docker run -t \
    -e UID="$(id -u)" \
    -e GID="$(id -g)" \
    -v "$PWD":/w \
    -w /tmp \
    --rm \
    alpine \
    sh -c 'wget "https://github.com/Tomas-M/iotop/archive/master.zip" &&
    unzip master.zip &&
    cd iotop-master &&
    apk add gcc make ncurses-dev linux-headers ncurses-static musl-dev &&
    V=1 LIBS="-no-pie -static -static-libgcc -static-libstdc++" make &&
    strip -s iotop &&
    chown "$UID:$GID" iotop &&
    chmod +x iotop &&
    mv iotop /w/'
