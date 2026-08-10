#!/usr/bin/env bash

from="$1"
to="$2"

shift 2

if [ -z "$from" ] || [ -z "$to" ] ; then
    echo "Usage: $(basename $0) FROM.h TO.h"
fi

INLINE_RULE='
---
id: rename-header
language: c
rule:
  pattern: |
    #include "'$from'"
fix: |
    #include "'$to'"
---
id: rename-header-cpp
language: cpp
rule:
  pattern: |
    #include "'$from'"
fix: |
    #include "'$to'"
'

ast-grep scan --inline-rules "$INLINE_RULE" "$@"
