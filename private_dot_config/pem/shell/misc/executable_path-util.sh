#!/bin/sh


# Add current dir to PATH
a2p() {
    echo "Runing:"
    echo "export PATH=\"$(pwd):\$PATH\""
    export PATH="$(pwd):$PATH"
    echo
    echo "Current Path:"
    echo $PATH | tr ':' '\n' | grep -v '^$' | head -n5
    echo '...'
}
