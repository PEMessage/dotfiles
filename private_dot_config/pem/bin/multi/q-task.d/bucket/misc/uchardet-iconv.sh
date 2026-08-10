#!/usr/bin/env bash

set -xe
set -o pipefail

uchardet * | grep GB | cut -d ':' -f 1 | xargs -I{} bash -c 'iconv -f  GB2312 -t UTF-8 {} | pysponge {}'
