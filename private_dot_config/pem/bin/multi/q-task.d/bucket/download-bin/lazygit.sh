#!/usr/bin/env bash

runcmd() {
    echo "Runing: $*"
    "$@"
}

if [ ! -f lazygit ] ; then
    runcmd github-download jesseduffield/lazygit \
        'lazygit_.*_Linux_x86_64.tar.gz' \
        lazygit.tar.gz
    runcmd q-extract -x lazygit.tar.gz lazygit:lazygit
    runcmd rm -rf lazygit.tar.gz
fi
