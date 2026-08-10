#!/usr/bin/env bash

runcmd() {
    echo "Runing: $*"
    "$@"
}

if [ ! -f fd ] ; then
    runcmd github-download sharkdp/fd \
        'fd-.*-x86_64-.*-linux-musl.tar.gz' \
        fd.tar.gz
    filename="$(q-extract -l fd.tar.gz | grep '/fd$')"
    runcmd q-extract -x fd.tar.gz "$filename:fd"
    runcmd rm -rf fd.tar.gz
fi
