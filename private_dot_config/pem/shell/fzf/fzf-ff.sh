#e ----------------------------------------- 
# Change working Dir
# dcd: use dirname to change dir
# fcd: use filename to change dir
# fff: fzf ranger like 
# ----------------------------------------- 
    # Implement

    fcd(){
        if [ "$#" -eq 0 ];then
            local path_arg='.'
        else
            local path_arg="$@"
        fi
   
        local temp=`find "$path_arg" -type f | fzf`
        if [ $? != '0' ]; then
            return 
        fi
        cd `echo "$temp" | bcd --print`
    }
    dcd(){
        if [ "$#" -eq 0 ];then
            local path_arg='.'
        else
            local path_arg="$@"
        fi

        local temp=`find "$path_arg" -type d | fzf | bcd --print`  
        if [ $? != '0' ]; then
            return 
        fi
        cd `echo "$temp" | bcd --print`
    }

    f-ranger(){
        local res
        while true
        do
            res=$( find .  -maxdepth 1 | awk 'BEGIN{ print ".." } { print }'|
                fzf --preview 'tree {} -L 2 || cat {} ' --height 90%) 
            if [ "$?" -ne 0 ];then
                return 0
            fi
            cd `echo "$res" | bcd --print`
        done
    }

# ----------------------------------------- 
# fxf: take dir as parameter to search
# ----------------------------------------- 
    fxf(){ 
        # all_name
        if [ "$#" -eq 0 ]; then
            local dir_path='.'
        else
            local dir_path="$1"
        fi
        local cmd="find $1 -type f"
        eval $cmd | fzf --preview 'cat'
      
    }

# ----------------------------------------- 
# ff: other fzf base tools
# ----------------------------------------- 
    ff(){
    # ----------------------------------------- 
    # __fzf_rg
    # ----------------------------------------- 
    __fzf_rg(){
        local rg_res file_name line_num
        if [ -n "$1" ] ; then
            local RG_FILETYPE="-g \*.$1"
            shift
        else 
            local RG_FILETYPE=""
        fi

        rg_res=$(   RG_PREFIX="rg --column --line-number --no-heading --color=always --smart-case "
        INITIAL_QUERY="${*:-}"
        : | fzf --ansi --disabled --query "$INITIAL_QUERY" \
            --bind "change:reload:sleep 0.1; $RG_PREFIX $RG_FILETYPE -- {q} || true" \
            --delimiter : \
            --preview 'batcat --color=always {1} --highlight-line {2}' )
            # --preview-window 'up,60%,border-bottom,+{2}+3/3,~3'  )
                        if [ "$?" -ne 0 ];then
                            return 0
                        fi
                        # echo "$rg_res"
                        file_name=$( echo "$rg_res" | cut -d ':' -f '1' )
                        line_num=$( echo "$rg_res" | cut -d ':' -f '2' )
                        vim "$file_name" +"$line_num"
    }
    # ----------------------------------------- 
    # __fzf_history
    # ----------------------------------------- 

    # ----------------------------------------- 
    # Arguments 
    # ----------------------------------------- 
        if [ "$1" = "apt" ]; then
            apt-cache search '' | sort | cut --delimiter ' ' --fields 1 |
                fzf --multi --cycle --reverse --preview 'apt-cache show {1}' |
                xargs -r sudo apt install -y
        elif [ "$1" = "ps" ]; then
            # 1. ps:   Feed the list of processes to fzf
            # 2. fzf:  Interactively select a process using fuzzy matching algorithm
            # 3. awk:  Take the PID from the selected line
            # 4. kill: Kill the process with the PID
            (date; ps -ef) |
                fzf --bind='ctrl-r:reload(date; ps -ef)' \
                --header=$'Press CTRL-R to reload\n\n' --header-lines=2 \
                --preview='echo {}' --preview-window=down,3,wrap \
                --layout=reverse --height=80% | awk '{print $2}' | xargs kill -9
        elif [ "$1" = "rg" ]; then
            shift
            __fzf_rg $1
        else 
            echo -e '
            ff ps: process show, select and kill 
            ff apt: apt package serach, select and install 
            ff rg: rg search pattern, open in vim

            fxf: find $1(path), search filename, and return filenaem
            fcd: find $1(path), search filename, cd to it
            dcd: find $1(path), search path,cd to it
            '
        fi
    }


