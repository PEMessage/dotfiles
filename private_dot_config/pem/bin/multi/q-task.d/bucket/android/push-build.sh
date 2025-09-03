#!/bin/bash


runcmd() {
    echo "Runing: $*"
    "$@"
}

ADB="${ADB:-adb}"



# ========================
push_build_to_device() {
    local rsync_base="$1"
    local local_base="$2"
    local files=("${@:3}")

    echo "Rsync base is $rsync_base"
    echo "Local base is $local_base"
    echo "Files to be pushed: ${files[*]}"

    for file in "${files[@]}"; do
        # Convert Unix path to Windows-style (if needed, though bash typically uses Unix paths)
        if [[ "$ADB" == *.exe ]]; then
            local wfile=$(echo "$file" | sed 's/\//\\/g')
        else
            local wfile="$file"
        fi

        # Get directory name and create local directory
        local dirname=$(dirname "$file")
        local localdir="$local_base/$dirname"

        runcmd mkdir -p "$localdir"

        # Rsync and ADB push commands
        # Note: You'll need to define your Run-Eval and Run-Cmd equivalents
        # For direct execution:
        runcmd rsync "$rsync_base/$file" "$local_base/$file"
        runcmd $ADB push "$local_base/$wfile" "/$file"
    done
}


push_build_to_device "$@"


