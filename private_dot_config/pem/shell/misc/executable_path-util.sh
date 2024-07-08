#!/bin/sh


# Add current dir to PATH
a2p() {
    export PATH="$(pwd):$PATH"
    echo $PATH | tr ':' '\n' | grep -v '^$' | head -n5
    echo '...'
}
