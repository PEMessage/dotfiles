#!/usr/bin/env bash

runcmd() {
    echo "Runing: $*"
    "$@"
}

if [ ! -f aichat ] ; then
    runcmd github-download sigoden/aichat \
        'aichat-.*-x86_64-unknown-linux-musl.tar.gz' \
        aichat.tar.gz
    runcmd q-extract -x aichat.tar.gz aichar:aichat
    runcmd rm -rf aichat.tar.gz
fi
