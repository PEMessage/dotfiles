#!/bin/bash

runcmd() {
    echo "Runing: $*"
    "$@"
}

if [ ! -f tracexec ] ; then
    runcmd github-download kxxt/tracexec \
        'tracexec-x86_64-unknown-linux-gnu-static.tar.gz' \
        tracexec.tar.gz
    runcmd q-extract -x tracexec.tar.gz tracexec:tracexec
    runcmd rm -rf tracexec.tar.gz
fi
