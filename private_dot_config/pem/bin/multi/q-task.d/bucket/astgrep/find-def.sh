#!/bin/bash

regex="$1"
shift
INLINE_RULE='
---
id: replace-misc-include-regex
language: cpp
rule:
  kind: function_declarator
  inside:
    kind: function_definition
  regex: '$regex' 
---
id: replace-misc-include-regex
language: c
rule:
  kind: function_declarator
  inside:
    kind: function_definition
  regex: '$regex' 
'

ast-grep scan --json --inline-rules "$INLINE_RULE" "$@" |
     jq -r '.[] | "\(.file):\(.range.start.line):\(.range.start.column):\(.text)"'
