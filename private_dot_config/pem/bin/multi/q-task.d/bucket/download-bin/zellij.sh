#!/usr/bin/env bash

runcmd() {
    echo "Runing: $*"
    "$@"
}

if [ ! -f zellij ] ; then
    runcmd github-download zellij-org/zellij \
        'zellij-x86_64-unknown-linux-musl.tar.gz$' \
        zellij.tar.gz
    runcmd q-extract -x zellij.tar.gz zellij:zellij
    runcmd rm -rf zellij.tar.gz
fi
