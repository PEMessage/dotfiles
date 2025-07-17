#!/bin/bash
# See: https://github.com/microsoft/WSL/issues/11261

# When booting waydroid, `weston --backend=wayland-backend.so` need these
# See: 
#   https://gist.github.com/onomatopellan/c5220c0efddaff69aaff77cca80b7b8e # core about waydroid wsl2 setup
#   https://github.com/microsoft/WSL/issues/11261 # fix failed to connect to parent wayland compositor: no such file or directory display option: (none), wayland_display=wayland-0
# Notice:
#   Also need a /mnt/wslg/runtime-dir/pulse for it actually work
set -x
mkdir -p ~/.config/systemd/user
cat  <<EOF > ~/.config/systemd/user/symlink-wayland-socket.service
[Unit]
Description=Symlink Wayland socket to XDG_RUNTIME_DIR

[Service]
Type=oneshot
ExecStart=/usr/bin/ln -s /mnt/wslg/runtime-dir/wayland-0      \$XDG_RUNTIME_DIR
ExecStart=/usr/bin/ln -s /mnt/wslg/runtime-dir/wayland-0.lock \$XDG_RUNTIME_DIR
ExecStart=/usr/bin/ln -s /mnt/wslg/runtime-dir/pulse \$XDG_RUNTIME_DIR

[Install]
WantedBy=default.target
EOF

systemctl --user enable symlink-wayland-socket.service
