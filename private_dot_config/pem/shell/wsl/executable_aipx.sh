

__env_toggle() {
    # Old bash will not reset this variable, manully reset it
    local OPTIND=1
    local opt=
    local OPTARG=

    while getopts "a:k:v:" opt; do
        case $opt in
            a) action="$OPTARG" ;;
            k)
                key="$OPTARG"
                upper_key=$(echo "$key" | tr '[:lower:]' '[:upper:]' )
                ;;
            v) value="$OPTARG" ;;
            # \?) echo "Invalid option -$OPTARG" >&2; return 1 ;;
            # :) echo "Option -$OPTARG requires an argument." >&2; return 1 ;;
        esac
    done
    shift $((OPTIND - 1))


    # Validation
    case "$action" in
        set|unset) ;;
        *) echo "Invalid action: $action. Must be 'set' or 'unset'." >&2; return 1 ;;
    esac

    if [ "$action" = set ] && (  [ -z "$key" ] || [ -z "$value" ] ) ; then
        echo "empty key(-k) or value(-v) pair, $key, $value"
        return 1
    elif [ "$action" = unset ] && [ -z "$key" ] ; then
        echo "empty key(-k)"
        return 1
    fi


    if [ "$action" = "set" ]; then
        echo "export $key=\"$value\""
        eval "export $key=\"$value\""
    else
        echo "unset $key"
        eval "unset $key"
    fi
}


__aipx_alltype() {

    __env_toggle -a "$1" -k OPENAI_API_BASE -v "$2"
    if [ -n "$3" ] || [ "$1" = "unset" ] ; then
        __env_toggle -a "$1" -k OPENAI_API_KEY -v "$3"
    fi
}


aipx() {
    if [ "$1" = ollama ] ; then
        shift
        # detect host
        if [ "$1" ]; then
            local hostip="$1"
        elif [ "$PEM_OS_VARIANT" = wsl2 ] ; then
            if [ "$(wslinfo  --networking-mode 2>/dev/null)" = mirrored ] ; then
                local hostip="localhost"
            else
                local hostip="$(ip route show | grep -i default | awk '{ print $3}' | head -n1)"
            fi
        else
            local hostip="localhost"
        fi
        __aipx_alltype "set" "http://$hostip:11434/v1"
    else
        __aipx_alltype "set" "$@"
    fi
}

unaipx() {
    __aipx_alltype "unset" "$@"
}

