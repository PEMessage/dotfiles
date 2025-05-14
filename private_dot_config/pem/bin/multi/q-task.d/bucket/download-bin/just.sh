#!/bin/bash

runcmd() {
    echo "Runing: $*"
    "$@"
}

if [ ! -f just ] ; then
    runcmd github-download casey/just \
        'just-.*-x86_64-unknown-linux-musl.tar.gz' \
        just.tar.gz
    runcmd q-extract -x just.tar.gz just
    runcmd rm -rf just.tar.gz
fi
