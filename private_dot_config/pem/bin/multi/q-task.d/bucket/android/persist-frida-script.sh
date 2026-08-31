#!/bin/bash
set -u

CACHE_ROOT="$HOME/.cache/frida-gadget-release"

# Per-package deployment creates isolated artifacts so several packages with
# different persisted scripts can coexist on the same device:
#   /system/lib/libgadget_<pkg>.so
#   /system/lib/libgadget_<pkg>.config.so
#   /system/lib/frida_script_<pkg>.js
#   /system/bin/silent_<pkg>.sh
#   wrap.<pkg> = /system/bin/silent_<pkg>.sh
GADGET_DIR="/system/lib"
BIN_DIR="/system/bin"
WRAP_PROP=""

# ---------------------------------------------------------------------------
# Resolve the on-device architecture and the matching Frida gadget artifact.
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
# Ensure a frida-gadget binary is available locally, using a per-version cache
# so we only download once per (version, arch) pair. Sets GADGET_BIN.
# ---------------------------------------------------------------------------
ensure_gadget() {
    local arch="$1"
    local filename="frida-gadget-$FRIDA_VERSION-android-$arch.so"
    local cache_dir="$CACHE_ROOT/$FRIDA_VERSION"
    local cached_bin="$cache_dir/$filename"
    local url="https://github.com/frida/frida/releases/download/$FRIDA_VERSION/frida-gadget-$FRIDA_VERSION-android-$arch.so.xz"

    mkdir -p "$cache_dir"

    if [ -f "$cached_bin" ]; then
        echo "Found cached gadget: $cached_bin"
    else
        echo "Downloading from: $url"
        curl -L "$url" -o "$cache_dir/$filename.xz"
        xz -d "$cache_dir/$filename.xz"
    fi

    GADGET_BIN="$cached_bin"
}

# ---------------------------------------------------------------------------
# Remount /system read-write so we can deploy there.
# ---------------------------------------------------------------------------
ensure_system_rw() {
    echo "=== Ensuring /system is writable ==="
    "$ADB" root >/dev/null 2>&1 || true
    "$ADB" wait-for-device
    "$ADB" remount >/dev/null 2>&1
    if ! "$ADB" shell "mount | grep -q 'on /system .*rw'"; then
        echo "WARNING: /system is not mounted rw; trying remount again" >&2
        "$ADB" remount
    fi
}

# ---------------------------------------------------------------------------
# Build per-package device paths, the wrapper script and the gadget config.
# ---------------------------------------------------------------------------
setup_paths() {
    local pkg_slug
    pkg_slug="$PKG"   # dots are legal in file names; keep the package name readable

    REMOTE_GADGET="$GADGET_DIR/libgadget_${pkg_slug}.so"
    REMOTE_CONFIG="$GADGET_DIR/libgadget_${pkg_slug}.config.so"
    REMOTE_SCRIPT="$GADGET_DIR/frida_script_${pkg_slug}.js"
    WRAPPER="$BIN_DIR/silent_${pkg_slug}.sh"
    WRAP_PROP="wrap.$PKG"
}

write_local_artifacts() {
    echo "=== Generating wrapper + config for $PKG ==="
    cat > silent.sh <<EOF
#!/system/bin/sh
export LD_PRELOAD=$REMOTE_GADGET
exec "\$@"
EOF

    cat > libgadget.config.so <<EOF
{
  "interaction": {
    "type": "script",
    "path": "$REMOTE_SCRIPT",
    "on_change": "ignore"
  },
  "log": {
    "level": "info"
  }
}
EOF
}

# ---------------------------------------------------------------------------
# Push gadget + config + script + wrapper to the device. Idempotent: files are
# simply overwritten with identical content.
# ---------------------------------------------------------------------------
deploy_files() {
    echo "=== Deploying gadget for $PKG ==="
    "$ADB" push "$GADGET_BIN" "$REMOTE_GADGET"
    "$ADB" push libgadget.config.so "$REMOTE_CONFIG"
    "$ADB" push "$SCRIPT" "$REMOTE_SCRIPT"
    "$ADB" push silent.sh "$WRAPPER"

    "$ADB" shell "su 0 chmod 755 $REMOTE_GADGET $WRAPPER"
    "$ADB" shell "su 0 chmod 644 $REMOTE_CONFIG $REMOTE_SCRIPT"
}

# ---------------------------------------------------------------------------
# Make the wrap property stick across reboots (build.prop) and take effect
# immediately (setprop). Idempotent: any previous wrap line for this package is
# replaced rather than duplicated.
# ---------------------------------------------------------------------------
persist_wrap_prop() {
    echo "=== Persisting $WRAP_PROP ==="

    "$ADB" shell "su 0 sh -c 'grep -vF \"$WRAP_PROP=\" /system/build.prop > /system/build.prop.new && mv /system/build.prop.new /system/build.prop'"
    "$ADB" shell "su 0 sh -c 'echo $WRAP_PROP=$WRAPPER >> /system/build.prop'"

    "$ADB" shell "su 0 setprop $WRAP_PROP $WRAPPER"
    echo "runtime property: $("$ADB" shell getprop $WRAP_PROP | tr -d '\r\n')"
}

