#!/bin/bash

runcmd() {
    echo "Runing: $*"
    "$@"
}

if [ ! -f cc-switch-cli ] ; then
    runcmd github-download SaladDay/cc-switch-cli \
        'cc-switch-cli-linux-x64-musl.tar.gz' \
        cc-switch-cli.tar.gz
    runcmd q-extract -x cc-switch-cli.tar.gz cc-switch:cc-switch-cli
    runcmd rm -rf cc-switch-cli.tar.gz
fi
