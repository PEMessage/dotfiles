#!/bin/sh


curl -s "$1/models" -H "Authorization: Bearer $2" | jq -r '.data[].id'
