#!/bin/bash

runcmd() {
    echo "Runing: $*"
    "$@"
}

if [ ! -f dive ] ; then
    runcmd github-download wagoodman/dive \
        'dive_.*_linux_amd64.tar.gz' \
        dive.tar.gz
    runcmd q-extract dive.tar.gz dive:dive
    runcmd chmod a+x dive
    runcmd rm -rf dive.tar.gz
fi
