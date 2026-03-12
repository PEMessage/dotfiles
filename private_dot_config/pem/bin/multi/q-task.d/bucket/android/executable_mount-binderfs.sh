#!/bin/bash

set -x

# Create the binderfs directory
mkdir -p /dev/binderfs

# Mount binder filesystem
mount -t binder binder /dev/binderfs
chmod 0666 /dev/binderfs/*
ln -s /dev/binderfs/* /dev/

# https://android.googlesource.com/platform/system/core/+/master/rootdir/ueventd.rc
chmod 0666 /dev/ashmem
