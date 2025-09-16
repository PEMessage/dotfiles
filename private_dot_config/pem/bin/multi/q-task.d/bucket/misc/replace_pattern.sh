#!/bin/bash

# Check if both arguments are provided
if [ $# -ne 2 ]; then
    echo "Usage: $0 <search_pattern> <replace_pattern>"
    exit 1
fi

search_pattern="$1"
replace_pattern="$2"

# Find files containing the search pattern and replace it
rg "$search_pattern" -l | xargs -I{} sed -i "s@${search_pattern}@${replace_pattern}@g" {}

echo "Replaced '$search_pattern' with '$replace_pattern' in all matching files"
