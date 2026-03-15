#!/bin/bash

runcmd() {
    echo "Runing: $*"
    "$@"
}

if [ ! -f rg ] ; then
    runcmd github-download BurntSushi/ripgrep \
        '^ripgrep-.*-x86_64-unknown-linux-musl.tar.gz$' \
        rg.tar.gz
    filename="$(q-extract -l rg.tar.gz | grep '/rg$')"
    runcmd q-extract -x rg.tar.gz "$filename:rg"
    runcmd rm -rf rg.tar.gz
fi
