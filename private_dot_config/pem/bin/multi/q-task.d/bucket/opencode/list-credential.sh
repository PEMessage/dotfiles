#!/usr/bin/env bash
! command -v sqlite3 > /dev/null && echo "sqlite3 not exist" && exit

if command -v jq > /dev/null ; then
    sqlite3 --json \
        "$(opencode debug paths | grep ^db | awk '{print $2}')" \
        "SELECT * FROM credential;" |
        jq 'map(.value = (try (.value|fromjson) catch .value))'
else
    sqlite3 "$(opencode debug paths | grep ^db | awk '{print $2}')" "SELECT * FROM credential;"
fi

