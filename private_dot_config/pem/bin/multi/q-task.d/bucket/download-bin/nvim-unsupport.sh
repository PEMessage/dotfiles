#!/usr/bin/env bash

runcmd() {
    echo "Runing: $*"
    "$@"
}

if [ ! -f nvim ] ; then
    runcmd github-download neovim/neovim-releases \
        'nvim-linux-x86_64.appimage$' \
        nvim
    chmod a+x nvim
fi
