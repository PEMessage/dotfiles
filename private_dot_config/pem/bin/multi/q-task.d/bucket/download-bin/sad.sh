#!/bin/bash

runcmd() {
    echo "Runing: $*"
    "$@"
}

if [ ! -f sad ] ; then
    runcmd github-download 'ms-jpq/sad' \
        'x86_64-unknown-linux-musl.zip' \
        sad.zip
    q-extract sad.zip
    rm sad.zip
fi

# https://github.com/ms-jpq/sad/releases/download/v0.4.32/x86_64-unknown-linux-musl.zip
