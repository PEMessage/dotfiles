#!/bin/bash

runcmd() {
    echo "Runing: $*"
    "$@"
}

if [ ! -f rgr ] ; then
    runcmd github-download acheronfail/repgrep \
        'repgrep-.*-x86_64-unknown-linux-musl.tar.gz$' \
        rgr.tar.gz
    filename="$(q-extract -l rgr.tar.gz | grep '/rgr$')"
    runcmd q-extract -x rgr.tar.gz "$filename:rgr"
    runcmd rm -rf rgr.tar.gz
fi
