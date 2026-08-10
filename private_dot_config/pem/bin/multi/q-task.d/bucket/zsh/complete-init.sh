#!/usr/bin/env bash

runcmd() {
    echo "Runing: $*"
    "$@"
}

runeval() {
    echo "Runing: $*"
    eval "$*"
}

COMPLETE_PATH="$PEM_HOME/bin/extra/zsh.d"
runcmd cd "$COMPLETE_PATH"

if [ ! -f _chezmoi ] && command -v chezmoi &> /dev/null ; then
    runeval 'chezmoi completion zsh > _chezmoi'
fi

