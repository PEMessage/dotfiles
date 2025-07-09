alias rsync='rsync --progress'
alias s="git status --short --branch"
alias vit='vim $(command ls -tp | grep -v / |  head -n1)'
alias lvim='vim -c "normal '\''0"'
alias lvi='vim -c "normal '\''0"'
alias msudo="sudo env \"PATH=\$PATH\""
alias vi="vim" # if we dont use package manger vim, we shouldn't use package manger vi

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

# alias ttt='command ls -tp | head -n1'
ttt() {
    if [ -n "$1" ] ; then
        local n="$1"
        shift
    else
        local n="1"
    fi
    command ls -tp | awk -v n=$n 'NR==n {print}'
}
