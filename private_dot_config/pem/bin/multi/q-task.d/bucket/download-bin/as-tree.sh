#!/usr/bin/env bash

runcmd() {
    echo "Runing: $*"
    "$@"
}

if [ ! -f as-tree ] ; then
    runcmd github-download jez/as-tree \
        'as-tree-.*-linux.zip' \
        as-tree.zip
    runcmd q-extract -x as-tree.zip as-tree:as-tree
    runcmd rm -rf as-tree.zip
fi
