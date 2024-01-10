export _FASD_BACKENDS="native viminfo"
export _FASD_MAX=6000
eval "$(fasd --init auto)"

dm(){
    local mark_name
    local prompt_message
    local mark_path
    if [ -n "$2" ] ; then
        mark_name="$1"
        mark_path="$2"
        prompt_message="Mark to $mark_name"

    elif [ -n "$1" ] ; then
        mark_name="$1"
        mark_path=`pwd`
        prompt_message="Mark to $mark_name"
    else
        mark_nane='EMPTY'
        mark_path=`pwd`
        prompt_message='Clean the mark'
    fi
    # echo $local_dir
    fasd --mark  "$mark_path" "$mark_name"
    echo "$mark_path -> $prompt_message "
}

cdd(){
    local fnd="$*"
    [ -d "$fnd" ] && cd "$fnd" && return
    [ -n "$fnd" ] &&  fasd_cd -d "$fnd" && return
    local temp=` fasd -sd 2>&1 | sort -rn |
        awk '{ print substr($0, index($0,$2)) }' |
        fzf  --no-sort --query="$fnd" 
        `
    cd "$temp"
}

cdt(){
    local fnd="$*"
    [ -d "$fnd" ] && cd "$fnd" && return
    [ -n "$fnd" ] &&  fasd_cd -d "$fnd" && return
    local temp=` fasd -sdt 2>&1 | sort -rn |
        awk '{ print substr($0, index($0,$2)) }' |
        fzf  --no-sort --query="$fnd" 
        `
    cd "$temp"
}

cdm() {
    local data="$(cat ~/.cache/fasd/data.txt | awk -F"|" '$4 != "" { print $0 } ')"
    local path="$(echo "$data" |
        awk -F"|" '{printf "%-10s %s\n",$4,$1}' |
        fzf | 
        awk '{ print substr($0, index($0,$2)) }'
        )"
    [ -f "$path" ] && cd "$(dirname "$path")" && return
    [ -d "$path" ] && cd "$path" && return
}

vf(){
    fasd -fi "$*" -e vim && return
}
