#!/usr/bin/env bash

runcmd() {
    echo "Runing: $*"
    "$@"
}

if [ ! -f cli-proxy-api ] ; then
    runcmd github-download router-for-me/CLIProxyAPI \
        'CLIProxyAPI_.*_linux_amd64.tar.gz' \
        cli-proxy-api.tar.gz
    runcmd q-extract -x cli-proxy-api.tar.gz cli-proxy-api
    runcmd rm -rf cli-proxy-api.tar.gz
fi
