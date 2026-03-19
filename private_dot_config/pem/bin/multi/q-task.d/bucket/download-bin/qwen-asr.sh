#!/bin/bash

runcmd() {
    echo "Runing: $*"
    "$@"
}

if [ ! -f qwen-asr ] ; then
    runcmd github-download huanglizhuo/QwenASR \
        'qwen-asr-.*-x86_64-unknown-linux-gnu.tar.gz' \
        qwen-asr.tar.gz
    runcmd q-extract -x qwen-asr.tar.gz qwen-asr:qwen-asr
    runcmd rm -rf qwen-asr.tar.gz
fi
