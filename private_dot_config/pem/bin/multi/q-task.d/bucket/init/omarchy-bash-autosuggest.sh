#!/usr/bin/env bash
# Download the newest prebuilt omarchy_autosuggest module to ~/.local/lib.
# The module is loaded by shell/omarchy-bash-autosuggest/autosuggest.bash.

set -euo pipefail

REPO="PEMessage/omarchy-bash-autosuggest"
LIB_DIR="${HOME}/.local/lib"

runcmd() {
    echo "Running: $*"
    "$@"
}

case "$(uname -m)" in
    x86_64|amd64)  ARCH="x86_64" ;;
    aarch64|arm64) ARCH="aarch64" ;;
    *)
        echo "[Err]: unsupported architecture: $(uname -m)"
        exit 1
        ;;
esac

mkdir -p "$LIB_DIR"
cd "$LIB_DIR"

runcmd github-download "$REPO" \
    "omarchy_autosuggest-${ARCH}\\.so$" \
    "omarchy_autosuggest-${ARCH}.so"
