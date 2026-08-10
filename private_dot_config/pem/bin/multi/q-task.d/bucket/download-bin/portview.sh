#!/usr/bin/env bash

runcmd() {
    echo "Runing: $*"
    "$@"
}

if [ ! -f portview ] ; then
    runcmd github-download Mapika/portview \
        'portview-linux-x86_64-musl.tar.gz' \
        portview.tar.gz
    filename="$(q-extract -l portview.tar.gz | grep '/portview$')"
    runcmd q-extract -x portview.tar.gz "$filename:portview"
    runcmd rm -rf portview.tar.gz
fi
