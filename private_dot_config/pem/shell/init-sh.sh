# Shoud be by ~/.bashrc or ~/.zshrc
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
        export PEMSHELL="bash"
    elif [ -n "$ZSH_VERSION" ]; then
        export PEMSHELL="zsh"
    else
        echo "Error: No support shell,Only support bash/zsh"
        return 
    fi

    function pe-parent_path() {
        echo $( dirname  "$(readlink -f "$1")" );
    }

    # From andorid envsetup.sh
    case "$PEMSHELL" in
        *bash*)
            function pe-check_type() { type -t "$1"; }
         
            ;;

        *zsh*)
            function pe-check_type() { type "$1"; }
            ;;
    esac





# -----------------------------------------
# Path Zone
# -----------------------------------------
    if [ -d $(pe-parent_path "$(pe-parent_path "${BASH_SOURCE[0]-$0}")")  ] ; then 
        export PEMHOME=$(pe-parent_path "$(pe-parent_path "${BASH_SOURCE[0]-$0}")")
    # elif [ -d "$HOME/.config/pem" ]; then
        # export PEMHOME="$HOME/.config/pem"
    else
        echo 'Error: init-sh.sh postion in wrong dir'
        return 
    fi

    # set PATH so it includes user's private bin if it exists
    if [ -d "$PEMHOME/bin" ]; then
        temp_d=$d
        for d in "$PEMHOME"/bin/*.d; do 
            [ -d $d ] &&  export PATH="$PATH:$d"
        done
        for d in "$PEMHOME"/bin/*.kd; do 
            [ -d $d ] &&  source "$d/init-sh.sh"
        done
        d=$temp_d
        unset temp_d
    fi

    # go install default path
    if [ -d "$HOME/go/bin" ]; then
        export PATH="$PATH:$HOME/go/bin"
    fi
    if [ -d "/usr/local/go/bin" ]; then
        export PATH=$PATH:/usr/local/go/bin
    fi

    # remove duplicate path
    # From skywind3000/vim/etc init.sh
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

    if [ -z "$XDG_DATA_HOME" ] ; then
        export XDG_DATA_HOME="$HOME/.local/share"
    fi

# -----------------------------------------
# Global Var Zone
# -----------------------------------------

    # OS Check
    # unameOut=$(uname -a)
    case $(uname -a) in
    # case "$unameOut" in
        *Microsoft*)     PEM_OS="WSL";; #wls must be first since it will have Linux in the name too
        *WSL2*)          PEM_OS="WSL2";; 
        Linux*)          PEM_OS="Linux";;
        Darwin*)         PEM_OS="Mac";;
        CYGWIN*)         PEM_OS="Cygwin";;
        MINGW*)          PEM_OS="Windows";; 
        *Msys)           PEM_OS="Windows";;
        *)               PEM_OS="UNKNOWN:${unameOut}"
    esac

    case $(uname -m) in 
        *x86_64*)   PEM_ARCH=x86_64;;
        *amd64*)    PEM_ARCH=x86_64;;
        *arm64*)    PEM_ARCH=arm64;;
        *aarch64*)  PEM_ARCH=arm64;;
        *armv8l*)   PEM_ARCH=arm64;;
    esac

    # if xdg_cache_home didn't exist use ~/.cache
    export PEM_CACHE_HOME=${XDG_CACHE_HOME:-${HOME}/.cache}/pem

    # dir not exist
    if [ ! -d "$PEM_CACHE_HOME" ]; then
        # is a file
        if [  -f "$PEM_CACHE_HOME" ]; then
            PEM_CACHE_HOME=''
            echo "Warning: cache home: $PEM_CACHE_HOME is a file"
        else
            mkdir -p "$PEM_CACHE_HOME"
            mkdir -p "$PEM_CACHE_HOME/shell"
            touch "$PEM_CACHE_HOME/shell/init-sh.sh"
        fi
    fi

    export PEM_DATA_HOME=${XDG_DATA_HOME:-${HOME}/.local/share}/pem
    # dir not exist
    if [ ! -d "$PEM_DATA_HOME" ]; then
        # is a file
        if [  -f "$PEM_DATA_HOME" ]; then
            PEM_DATA_HOME=''
            echo "Warning: data home: $PEM_DATA_HOME is a file"
        else
            mkdir -p "$PEM_DATA_HOME"
            mkdir -p "$PEM_DATA_HOME/shell"
            mkdir -p "$PEM_DATA_HOME/bin"
            mkdir -p "$PEM_DATA_HOME/pre-bin"
            touch "$PEM_DATA_HOME/shell/init-sh.sh"
        fi
    fi

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
    pe-editor-save()
    {
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
        *gnu*|*linux*|*msys*|*cygwin*)
            alias ls='ls --color=auto --time-style=full-iso -h'
        ;;
        *freebsd*|*darwin*)
            alias ls='ls -G'
        ;;
    esac



    if [ "$PEM_OS" = "WSL2" ]; then
        alias neovide="neovide.exe --wsl"
    fi

    if [ "$PEM_OS" = "Windows" ]; then
        alias stmux="script -c tmux /dev/null"
    fi




    alias grep='grep --color=auto'
    alias cnl='LC_ALL=zh_CN.UTF-8 LANG=zh_CN.UTF-8'
    alias nvi="nvim"

    export EDITOR=vim


    alias nvim-lazy='NVIM_APPNAME=lazynvim nvim'
    alias mv='mv -i'
    alias rm='rm -i'
    alias cp='cp -i'

    # Default to human readable figures
    alias df='df -h'
    alias du='du -h'


# -----------------------------------------
# Lazy load
# -----------------------------------------

# -----------------------------------------
# Source Zone
# -----------------------------------------
    if [ -f "${PEMHOME}/arch/${PEM_ARCH}/init-sh.sh"  ]; then
        source "${PEMHOME}/arch/${PEM_ARCH}/init-sh.sh" 
    fi

    # Method 1: use findutils
    #
    # PEMFUNCLIST=$(find ${PEMHOME}/shell -type d -not -path ${PEMHOME}/shell -exec find {} -type f -name '*.sh' \; )
    # for i in `echo $PEMFUNCLIST | tr '\n' ' ' ` ;
    # do
    #     source "$i"
    # done

    # Method 2: use bash/zsh style 
    for d in "${PEMHOME}"/shell/* ; do 
        if [ -d "$d" ] ; then
            # echo "$d"
            for f in "$d"/*.sh ; do 
                if [ -f "$f" ] ; then
                    source "$f"
                fi
            done
        fi 
    done

    if [ -n "$BASH_VERSION" ] ; then
        for d in "${PEMHOME}"/shell/* ; do 
            if [ -d "$d" ] ; then
                # echo "$d"
                for f in "$d"/*.bash ; do 
                    if [ -f "$f" ] ; then
                        source "$f"
                    fi
                done
            fi 
        done
    fi

    if [ -n "$ZSH_VERSION" ] ; then
        for d in "${PEMHOME}"/shell/* ; do 
            if [ -d "$d" ] ; then
                # echo "$d"
                for f in "$d"/*.zsh ; do 
                    if [ -f "$f" ] ; then
                        source "$f"
                    fi
                done
            fi 
        done
    fi
    
    if [ -f "${PEM_CACHE_HOME}/shell/init-sh.sh" ] ; then
        source "${PEM_CACHE_HOME}/shell/init-sh.sh"
    fi

    if [ -f "${PEM_DATA_HOME}/shell/init-sh.sh" ] ; then
        source "${PEM_DATA_HOME}/shell/init-sh.sh"
    fi
     
    # Method 3: Manualy source
    # source "$PEMHOME"/shell/fzf/fzf-ff.sh
    # source "$PEMHOME"/shell/vless/vless.sh
    # source "$PEMHOME"/shell/fff/fff-conf.sh
    # source "$PEMHOME"/shell/z-sh/z.sh

