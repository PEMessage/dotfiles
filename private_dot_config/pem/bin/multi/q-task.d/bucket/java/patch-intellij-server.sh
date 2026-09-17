#!/usr/bin/env bash
# Idempotently patch intellij-server + bundled JBR to use a self-built glibc >= 2.28
# Requires: patchelf
set -euo pipefail

SERVER_DIR="${SERVER_DIR:-$HOME/.local/share/nvim/intellij-server/server}"
GLIBC_DIR="${GLIBC_DIR:-$HOME/.local/glibc-2.28/lib}"
GLIBC_LD="$GLIBC_DIR/ld-linux-x86-64.so.2"
SYS_LIBS="/lib/x86_64-linux-gnu:/usr/lib/x86_64-linux-gnu"

[ -d "$SERVER_DIR" ] || { echo "not found: $SERVER_DIR" >&2; exit 1; }
[ -d "$GLIBC_DIR" ] || { echo "not found: $GLIBC_DIR (build glibc first)" >&2; exit 1; }
command -v patchelf >/dev/null || { echo "patchelf not installed" >&2; exit 1; }

# patch <file> <rpath> : backup once, set interpreter+rpath if not already patched
patch_bin() {
    local f="$1" rpath="$2"
    [ -f "$f" ] || { echo "skip (missing): $f"; return 0; }
    local interp
    interp=$(patchelf --print-interpreter "$f" 2>/dev/null || true)
    if [ "$interp" = "$GLIBC_LD" ]; then
        echo "already patched: $f"
    else
        cp -n "$f" "$f.bak"
        [ -n "$interp" ] && patchelf --set-interpreter "$GLIBC_LD" "$f"
        patchelf --force-rpath --set-rpath "$rpath" "$f"
        echo "patched: $f"
    fi
}

G="$GLIBC_DIR"
patch_bin "$SERVER_DIR/bin/intellij-server" "$G:\$ORIGIN/../jbr/lib:\$ORIGIN/../jbr/lib/server:\$ORIGIN:$SYS_LIBS"
patch_bin "$SERVER_DIR/jbr/bin/java"        "$G:\$ORIGIN:\$ORIGIN/../lib:$SYS_LIBS"
patch_bin "$SERVER_DIR/jbr/lib/jspawnhelper" "$G:\$ORIGIN:$SYS_LIBS"
# dlopened by the JVM: only its own rpath applies to its deps (libz.so.1 lives in system dirs)
patch_bin "$SERVER_DIR/jbr/lib/libzip.so"   "\$ORIGIN:$SYS_LIBS"

# Custom loader's default search path is only $G and its cache was empty at build
# time, so dlopened libs (rocksdbjni -> libstdc++.so.6) can't find system libs.
# Regenerate its ld.so.cache to include system multiarch dirs.
GLIBC_ROOT="${GLIBC_DIR%/lib}"
printf '%s\n' "$GLIBC_DIR" /lib/x86_64-linux-gnu /usr/lib/x86_64-linux-gnu /lib /usr/lib \
    > "$GLIBC_ROOT/etc/ld.so.conf"
"$GLIBC_ROOT/sbin/ldconfig" -f "$GLIBC_ROOT/etc/ld.so.conf" -C "$GLIBC_ROOT/etc/ld.so.cache"
echo "ld.so.cache regenerated: $GLIBC_ROOT/etc/ld.so.cache"

"$SERVER_DIR/bin/intellij-server" --version
