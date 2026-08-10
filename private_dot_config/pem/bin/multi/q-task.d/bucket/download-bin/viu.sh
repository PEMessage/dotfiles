#!/usr/bin/env bash

runcmd() {
    echo "Runing: $*"
    "$@"
}

if [ ! -f viu ] ; then
    runcmd github-download atanunq/viu \
        'viu-x86_64-unknown-linux-musl' \
        viu
    chmod a+x viu
fi
