#!/bin/bash

runcmd() {
    echo "Runing: $*"
    "$@"
}

if [ ! -f sd ] ; then
    runcmd github-download 'chmln/sd' \
        'sd-.*-x86_64-unknown-linux-musl.tar.gz' \
        sd.tar.gz
    filename="$(aichat.shract -l sd.tar.gz | grep '/sd$')"
    runcmd aichat.shract -x sd.tar.gz "$filename:sd"
    runcmd rm -rf sd.tar.gz
fi
