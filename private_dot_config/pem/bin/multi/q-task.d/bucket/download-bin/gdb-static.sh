#!/usr/bin/env bash

runcmd() {
    echo "Runing: $*"
    "$@"
}

if [ ! -f gdb-static ] ; then
    runcmd github-download guyush1/gdb-static \
        'gdb-static-full-x86_64.tar.gz' \
        gdb-static.tar.gz
    mkdir gdb-static
    mv gdb-static.tar.gz gdb-static
    cd gdb-static
    q-extract gdb-static.tar.gz
    rm gdb-static.tar.gz

    mv gdb gdb-static
fi
