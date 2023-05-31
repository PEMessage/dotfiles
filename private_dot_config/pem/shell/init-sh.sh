# -----------------------------------------
# prvent load twice
# -----------------------------------------
    # prevent loading twice
    if [ -z "$_INIT_SH_LOADED" ]; then
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
# Alias Zone
# -----------------------------------------

    case "$OSTYPE" in
        *gnu*|*linux*|*msys*|*cygwin*) alias ls='ls --color=auto' ;;
        *freebsd*|*darwin*) alias ls='ls -G' ;;
    esac

    export EDITOR=vim


    if [ -d "$HOME/.config/pem" ]; then
        export PEMHOME="$HOME/.config/pem"
    fi

# -----------------------------------------
# Path Zone
# -----------------------------------------

    # set PATH so it includes user's private bin if it exists
    if [ -d "$PEMHOME/bin" ]; then
        export PATH="$PEMHOME/bin:$PATH"
    fi

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
# Function Zone
# -----------------------------------------

    source "$PEMHOME"/shell/fzf/fzf-ff.sh
    source "$PEMHOME"/shell/vless/vless.sh
    source "$PEMHOME"/shell/fff/fff-conf.sh

