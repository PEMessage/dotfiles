#!/bin/bash

# Check if output is a TTY for color support
if [ -t 1 ]; then
    # Terminal colors
    RED=$(printf '\033[1;31m')
    GREEN=$(printf '\033[0;32m')
    BLUE=$(printf '\033[1;34m')
    PURPLE=$(printf '\033[0;35m')
    NC=$(printf '\033[0m') # No Color

    # Apply colors to different elements
    PATH_COLOR="$PURPLE"
    COLON_COLOR="$BLUE"
    LINE_COLOR="$GREEN"
    MATCH_COLOR="$RED"
else
    # No colors for non-TTY output
    RED=''
    GREEN=''
    BLUE=''
    PURPLE=''
    NC=''
    PATH_COLOR=''
    COLON_COLOR=''
    LINE_COLOR=''
    MATCH_COLOR=''
fi

regex="$1"
shift
INLINE_RULE='
---
id: find-def-cpp
language: cpp
rule:
  kind: function_declarator
  inside:
    kind: function_definition
  regex: '$regex' 
---
id: find-def-c
language: c
rule:
  kind: function_declarator
  inside:
    kind: function_definition
  regex: '$regex' 
'
FORMATTER='.[] | '
FORMATTER+='"'
FORMATTER+='\($path_color)\(.file)\($nc)'
FORMATTER+='\($colon_color):\($nc)'
FORMATTER+='\($line_color)\(.range.start.line)\($nc)'
FORMATTER+='\($colon_color):\($nc)'
FORMATTER+='\($line_color)\(.range.start.column)\($nc)'
FORMATTER+='\($colon_color):\($nc)'
FORMATTER+='\($match_color)\(.text)\($nc)'
FORMATTER+='"'

ast-grep scan --json --inline-rules "$INLINE_RULE" "$@"
ast-grep scan --json --inline-rules "$INLINE_RULE" "$@" |
     jq --arg path_color "$PURPLE" \
        --arg colon_color "$BLUE" \
        --arg line_color "$GREEN" \
        --arg match_color "$RED" \
        --arg nc "$NC" \
        -r "$FORMATTER"
