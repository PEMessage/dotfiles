#!/bin/bash

runcmd() {
    echo "Runing: $*"
    "$@"
}

if [ ! -f fzf ] ; then
    runcmd github-download junegunn/fzf \
        'fzf-.*-linux_amd64.tar.gz' \
        fzf.tar.gz
    filename="$(q-extract -l fzf.tar.gz | grep '/fzf$')"
    runcmd q-extract -x fzf.tar.gz "$filename:fzf"
    runcmd rm -rf fzf.tar.gz
fi
