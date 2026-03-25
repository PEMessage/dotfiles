#!/bin/bash

set -x

# Create the binderfs directory
mkdir -p /dev/binderfs

# Mount binder filesystem
mount -t binder binder /dev/binderfs
chmod 0666 /dev/binderfs/*
ln -s /dev/binderfs/* /dev/

# https://android.googlesource.com/platform/system/core/+/master/rootdir/ueventd.rc
# linux 6.x remove ashmem
if [ -e /dev/ashmem ] ; then
    chmod 0666 /dev/ashmem
fi
