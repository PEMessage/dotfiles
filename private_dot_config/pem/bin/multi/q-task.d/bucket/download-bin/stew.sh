#!/usr/bin/env bash

runcmd() {
    echo "Runing: $*"
    "$@"
}

if [ ! -f stew ] ; then
    runcmd github-download marwanhawari/stew -v v0.6.0 \
        'stew-.*-linux-amd64.tar.gz' \
        stew.tar.gz
    runcmd q-extract -x stew.tar.gz stew:stew
    runcmd rm -rf stew.tar.gz
fi
