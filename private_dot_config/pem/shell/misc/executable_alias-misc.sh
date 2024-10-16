alias ffapt='ffpm i'
alias rsync='rsync --progress'
alias s="git status --short --branch"
alias vit='vim $(command ls -tp | grep -v / |  head -n1)'
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
