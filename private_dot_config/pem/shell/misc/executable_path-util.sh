#!/bin/sh


# Add current dir to PATH
a2p() {
    export PATH="$(pwd):$PATH"
    echo $PATH | tr ':' '\n' | head -n5
    echo '...'
}
