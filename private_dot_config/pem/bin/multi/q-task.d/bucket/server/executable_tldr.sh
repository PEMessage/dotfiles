#!/usr/bin/env bash

case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac
if [ "$color_prompt" = yes ]; then
    blackF="\e[30m" # Fonts color
    redF="\e[1;31m"
    yellowF="\e[1;33m"
    magentaF="\e[1;35m"
    cyanF="\e[1;36m"
    blueF="\e[1;34m"
    greenF="\e[1;32m"
    whiteF="\e[37m"
    blackB="\e[30m" # Background color
    redB="\e[41m"
    greenB="\e[42m"
    yellowB="\e[43m"
    blueB="\e[44m"
    magentaB="\e[45m"
    cyanB="\e[46m"
    whiteB="\e[47m"
    colorEnd="\e[00m"
fi
movelineup="\e[1A"

echo -e "
# server checklist

* add a user(which call useradd):
    ${greenF}${movelineup}
    adduser [USERNAME]
    ${colorEnd}${movelineup}

* add to sudo(need to re-login ssh to take effect):
    ${greenF}${movelineup}
    usermod -aG sudo \`whoami\`
    ${colorEnd}${movelineup}

* map local port to remote:
    ${greenF}${movelineup}
    ssh -R 7890:localhost:7890 server@ip
    ${colorEnd}${movelineup}

* init chezmoi:
    ${greenF}${movelineup}
    sh -c \"\$(curl -fsLS get.chezmoi.io)\" -- init --branch linux-v2  --apply pemessage
    ${colorEnd}${movelineup}

* ~/.perc:
    ${greenF}${movelineup}
    export PEM_PLUG_GROUP=none
    export PATH=\"\$HOME/bin:\$PATH\"
    ${colorEnd}${movelineup}

"
