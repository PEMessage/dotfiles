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

    if [ -n "$BASH_VERSION" ]; then
        export PEM_SHELL="bash"
    elif [ -n "$ZSH_VERSION" ]; then
        export PEM_SHELL="zsh"
    else
        echo "Error: No support shell,Only support bash/zsh"
        return
    fi

# -----------------------------------------
# Some basic function 
# -----------------------------------------

    __PEM_ShowVar() {
        [ -n "$1" ] || return 1; 
        eval "echo \"'$1' is '\$$1'\""
        return
    }

    __PEM_ToggleOption() {
        [ -n "$1" ] || return 1; 
        # "$1": key
        # "$2...": value loop list
        local key="$1"
        shift

        local curvalue='' # make shellcheck SC2154 happy
        local next_index="2"
        local x
        eval "curvalue=\"\$$key\""
        for x in "$@"
        do
            if [ "$x" = "$curvalue" ]; then
                break
            fi
            next_index="$((next_index + 1))"
            # echo "$next_index"
        done
        
        [ "$next_index" -gt "$#" ] && {
            next_index=1
        }

        printf "Orig: " && __PEM_ShowVar "$key"
        eval "$key=\$$next_index"
        printf "Now: " && __PEM_ShowVar "$key"

        # unset x  
        # unset curvalue  
        # unset key 
    }



# -----------------------------------------
# Basic enviroment setup
# -----------------------------------------
        # OS Check
    # unameOut=$(uname -a)
    case $(uname -a) in
    # case "$unameOut" in
        *WSL2*)          PEM_OS="linux" 
                         PEM_OS_VARIANT="wsl2";;
        *Microsoft*)     PEM_OS="linux" #wls must be first since it will have Linux in the name too
                         PEM_OS_VARIANT="wsl";;
        Linux*)          PEM_OS="linux";;
        Darwin*)         PEM_OS="mac";;
        CYGWIN*)         PEM_OS="cygwin";;
        MINGW*)          PEM_OS="windows";;
        *Msys)           PEM_OS="windows";;
        *)               PEM_OS="unknow"
    esac

    case $(uname -m) in
        *x86_64*)   PEM_ARCH=x86_64;;
        *amd64*)    PEM_ARCH=x86_64;;
        *arm64*)    PEM_ARCH=arm64;;
        *aarch64*)  PEM_ARCH=arm64;;
        *armv8l*)   PEM_ARCH=arm64;;
        *)          PEM_ARCH="unknow"
    esac

    PEM_INIT_SCRIPT="$(readlink -f ${BASH_SOURCE[0]-$0})"
    export PEM_HOME="${XDG_CONFIG_HOME:-${HOME}/.config}/pem"
    export PEM_DATA_HOME="${XDG_CONFIG_HOME:-${HOME}/.local/share}/pem"
    export PEM_CACHE_HOME="${XDG_CACHE_HOME:-${HOME}/.cache}/pem"
    # No space in these variable
    PEM_ROOT_LIST="$PEM_CACHE_HOME $PEM_DATA_HOME $PEM_HOME"

    # For PATH="$PEM_PRE_PATH:$PATH" use
    #   why not just append to PATH directly ?
    #   make sure $PEM_CACHE_HOME *.pre.bin
    #   have higher prioty then $PEM_HOME
    PEM_PRE_PATH=""

# -----------------------------------------
# alias zone
# -----------------------------------------
    # Some simple alias
    alias grep='grep --color=auto'
    alias cnl='LC_ALL=zh_CN.UTF-8 LANG=zh_CN.UTF-8'
    alias nvi="nvim"

    alias nvim-lazy='NVIM_APPNAME=lazynvim nvim'
    alias mv='mv -i'
    alias rm='rm -i'
    alias cp='cp -i'

    # Default to human readable figures
    alias df='df -h'
    alias du='du -h'
    alias ls='ls --color --time-style=long-iso -h'
    alias ll='ls --color --time-style=long-iso -h -l -a'

