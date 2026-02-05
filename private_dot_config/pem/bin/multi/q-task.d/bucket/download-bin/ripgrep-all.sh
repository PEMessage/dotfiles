#!/bin/bash

runcmd() {
    echo "Runing: $*"
    "$@"
}
NAME=ripgrep_all
BINARY=rga
SUFFIX=.tar.gz

DOWNLOAD=$NAME$SUFFIX

if [ ! -f "$BINARY" ] ; then
    runcmd github-download phiresky/ripgrep-all \
        'ripgrep_all-.*-x86_64-unknown-linux-musl.tar.gz' \
        $DOWNLOAD
    filename="$(q-extract -l $DOWNLOAD | grep "/$BINARY\$")"
    runcmd q-extract -x "$DOWNLOAD" "$filename:$BINARY"
    runcmd rm -rf "$DOWNLOAD"
fi
