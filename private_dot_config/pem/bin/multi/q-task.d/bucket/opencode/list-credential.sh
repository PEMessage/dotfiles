#!/usr/bin/env bash
sqlite3 "$(opencode debug paths | grep ^db | awk '{print $2}')" "SELECT * FROM credential;"
