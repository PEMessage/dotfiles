#!/bin/bash

runcmd() {
    echo "Runing: $*"
    "$@"
}

if [ ! -f tldr ] ; then
    runcmd github-download tealdeer-rs/tealdeer \
        'tealdeer-linux-x86_64-musl$' \
        tldr
    chmod a+x tldr
fi