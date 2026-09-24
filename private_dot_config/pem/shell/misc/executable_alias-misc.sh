alias rsync='rsync --progress'
alias s="git status --short --branch"
alias vit='vim $(command ls -tp | grep -v / |  head -n1)'
alias lvim='vim -c "normal '\''0"'
alias lvi='vim -c "normal '\''0"'
alias msudo="sudo env \"PATH=\$PATH\""
alias vi="vim" # if we dont use package manger vim, we shouldn't use package manger vi
alias rgv="rg --vimgrep"

alias lazypodman='DOCKER_HOST=unix:///run/user/`id -u`/podman/podman.sock lazydocker'

# -c, --continue [true|false]
# -s, --split=<N>
# -x, --max-connection-per-server=<NUM>
# -k, --min-split-size=<SIZE>
# -j, --max-concurrent-downloads=<N>
# -i, --input-file=<FILE>
alias q-aria2c='aria2c -c -s 16 -x 16'
alias q-less='less -R --mouse -X'
# `sudo -E` will passthough all env expect PATH
# `env "PATH=$PATH"` will using first ARGS as PATH to run following command
alias q-sudo='sudo -E env "PATH=$PATH"'
alias q-xxd='xxd -R always'

# if west build prompt `ModuleNotFoundError: No module named 'elftools'`
# you should add `--with pyelftools` at CMake config stage.
# or maybe need to clean build dir and re-run build
#
# anytree: for west run -t romplit
alias q-west='uvx --with jsonschema --with pyelftools --with anytree west'

# alias ttt='command ls -tp | head -n1'
ttt() {
    command ls -tp "$@" | awk -v n=1 'NR==n {print}'
}

alias q-bell='echo -e "\a"'
alias q-pixi='eval "$(pixi shell-hook)"'
alias opencode2='opencode2 --standalone'

alias q-ssh='ssh -R 7890:localhost:7890'
alias p-ssh='ssh -R 7890:localhost:7890 -o "SetEnv=http_proxy=http://localhost:7890 HTTP_PROXY=http://localhost:7890 https_proxy=http://localhost:7890 HTTPS_PROXY=http://localhost:7890 socks5h_proxy=socks5h://localhost:7890 SOCKS5H_PROXY=socks5h://localhost:7890"'
