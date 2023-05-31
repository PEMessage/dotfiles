# ----------------------------------------- 
# Change working Dir
# dcd: use dirname to change dir
# fcd: use filename to change dir
# fff: fzf ranger like 
# ----------------------------------------- 
    # internal use cd
    __fzf_cd(){
        local fd_dir fd_t fd_cmd fzf_opt fzf_res
        # File Or Dir Check
        if [ "$1" = 'fcd' ]; then 
            fd_t=' -type f '
        else 
            fd_t=' -type d '
        fi

        # Path Check
        if [ "$2" = '.' ]; then 
            fd_dir=' . '
        elif [ \( "$2" = '*' \) -o \( -z "$2" \) ]; then
            fd_dir=' * '
        else 
            fd_dir="$2" 
        fi

        # Get FzF result
        fd_cmd='find '"$fd_dir $fd_t"
        fzf_opt="--height ${FZF_TMUX_HEIGHT:-40%} --bind=ctrl-z:ignore --reverse"
        fzf_res=$( eval $fd_cmd 2>/dev/null | eval "fzf $fzf_opt"  )
        # If File , Get dirname
        if [ "$1" = 'fcd' ]; then 
            fzf_res=$(dirname $fzf_res) 
        fi 
        # CD to dir
        cd "$fzf_res"
    }
    
    # Implement
    fcd(){
        __fzf_cd "fcd" "$1"
    }
    alias f-fcd="fcd"
    
    dcd(){
        __fzf_cd "dcd" "$1"
    }
    alias f-dcd="dcd"

    f-ranger(){
        local res
        while [ '1' = '1' ]
        do
            res=$( find .  -maxdepth 1 -type d | awk 'BEGIN{ print ".." } { print }'|
                fzf --preview 'tree -C {} -L 2' --height 70%) 
            if [ "$?" -ne 0 ];then
                return 0
            fi
            cd "$res"
        done
    }

# ----------------------------------------- 
# fxf: take dir as parameter to search
# ----------------------------------------- 
    fpf(){ 
        if [ -z "$1" ]; then
            local temp='.'
        else
            local temp="$1"
        fi

        while [ '1' = '1' ]
        do
            
        done



        local cmd="find $1 -type f"
        eval "$cmd" | fzf --preview 'cat {}' 
    }
    # fxf(){ 
    #     local f_type d_type all_type  all_name dot_name others_name dir_path 
    #     f_type='-type f'
    #     d_type='-type d'
    #     all_type='-type f,d'
    #     all_name
    #     if [ -z "$1" ]; then
    #         local dir_path='.'
    #     else
    #         local dir_path="$1"
    #     fi
    #     local cmd="find $1 -type f"
    #     eval "$cmd" | fzf --preview 'cat {}' 
    # }
    alias f-fxf='fxf'
    fvim(){
        local temp=`fxf $1`
        if [ -z "$temp" ]; then
            return
        else
            vim "$temp"
        fi
    }
# ----------------------------------------- 
# ff: other fzf base tools
# ----------------------------------------- 
    ff(){
        if [ "$1" = "apt" ]; then
            apt-cache search '' | sort | cut --delimiter ' ' --fields 1 | fzf --multi --cycle --reverse --preview 'apt-cache show {1}' | xargs -r sudo apt install -y
        fi
        if [ "$1" = "ps" ]; then
            # 1. ps:   Feed the list of processes to fzf
            # 2. fzf:  Interactively select a process using fuzzy matching algorithm
            # 3. awk:  Take the PID from the selected line
            # 4. kill: Kill the process with the PID
            (date; ps -ef) |
                fzf --bind='ctrl-r:reload(date; ps -ef)' \
                --header=$'Press CTRL-R to reload\n\n' --header-lines=2 \
                --preview='echo {}' --preview-window=down,3,wrap \
                --layout=reverse --height=80% | awk '{print $2}' | xargs kill -9
        fi
        if [ "$1" = "rg" ]; then
            RG_PREFIX="rg --column --line-number --no-heading --color=always --smart-case "
            INITIAL_QUERY="${*:-}"
            : | fzf --ansi --disabled --query "$INITIAL_QUERY" \
                --bind "change:reload:sleep 0.1; $RG_PREFIX {q} || true" \
                --delimiter : \
                --preview 'batcat --color=always {1} --highlight-line {2}' \
                --preview-window 'up,60%,border-bottom,+{2}+3/3,~3' \

        fi
        if [ "$1" = "-h" ]; then
            echo -e '
            ff ps: ps select for ff
            ff apt: apt select for ff

            fxf: find $1(path), search filename, and return filenaem
            fcd: find $1(path), search filename, cd to it
            dcd: find $1(path), search path,cd to it
            f-ranger: ranger-like file manager
            '
        fi
    }


