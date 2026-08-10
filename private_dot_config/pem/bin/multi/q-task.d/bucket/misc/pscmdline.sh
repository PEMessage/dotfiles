#!/usr/bin/env bash

# See:
# 【【DEFCON33 2025】第81集 - DEF CON 33：Silent Leaks - 共享Linux环境进程泄露秘密全解析】
# 【精准空降到 02:28】
# https://www.bilibili.com/video/BV1RV2wB5EBx/?share_source=copy_web&vd_source=ba726eaf572f03aca4ba3d79f0118159&t=148
# or ps auxww

for cmdline_file in /proc/*/cmdline; do
    # Extract PID from the path
    pid=$(basename "$(dirname "$cmdline_file")")
    
    cmdline=$(tr '\0' ' ' < "$cmdline_file")
        
    # Remove trailing space if present
    cmdline=${cmdline% }
        
    # Only display if cmdline is not empty
    if [ -n "$cmdline" ]; then
        printf "PID: %-6s Command: %s\n" "$pid" "$cmdline"
    fi
done 2>/dev/null  # Suppress error messages for inaccessible processes

