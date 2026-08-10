#!/usr/bin/env bash

runcmd() {
    echo "Runing: $*"
    "$@"
}

if [ ! -f tokei ] ; then
    runcmd github-download XAMPPRocky/tokei -v v13.0.0-alpha.0 \
        'tokei-x86_64-unknown-linux-musl.tar.gz' \
        tokei.tar.gz
    runcmd q-extract -x tokei.tar.gz tokei:tokei
    runcmd rm -rf tokei.tar.gz
fi
