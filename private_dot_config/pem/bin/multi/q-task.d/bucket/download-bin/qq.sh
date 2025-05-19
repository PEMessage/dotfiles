#!/bin/bash

runcmd() {
    echo "Runing: $*"
    "$@"
}

if [ ! -f aichat ] ; then
    runcmd github-download JFryy/qq \
        'qq-.*-linux-amd64.tar.gz$' \
        qq.tar.gz
    runcmd q-extract -x qq.tar.gz qq:qq
    runcmd rm -rf qq.tar.gz
fi