# -----------------------------------------
# configuration
# -----------------------------------------
    PEM_Z_BACKEND="fasd"
    PEM_EDITOR="vim"
    export EDITOR="vim"
# -----------------------------------------
# load other setup 
# Step 1: mkdir and add to path
# -----------------------------------------
    # var expansion is not split (by default) in zsh,
    # but command expansions are.
    # Therefore in both Bash and zsh you can use
    # See: 
    # https://unix.stackexchange.com/questions/295033/loop-over-a-string-in-zsh-and-bash
    for x in $(echo $PEM_ROOT_LIST) ;
    do
        [ -d "$x" ] || {
           mkdir -p "$x/bin"
           mkdir -p "$x/shell"
           echo "# this script auto source by $PEM_INIT_SCRIPT" > \
               "$x/shell/autorun.sh"
           mkdir -p "$x/etc"
        }

        [ -x "$x/shell/autorun.sh" ] && {
            . "$x/shell/autorun.sh"
        }

        # [ ! -f "$x/bin/init/already" ] &&
        #     [ -x "$x/bin/init/bootstrap" ] &&
        #     (
        #         "$x/bin/init/bootstrap" "$PEM_OS" "$PEM_ARCH"
        #     )

        # common PATH
        for xbin in \
            "$x/bin"/*.d \
            "$x/bin/arch/${PEM_OS}-${PEM_ARCH}"/*.d \
            "$x/bin/common"/*.d \
            "$x/bin/multi"/*.d 
        do
            [ -d "$xbin" ] && {
                case "$xbin" in
                    *.pre.d)
                        # will be preappend to $PATH later
                        PEM_PRE_PATH="$PEM_PRE_PATH:$xbin"
                        ;;
                    *.d)
                        PATH="$PATH:$xbin"
                        ;;
                esac
            }
        done ; unset xbin
    done ; unset x
    PATH="$PEM_PRE_PATH:$PATH"



        # # arch specific PATH
        # if [ -d "$x/bin/arch/${PEM_OS}-${PEM_ARCH}" ] ; then
        #     for xbin in "$x/bin/arch/${PEM_OS}-${PEM_ARCH}"/*.d
        #     do
        #         [ -d "$xbin" ] && {
        #             case "$xbin" in
        #                 *.pre.d)
        #                     PATH="$xbin:$PATH"
        #                     ;;
        #                 *.d)
        #                     PATH="$PATH:$xbin"
        #                     ;;
        #             esac
        #         }
        #     done
        # fi


# -----------------------------------------
# load other setup 
# Step 2: load other shell script
# -----------------------------------------
    for x in $(echo $PEM_ROOT_LIST) ;
    do
        for xshell in "$x/shell"/* ;
        do
            [ -d "$xshell" ] && {
                for xsh in "$xshell"/*sh ;
                do
                    [ -x "$xsh" ] && {
                        case "$xsh" in
                            *.sh) . "$xsh" ;;
                            *.bash) [ -n "$BASH_VERSION" ] && . "$xsh" ;;
                            *.zsh) [ -n "$ZSH_VERSION" ] && . "$xsh" ;;
                        esac
                    }
                done ; unset xshell
            }
        done ; unset xbin
    done ; unset x


# -----------------------------------------
# Some clean work (at very end)
# -----------------------------------------
    # remove duplicate path
    # From skywind3000/vim/etc init.sh
    if [ -n "$PATH" ]; then
        PEM_TMEP_OLD_PATH=$PATH:; PATH=
        while [ -n "$PEM_TMEP_OLD_PATH" ]; do
            x=${PEM_TMEP_OLD_PATH%%:*}        # the first remaining entry
            case $PATH: in
                *:"$x":*) ;;         # already there
                *) PATH=$PATH:$x;;   # not there yet
            esac
            PEM_TMEP_OLD_PATH=${PEM_TMEP_OLD_PATH#*:}
        done
        PATH=${PATH#:}
        unset PEM_TMEP_OLD_PATH x
    fi

    source ~/.peprofile
