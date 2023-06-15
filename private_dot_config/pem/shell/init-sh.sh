#! /usr/bin/sh
# -----------------------------------------
# prvent load twice
# -----------------------------------------
    # prevent loading twice
    # if [ -z "$_INIT_SH_SH_LOADED" ]; then
    #     _INIT_SH_LOADED=1
    # else
    #     return
    # fi

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
    else
        echo 'Error: init-sh.sh postion in wrong dir'
        return 
    fi

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

    # OS Check
    unameOut=$(uname -a)
    case "$unameOut" in
        *Microsoft*)     PEMOS="WSL";; #wls must be first since it will have Linux in the name too
        *WSL2*)     PEMOS="WSL2";; 
        Linux*)     PEMOS="Linux";;
        Darwin*)    PEMOS="Mac";;
        CYGWIN*)    PEMOS="Cygwin";;
        MINGW*)     PEMOS="Windows";; 
        *Msys)     PEMOS="Windows";;
        *)          PEMOS="UNKNOWN:${unameOut}"
    esac
# -----------------------------------------
# Editor Zone
# -----------------------------------------
    export PEMEDITOR='nvim' # MARK:PEMEDITOR
    pe-editor-toggle(){
        local new_editor 
        if [ -z "$1" ]; then
            if [ "$PEMEDITOR" = "vim" ];then
                new_editor="nvim"
            elif [ "$PEMEDITOR" = "nvim" ];then
                new_editor="vim"
            else
                new_editor="vim"
            fi
        else
            new_editor="$1"
        fi

        # Switch Editor
        echo "Origin: $PEMEDITOR -> Now: $new_editor "
        PEMEDITOR="$new_editor"
        return 0
    }
    pe-editor-save(){
        local current_file="${PEMHOME}/shell/init-sh.sh"
        local line_number=$(grep 'MARK:PEMEDITOR$' $current_file -n | cut -d ':' -f 1) # 

        # Test 
        # echo $line_number
        # echo $line_content | sed --quiet -e "s@'.*'@'${PEMEDITOR}'@1p"

        # Sub 
        #
        # !!! -i will do in-place replace highly damgerous !!!
        local res=`sed --in-place -e "${line_number}s@'.*'@'${PEMEDITOR}'@" "$current_file"`
        local line_content=$(grep 'MARK:PEMEDITOR$' $current_file -n | cut -d ':' -f 2) #

        echo -e "Save the Config to $current_file with: \n $line_content"
    }



    

# -----------------------------------------
# Alias and Path Config Zone
# -----------------------------------------

    case "$OSTYPE" in
        *gnu*|*linux*|*msys*|*cygwin*) alias ls='ls --color=auto' ;;
        *freebsd*|*darwin*) alias ls='ls -G' ;;
    esac



    if [ "$PEMOS" = "WSL2" ]; then
        alias neovide="neovide.exe --wsl"
    fi




    alias grep='grep --color=auto'
    alias cnl='LC_ALL=zh_CN.UTF-8'

    export EDITOR=vim

    alias nvim-lazy='NVIM_APPNAME=lazynvim nvim'
    alias mv='mv -i'
    alias rm='rm -i'


# -----------------------------------------
# Source Zone
# -----------------------------------------

    # PEMHOME=$(find ${PEMHOME}/shell -type d -not -path ${PEMHOME}/shell -exec find {} -type f \;)

    source "$PEMHOME"/shell/fzf/fzf-ff.sh
    source "$PEMHOME"/shell/vless/vless.sh
    source "$PEMHOME"/shell/fff/fff-conf.sh
    source "$PEMHOME"/shell/z-sh/z.sh

