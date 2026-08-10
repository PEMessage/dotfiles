#!/usr/bin/env bash

runcmd() {
    echo "Runing: $*"
    "$@"
}

if [ ! -f lazydocker ] ; then
    runcmd github-download jesseduffield/lazydocker \
        'lazydocker_.*_Linux_x86_64.tar.gz' \
        lazydocker.tar.gz
    runcmd q-extract -x lazydocker.tar.gz lazydocker:lazydocker
    runcmd rm -rf lazydocker.tar.gz
fi
