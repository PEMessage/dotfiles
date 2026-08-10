#!/usr/bin/env bash

runcmd() {
    echo "Runing: $*"
    "$@"
}

if [ ! -f ddns-go ] ; then
    runcmd github-download jeessy2/ddns-go \
        'ddns-go_.*_linux_x86_64.tar.gz$' \
        ddns-go.tar.gz
    filename="$(q-extract -l ddns-go.tar.gz | grep 'ddns-go$')"
    runcmd q-extract -x ddns-go.tar.gz "$filename:ddns-go"
    runcmd rm -rf ddns-go.tar.gz
fi
