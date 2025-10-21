#!/bin/bash

regex="$1"
shift
INLINE_RULE='
---
id: find-class-or-struct-cpp
language: cpp
rule:
  kind: type_identifier
  inside:
    any:
      - kind: class_specifier
      - kind: struct_specifier
  regex: '$regex'
---
id: find-struct-c
language: c
rule:
  kind: type_identifier
  inside:
    kind: struct_specifier
  regex: '$regex'
'

ast-grep scan --json --inline-rules "$INLINE_RULE" "$@" |
     jq -r '.[] | "\(.file):\(.range.start.line):\(.range.start.column):\(.text)"'
