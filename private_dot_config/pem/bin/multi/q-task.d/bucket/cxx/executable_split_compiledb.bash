#!/usr/bin/env bash

# Check if input file and regex pattern are provided
if [ $# -lt 2 ]; then
    echo "Usage: $0 <regex_pattern> <compile_commands.json>"
    exit 1
fi

regex_pattern="$1"
input_file="$2"

# Check if input file exists
if [ ! -f "$input_file" ]; then
    echo "Error: File '$input_file' not found"
    exit 1
fi

# Use jq to filter entries where the file doesn't match the regex
jq --arg pattern "$regex_pattern" '[ .[] | select(.file | test($pattern)) ]' "$input_file"
