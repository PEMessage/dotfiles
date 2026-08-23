#!/usr/bin/env bash

set -x
SCRIPT_PATH="$(readlink -f $0)"
SCRIPT_DIR="$(dirname "$THIS_SCRIPT")"
BIN_PATH="${PEM_DATA_HOME:-${HOME}/.local/share/pem}/bin/misc.d"

mkdir -p "$BIN_PATH"
cc -o "$BIN_PATH/herdr-passthough"  "$SCRIPT_DIR/src/herdr-passthough.c"



