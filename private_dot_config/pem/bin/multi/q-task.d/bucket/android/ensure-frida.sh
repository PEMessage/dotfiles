#!/bin/bash
set -u

CACHE_ROOT="$HOME/.cache/frida-server-release"

# Where the binary is deployed on the device. Overridden to /system/bin when
# -S/--system is given (e.g. when /data is mounted noexec but /system is rw).
DEPLOY_DIR="/data/local/tmp"

# ---------------------------------------------------------------------------
# Resolve the on-device architecture and the matching Frida release artifact.
# ---------------------------------------------------------------------------
detect_abi() {
    local abi
    abi=$("$ADB" shell getprop ro.product.cpu.abi | head -n1 | tr -d '\r\n')
    echo "Device ABI detected: $abi" >&2
    echo "$abi"
}

resolve_arch() {
    local abi="$1"
    case "$abi" in
        arm64-v8a) echo "arm64" ;;
        armeabi-v7a|armeabi) echo "arm" ;;
        x86_64) echo "x86_64" ;;
        x86) echo "x86" ;;
        *) echo "Unsupported architecture: $abi" >&2; return 1 ;;
    esac
}

# ---------------------------------------------------------------------------
# Ensure a frida-server binary is available locally, using a per-version cache
# so we only download once per (version, arch) pair.
# ---------------------------------------------------------------------------
ensure_frida_server() {
    local arch="$1"
    local filename="frida-server-$FRIDA_VERSION-android-$arch"
    local cache_dir="$CACHE_ROOT/$FRIDA_VERSION"
    local cached_bin="$cache_dir/$filename"
    local url="https://github.com/frida/frida/releases/download/$FRIDA_VERSION/$filename.xz"

    mkdir -p "$cache_dir"

    if [ -f "$cached_bin" ]; then
        echo "Found cached frida-server: $cached_bin"
    else
        echo "Downloading from: $url"
        curl -L "$url" -o "$cache_dir/$filename.xz"
        xz -d "$cache_dir/$filename.xz"
    fi

    cp "$cached_bin" frida-server
}

# ---------------------------------------------------------------------------
# Push the binary to the device and launch it as root in the background.
# ---------------------------------------------------------------------------
deploy_frida_server() {
    local remote_bin="$DEPLOY_DIR/frida-server"
    echo "=== Deploying and Starting Frida Server on Device ($remote_bin) ==="
    "$ADB" shell "su 0 pkill -f frida-server" || true
    "$ADB" push frida-server "$DEPLOY_DIR/"
    "$ADB" shell "su 0 chmod 755 $remote_bin"
    "$ADB" shell "su 0 $remote_bin -D"
}

verify() {
    echo "=== Verification ==="
    sleep 2
    frida-ps -U
    echo "Frida-server is running successfully!"
}

main() {
    while [ $# -gt 0 ]; do
        case "$1" in
            -S|--system) DEPLOY_DIR="/system/bin" ;;
            -h|--help)
                echo "Usage: $0 [-S|--system]"
                echo "  -S, --system   Deploy frida-server to /system/bin instead of /data/local/tmp"
                exit 0 ;;
            *) echo "Unknown option: $1" >&2; exit 1 ;;
        esac
        shift
    done

    FRIDA_VERSION=$(frida --version)
    ADB="${ADB:-adb}"
    echo "Using ADB: $ADB"

    local abi arch
    abi=$(detect_abi)
    arch=$(resolve_arch "$abi")

    ensure_frida_server "$arch"
    deploy_frida_server
    verify
}

main "$@"
