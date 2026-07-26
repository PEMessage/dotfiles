#!/bin/bash

runcmd() {
    echo "Runing: $*"
    "$@"
}

if [ ! -f dta ] ; then
    runcmd github-download yamsergey/dta -v 0.9.40 \
        'dta-cli-.*.tar.gz' \
        dta.tar.gz
    filename="$(q-extract -l dta.tar.gz | grep '/dta$')"
    runcmd q-extract dta.tar.gz
    runcmd rm -rf dta.tar.gz
    runcmd ln -s dta-cli/bin/dta-cli dta
fi
