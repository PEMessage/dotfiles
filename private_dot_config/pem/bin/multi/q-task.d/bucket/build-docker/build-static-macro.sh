#!/bin/bash

docker run -t \
    -e UID="$(id -u)" \
    -e GID="$(id -g)" \
    -v "$PWD":/w \
    -w /tmp \
    --interactive \
    --rm \
    alpine \
    sh -c "apk add gcc musl-dev git ncurses-static readline-static ncurses-dev readline-dev &&
    git clone https://github.com/PEMessage/macro &&
    cd macro &&
    gcc macro.c -s -O2 -lreadline -lncurses --static -o macro &&
    mkdir out && 
    cp macro out && 
    chown \"\$UID:\$GID\" out/* &&
    chmod +x out/* &&
    mv out/* /w/"
