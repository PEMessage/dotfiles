#!/usr/bin/env bash

runcmd() {
    echo "Runing: $*"
    "$@"
}

if [ ! -f prise ] ; then
    runcmd github-download rockorager/prise \
        'prise-x86_64-linux.tar.gz' \
        prise.tar.gz
    runcmd q-extract -x prise.tar.gz prise
    runcmd rm -rf prise.tar.gz
fi
