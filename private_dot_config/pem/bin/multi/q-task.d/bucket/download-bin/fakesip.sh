#!/bin/bash

runcmd() {
    echo "Runing: $*"
    "$@"
}
NAME=fakesip
BINARY=fakesip
SUFFIX=-linux-x86_64.tar.gz

DOWNLOAD=$NAME$SUFFIX

if [ ! -f "$BINARY" ] ; then
    runcmd github-download MikeWang000000/FakeSIP \
        'fakesip-linux-x86_64.tar.gz' \
        $DOWNLOAD
    filename="$(q-extract -l $DOWNLOAD | grep "/$BINARY$")"
    runcmd q-extract -x "$DOWNLOAD" "$filename:$BINARY"
    runcmd rm -rf "$DOWNLOAD"
fi
