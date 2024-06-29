#!/bin/bash
version=6.6.12

docker run -t \
    -e UID="$(id -u)" \
    -e GID="$(id -g)" \
    -v "$PWD":/w \
    -w /tmp \
    --interactive \
    --rm \
    alpine \
    sh -c "apk add gcc musl-dev wget  ncurses-static ncurses-dev make &&
    wget  https://ftp.gnu.org/pub/gnu/global/global-$version.tar.gz &&
    tar xzvf global-$version.tar.gz && 
    cd global-$version &&
    LDFLAGS=--static ./configure && 
    make &&
    mkdir out && 
    cp htags/htags out && 
    cp gtags-cscope/gtags-cscope out &&
    cp global/global out &&
    cp gtags/gtags out &&
    chown \"\$UID:\$GID\" out/* &&
    chmod +x out/* &&
    mv out/* /w/"
