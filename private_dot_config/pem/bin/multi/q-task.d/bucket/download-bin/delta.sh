#!/bin/bash

runcmd() {
    echo "Runing: $*"
    "$@"
}
NAME=delta
SUFFIX=.tar.gz

DOWNLOAD=$NAME$SUFFIX

if [ ! -f "$NAME" ] ; then
    runcmd github-download dandavison/delta \
        'delta-.*-x86_64-unknown-linux-musl.tar.gz' \
        $NAME.tar.gz
    filename="$(q-extract -l $DOWNLOAD | grep "/$NAME\$")"
    runcmd q-extract -x "$DOWNLOAD" "$filename:$NAME"
    runcmd rm -rf "$DOWNLOAD"
fi
