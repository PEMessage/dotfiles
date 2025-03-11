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
