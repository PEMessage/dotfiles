#! /usr/bin/sh
# -----------------------------------------
# prvent load twice
# -----------------------------------------
    # prevent loading twice
    if [ -z "$_INIT_SH_SH_LOADED" ]; then
        _INIT_SH_LOADED=1
    else
        return
    fi

    # skip if in non-interactive mode
    case "$-" in
        *i*) ;;
        *) return
    esac




# -----------------------------------------
# Path Zone
# -----------------------------------------
    if [ -d "$HOME/.config/pem" ]; then
        export PEMHOME="$HOME/.config/pem"
    fi

    # set PATH so it includes user's private bin if it exists
    if [ -d "$PEMHOME/bin" ]; then
        export PATH="$PEMHOME/bin:$PATH"
    fi

    export PEMEDITOR="vim"
    pe-togglevim(){
        local new_editor 
        if [ -z "$1" ]; then
            if [ "$PEMEDITOR" = "vim" ];then
                new_editor = "nvim"
            elif [ "$PEMEDITOR" = "nvim" ];then
                new_editor = "vim"
            else
                new_editor = "vim"
            fi
        else
            new_editor = $1
        fi


        # Switch Editor
        echo "Origin: $PEMEDITOR -> Now: $new_editor "
        PEMEDITOR = $1
        return 0
    }

    # remove duplicate path
    if [ -n "$PATH" ]; then
        old_PATH=$PATH:; PATH=
        while [ -n "$old_PATH" ]; do
            x=${old_PATH%%:*}        # the first remaining entry
            case $PATH: in
                *:"$x":*) ;;         # already there
                *) PATH=$PATH:$x;;   # not there yet
            esac
            old_PATH=${old_PATH#*:}
        done
        PATH=${PATH#:}
        unset old_PATH x
    fi

    export PATH

# -----------------------------------------
# Alias and Path Config Zone
# -----------------------------------------

    case "$OSTYPE" in
        *gnu*|*linux*|*msys*|*cygwin*) alias ls='ls --color=auto' ;;
        *freebsd*|*darwin*) alias ls='ls -G' ;;
    esac
    alias grep='grep --color=auto'
    alias cnl='LC_ALL=zh_CN.UTF-8'

    export EDITOR=vim

    alias nvim-pe='NVIM_APPNAME=penvim nvim'
    alias mv='mv -i'


# -----------------------------------------
# Function Zone
# -----------------------------------------

    source "$PEMHOME"/shell/fzf/fzf-ff.sh
    source "$PEMHOME"/shell/vless/vless.sh
    source "$PEMHOME"/shell/fff/fff-conf.sh

