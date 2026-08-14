#!/usr/bin/env bash
set -euo pipefail

SERVICE_NAME=deskflow.service
SERVICE_DIR=~/.config/systemd/user
SERVICE_FILE=$SERVICE_DIR/$SERVICE_NAME
FLATPAK_APP=org.deskflow.deskflow
CONFIG_FILE=""
EXEC_LINE=""

die() {
    echo "[Error]: $*" >&2
    exit 1
}

detect_deskflow() {
    if command -v deskflow > /dev/null 2>&1; then
        EXEC_LINE="ExecStart=$(command -v deskflow)"
        CONFIG_FILE=~/.config/Deskflow/Deskflow.conf
        echo "[Info]: found native deskflow"
        return 0
    fi

    if command -v flatpak > /dev/null 2>&1 && flatpak list --app --columns=application 2>/dev/null | grep -qx "$FLATPAK_APP"; then
        EXEC_LINE="ExecStart=$(command -v flatpak) run $FLATPAK_APP"
        CONFIG_FILE=~/.var/app/$FLATPAK_APP/config/Deskflow/Deskflow.conf
        echo "[Info]: found deskflow flatpak ($FLATPAK_APP)"
        return 0
    fi

    die "deskflow not found (no deskflow binary, no flatpak app $FLATPAK_APP). pls install deskflow first."
}

set_autohide() {
    if [ ! -f "$CONFIG_FILE" ]; then
        echo "[Warn]: config $CONFIG_FILE not found, skip autoHide. GUI window will show on first start."
        return 0
    fi

    if grep -q '^autoHide=' "$CONFIG_FILE"; then
        sed -i 's/^autoHide=.*/autoHide=true/' "$CONFIG_FILE"
    else
        sed -i '/^\[gui\]/a autoHide=true' "$CONFIG_FILE"
    fi
    echo "[Info]: set autoHide=true in $CONFIG_FILE (GUI starts hidden, open from tray)"
}

write_unit() {
    mkdir -p "$SERVICE_DIR"

    if [ -f "$SERVICE_FILE" ]; then
        echo "[Info]: systemd user unit '$SERVICE_FILE' already exists"
        return 0
    fi

    cat > "$SERVICE_FILE" <<EOF
[Unit]
Description=Deskflow (keyboard/mouse sharing)
After=graphical-session.target

[Service]
Type=simple
$EXEC_LINE
Restart=on-failure
RestartSec=5

[Install]
WantedBy=default.target
EOF
    echo "[Info]: systemd user unit created"
}

start_service() {
    systemctl --user daemon-reload
    systemctl --user enable --now "$SERVICE_NAME"
    echo "[Info]: '$SERVICE_NAME' enabled and started"
}

main() {
    detect_deskflow
    set_autohide
    write_unit
    start_service
}

main
