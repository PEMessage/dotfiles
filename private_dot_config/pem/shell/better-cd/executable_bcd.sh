# For file autocd to it's dir / accept stdin 
bcd()
{
    if [ "$1" = "--print"  ] || 
        [ "$1" = "-p" ] ; then
        local op="echo"
        shift
    else 
        local op="cd"
    fi

    if [ "$#" = 0 ] ; then
        local input="$(</dev/stdin)"
    else 
        local input="$*"
    fi
    [ -d "$input" ] && {
        "$op" "$input"
        return 0 
    }

    local dirname_input="$(dirname "$input")"
    [ -d "$dirname_input" ] && {
        "$op" "$dirname_input"
        return 0
    }
    local env_input="$(eval echo \"\$${input}\")"
    [ -d "$env_input" ] && {
        "$op" "$env_input"
        return 0
    }

    local which_input="$(which "$input")"
    [ "$which_input" ] && {
        "$op" "$(dirname "$which_input")"
        return 0
    }

    return 1
}

wcd(){
    cd "`wslpath "$1"`"
}
gcd(){
    cd "$(git rev-parse --show-toplevel)"
} 

tcd() {
    local target="$1"
    local current_dir="$(pwd)"

    while [ "$current_dir" != "/" ]; do
        if [ -e "$current_dir/$target" ]; then
            cd "$current_dir"
            return 0
        elif [ "$(basename "$current_dir")" = "$target" ] ; then
            cd "$current_dir"
            return 0
        fi
        current_dir="$(dirname "$current_dir")"
    done

    echo "No parent directory containing $target found; staying in $(pwd)."
}

alias rcd='tcd .repo'

scd() {

    local end='\(/\|$\)'
    declare -a pattern_list=(
        "s@/sys$end@/vnd/@g"
        "s@/SYSTEM$end@/VENDOR/@g"
        "s@/vnd$end@/sys/@g"
        "s@/VENDOR$end@/SYSTEM/@g"
        "s@/qssi$end@/target/@g"
        "s@/target$end@/qssi/@g"
        "s@/QSSI14@/TARGET13/@g"
        "s@/TARGET13@/QSSI14/@g"
        "s@userdebug@user@g"
        "s@user@userdebug@g"
        "s@sys@vnd@g"
        "s@vnd@sys@g"
    )
    current_dir="$(readlink -f .)"

    for x in "${pattern_list[@]}"
    do
        post_dir="$(echo "$current_dir" | sed "$x")"
        if [ ! "$post_dir" = "$current_dir" ] && [ -d "$post_dir" ] ; then
            cd "$post_dir"
            return 0
        fi
    done
}

cd() {
    local hnum=16;
    local new_dir index dir cnt;
    if ! [ $# -eq 0 ]; then
        if [[ $# -eq 2 && $1 = "--" ]]; then
            shift;
        else
            if ! {
                [ $# -eq 1 ] && [[ $1 =~ ^(-[0-9]{,2}|-|--|[^-].*)$ ]]
            }; then
                builtin cd "$@";
                return;
            fi;
        fi;
    fi;
    [ "$1" = "--" ] && {
        dirs -v;
        return
    };
    new_dir=${1:-$HOME};
    if [[ "$new_dir" =~ ^-[0-9]{,2}$ ]]; then
        index=${new_dir:1};
        if [ -z "$index" ]; then
            new_dir=$OLDPWD;
        else
            new_dir=$(dirs -l +$index) || return;
        fi;
    fi;
    pushd -- "$new_dir" > /dev/null || return;
    popd -n +$hnum &> /dev/null || true;
    new_dir=$PWD cnt=1;
    while dir=$(dirs -l +$cnt 2> /dev/null); do
        if [ "$dir" = "$new_dir" ]; then
            popd -n +$cnt > /dev/null;
            continue;
        fi;
        let cnt++;
    done
}

cdt() {
    local item="$(dirs -v | fzf)"
    item="${item/# +([0-9])  /}"
    cd "$item"
}
