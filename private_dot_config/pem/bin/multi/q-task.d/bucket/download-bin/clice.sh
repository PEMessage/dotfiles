#!/bin/bash

runcmd() {
    echo "Runing: $*"
    "$@"
}

if [ ! -f clice ] ; then
    runcmd github-download clice-io/clice \
        'clice-x64-linux-gnu.tar.gz' \
        clice.tar.gz
    runcmd q-extract clice.tar.gz
    runcmd rm -rf clice.tar.gz
fi
