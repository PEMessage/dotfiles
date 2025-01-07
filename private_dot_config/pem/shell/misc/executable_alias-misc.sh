alias ffapt='ffpm i'
alias rsync='rsync --progress -u'
alias s="git status --short --branch"
alias vit='vim $(command ls -tp | grep -v / |  head -n1)'
alias lvim='vim -c "normal '\''0"'
alias lvi='vim -c "normal '\''0"'
alias msudo="sudo env \"PATH=\$PATH\""
alias vi="vim" # if we dont use package manger vim, we shouldn't use package manger vi

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
