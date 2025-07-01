#!/bin/sh


# Add current dir to PATH
a2p() {
    if [ "$1" != "" ] ; then 
        echo "Runing:"
        echo "export PATH=\"$(readlink -f "$1"):\$PATH\""
        export PATH="$(readlink -f "$1"):$PATH"
    else 
        echo "Runing:"
        echo "export PATH=\"$(pwd):\$PATH\""
        export PATH="$(pwd):$PATH"
    fi
    echo
    echo "Current Path:"
    echo $PATH | tr ':' '\n' | grep -v '^$' | head -n5
    echo '...'
}



# in order use - in function name, using ksh style declare
function q-activate() {
    local current_dir="$PWD"
    local found=0

    while [ "$current_dir" != "/" ]; do
        if [ -d "$current_dir/.venv" ]; then
            found=1
            break
        fi
        current_dir=$(dirname "$current_dir")
    done

    if [ "$found" -eq 0 ]; then
        echo "No .venv directory found in any parent directory"
        return 1
    else
        source "$current_dir/.venv/bin/activate"
    fi
}