# ---------------------------------------------------------------------------
# Restart the target only if it is not already running with the gadget loaded
# (so re-running this script is a no-op once deployed).
# ---------------------------------------------------------------------------
restart_app() {
    local pid
    pid=$("$ADB" shell pidof "$PKG" | tr -d '\r' | awk '{print $1}')

    if [ -n "$pid" ] && "$ADB" shell "cat /proc/$pid/maps 2>/dev/null | grep -q libgadget_"; then
        echo "Gadget already active in pid $pid; no restart needed"
        return
    fi

    echo "Restarting $PKG to apply LD_PRELOAD..."
    if [ -n "$pid" ]; then
        "$ADB" shell "su 0 kill -9 $pid" || true
        sleep 2
    fi
    if [ -n "$SERVICE" ]; then
        echo "starting service: $SERVICE"
        "$ADB" shell "am startservice -n $SERVICE" >/dev/null 2>&1 || true
    elif [ -n "$ACTIVITY" ]; then
        echo "launching activity: $ACTIVITY"
        "$ADB" shell "am start -n $ACTIVITY" >/dev/null 2>&1 || true
    else
        echo "No -S/--service or -a/--activity given; launch $PKG manually to apply the hook."
    fi
}

verify() {
    echo "=== Verification ==="
    sleep 5
    local pid
    pid=$("$ADB" shell pidof "$PKG" | tr -d '\r' | awk '{print $1}')

    if [ -z "$pid" ]; then
        echo "FAIL: no running process for $PKG" >&2
        return 1
    fi

    echo "process: $PKG pid=$pid"
    echo "gadget mapped: $("$ADB" shell "cat /proc/$pid/maps 2>/dev/null | grep -c libgadget_")"
    echo "gadget threads: $("$ADB" shell "cat /proc/$pid/task/*/comm 2>/dev/null | grep -cE 'gum-js|gadget'")"
    echo "wrap property: $("$ADB" shell getprop $WRAP_PROP | tr -d '\r\n')"

    if "$ADB" shell "cat /proc/$pid/maps 2>/dev/null | grep -q libgadget_"; then
        echo "SUCCESS: gadget deployed and running in $PKG"
    else
        echo "FAIL: gadget not loaded in $PKG" >&2
        return 1
    fi
}

usage() {
    echo "Usage: $0 -p|--package <pkg> -s|--script <local.js> [-S|--service <comp>] [-a|--activity <comp>]"
    echo
    echo "Persist a frida-gadget script on the device for a given package."
    echo "The script is auto-run whenever the package process spawns; no frida-server needed."
    echo
    echo "  -p, --package    target package name (e.g. com.example.app)"
    echo "  -s, --script     local path to the JS script to persist (required)"
    echo "  -S, --service    component to start after restart, e.g. com.example.app/.MyService"
    echo "  -a, --activity   component to launch after restart, e.g. com.example.app/.MainActivity"
    echo "  -h, --help       show this help"
    echo
    echo "  ADB=<path>       override the adb binary (default: adb). Example:"
    echo "                   ADB=\$(which dl.exe) (Windows adb from WSL)"
    echo
    echo "Examples:"
    echo "  # Silence the beeper , auto-restarting its service"
    echo "  ADB=\$(which adb.exe) ./ensure-silent_beep.sh \\"
    echo "      -p com.XXX.simulatebeeper \\"
    echo "      -s silence_gadget.js \\"
    echo "      -S com.XXX.simulatebeeper/.SimulateBeeperService"
    echo
    echo "Idempotent: re-running with the same args re-deploys without duplication."
}

main() {
    SCRIPT=""
    SERVICE=""
    ACTIVITY=""

    while [ $# -gt 0 ]; do
        case "$1" in
            -p|--package) PKG="$2"; shift 2 ;;
            -s|--script) SCRIPT="$2"; shift 2 ;;
            -S|--service) SERVICE="$2"; shift 2 ;;
            -a|--activity) ACTIVITY="$2"; shift 2 ;;
            -h|--help) usage; exit 0 ;;
            *) echo "Unknown option: $1" >&2; usage >&2; exit 1 ;;
        esac
    done

    if [ -z "${PKG:-}" ]; then echo "ERROR: -p/--package is required" >&2; usage >&2; exit 1; fi
    if [ -z "$SCRIPT" ] || [ ! -f "$SCRIPT" ]; then echo "ERROR: -s/--script must point to an existing JS file" >&2; usage >&2; exit 1; fi

    FRIDA_VERSION=$(frida --version)
    ADB="${ADB:-adb}"
    echo "Using ADB: $ADB"
    echo "Frida version: $FRIDA_VERSION"
    echo "Target package: $PKG"
    echo "Script: $SCRIPT"

    local abi arch
    abi=$(detect_abi)
    arch=$(resolve_arch "$abi")

    setup_paths
    ensure_gadget "$arch"
    ensure_system_rw
    write_local_artifacts
    deploy_files
    persist_wrap_prop
    restart_app
    verify
}

main "$@"
