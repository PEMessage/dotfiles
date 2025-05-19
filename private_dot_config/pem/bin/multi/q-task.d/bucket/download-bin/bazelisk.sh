#!/bin/bash

runcmd() {
    echo "Runing: $*"
    "$@"
}

if [ ! -f aichat ] ; then
    runcmd github-download bazelbuild/bazelisk \
        'bazelisk-linux-amd64' \
        bazelisk
    runcmd chmod a+x bazelisk
fi
