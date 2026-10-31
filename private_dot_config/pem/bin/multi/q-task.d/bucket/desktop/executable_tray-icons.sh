#!/usr/bin/env bash
# tray-icons — show every StatusNotifierItem (system-tray) icon and the file it resolves to.
#
# The tray is DMS's `systemTray` widget: it renders StatusNotifierItems (SNI) that
# apps export over the session bus. Each item carries an IconName, which is either
# an absolute path or a name looked up in the *active* icon theme (LinkIcons, see
# ~/nix/aspects/desktop/niri/_package/link-icon-theme.nix).
set -euo pipefail

B=/run/current-system/sw/bin/busctl
W=org.kde.StatusNotifierWatcher
WP=/StatusNotifierWatcher
IF=org.kde.StatusNotifierItem

# Icon theme, then its Inherits chain, most-preferred first (matches index.theme).
CHAIN=(LinkIcons Papirus-Dark breeze-dark MoreWaita Adwaita hicolor)

# Icon search roots (XDG data dirs), most specific first.
ROOTS=(
  "$HOME/.local/share/icons"
  /etc/profiles/per-user/"$USER"/share/icons
  "$HOME/.nix-profile/share/icons"
  /run/current-system/sw/share/icons
)

best_in() { # best_in <theme-dir> <name>  -> prefer scalable, then largest size dir
  local tdir=$1 name=$2 hit
  hit=$(find -L "$tdir" \( -path '*/scalable/*' -o -path '*/symbolic/*' \) \
        -name "$name.svg" 2>/dev/null | sort | head -1)
  [[ -z $hit ]] && hit=$(find -L "$tdir" -name "$name.svg" -o -name "$name.png" 2>/dev/null | sort -V | tail -1)
  [[ -n $hit ]] && printf '%s\n' "$hit"
}

resolve() { # resolve <icon-name-or-absolute-path>
  local name=$1 theme tdir hit
  [[ $name == /* ]] && { printf '%s\n' "$name"; return; }
  for theme in "${CHAIN[@]}"; do
    for r in "${ROOTS[@]}"; do
      tdir=$r/$theme
      [[ -d $tdir ]] || continue
      hit=$(best_in "$tdir" "$name")
      [[ -n $hit ]] && { printf '%s\n' "$hit"; return; }
    done
  done
  printf '(not found in chain: %s)\n' "${CHAIN[*]}"
}

items=$("$B" --user get-property org.kde.StatusNotifierWatcher "$WP" \
        "$W" RegisteredStatusNotifierItems | sed 's/^as [0-9]* //' | tr -d '"')
[[ -n ${items// } ]] || { echo "no tray items"; exit 0; }

for item in $items; do
  dest=${item%%/*}; path=/${item#*/}
  get() { "$B" --user get-property "$dest" "$path" "$IF" "$1" 2>/dev/null | sed 's/^s //; s/^"//; s/"$//'; }
  title=$(get Title); id=$(get Id); icon=$(get IconName)
  printf '── %s  [%s]\n' "$title" "$id"
  printf '   IconName : %s\n' "$icon"
  printf '   File     : %s\n' "$(resolve "$icon")"
done
