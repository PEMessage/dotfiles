#!/usr/bin/env bash

# A alternative to repo list wihtout need to actually download
repo manifest | xmlstarlet sel -t -m '//project' -v '@name' -o ':' -v '@path' -n | awk -F":" '{print $1":"($2?$2:$1)}'
