__ffcd(){
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


ff(){
    if [ "$1" = "apt" ]; then
        apt-cache search '' | sort | cut --delimiter ' ' --fields 1 | fzf --multi --cycle --reverse --preview 'apt-cache show {1}' | xargs -r sudo apt install -y
    fi
    if [ \( "$1" = "cd" \) -o \( "$1" = "fcd" \)  ]; then
        __ffcd "$1" "$2"
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
}


