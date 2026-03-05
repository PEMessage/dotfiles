#!/bin/bash

runcmd() {
    echo "Runing: $*"
    "$@"
}

if [ ! -f tmux ] ; then
    runcmd github-download mjakob-gh/build-static-tmux \
        'tmux.linux-amd64.gz$' \
        tmux.gz
    runcmd gunzip tmux.gz
    runcmd chmod a+x tmux
fi