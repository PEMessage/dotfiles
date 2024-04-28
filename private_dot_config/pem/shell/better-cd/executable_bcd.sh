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
    [ -d "$input_base" ] && {
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

wcd () { cd "`wslpath "$1"`"; }
