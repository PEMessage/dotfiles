
px() {
    __px3_smartone -a set "$@"
}
unpx() {
    __px3_smartone -a unset "$@"
}

__px3_smartone() {
    local fnd opt narg
    # Credit: https://github.com/rupa/z/blob/master/z.sh
    while [ "$1" ]; do case "$1" in
        --) while [ "$1" ]; do shift; narg="$narg $1";done;;
        -*) 
            opt="$1"
            shift 
            case $opt in
                -d|--docker)
                    fnd="$fnd -m systemd -E docker.service"
                ;;
                *)
                    fnd="$fnd $opt"
                ;;
            esac
        ;;
        *) fnd="$fnd $1" ; shift;;
    esac ; done
    eval set -- "$fnd"

    

    if [ "$PEM_OS_VARIANT" = wsl2 ] ||
        uname -a | grep -i wsl2 >/dev/null 2>&1 ; then 
        local hostip="$(ip route show | grep -i default | awk '{ print $3}')"
        __px3_alltype  -i "$hostip" -p "7890" "$@"
    fi

}



px2() {
    local ip="$1"
    local port="$2"
    shift 2
    __px3_alltype -a set -i "$ip" -p "$port" "$@"
}
unpx2() {
    local ip="$1"
    local port="$2"
    shift 2
    __px3_alltype -a unset -i "$ip" -p "$port" "$@"
}



__px3_alltype() {
    __px3 -k http_proxy -u "http://" "$@"
    __px3 -k https_proxy -u "http://" "$@"
    # you need a mix-port support
    __px3 -k sock5h_proxy -u "sock5h://" "$@"
}
__px3()
{
    local mode="shell"
    local action=
    local key=
    local upper_key=
    local value=
    local ext_arg=
    local ip=
    local url_prefix=

    # Option parsing
    while getopts "m:a:k:i:p:x:u:v:E:i:" opt; do
        case $opt in
            m) mode="$OPTARG" ;;
            a) action="$OPTARG" ;;
            k)
                key="$OPTARG" 
                upper_key=$(echo "$key" | tr '[:lower:]' '[:upper:]' )
                ;;
            i) ip="$OPTARG" ;;
            p) port="$OPTARG" ;;
            x) ip_port="$OPTARG";;
            u) url_prefix="$OPTARG" ;;
            v) value="$OPTARG" ;;
            E) ext_arg="$OPTARG" ;;  # Extra argument for systemd mode
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

    

    if [ -n "$ip" ] &&  [ -n "$port" ] ; then
        ip_port="$ip:$port"
    fi
    if [ -n "$url_prefix" ] && [ -n "$ip_port" ] ; then
        value="$url_prefix$ip_port"
    fi

    if [ "$action" = set ] && (  [ -z "$key" ] || [ -z "$value" ] ) ; then
        echo "empty key(-k) or value(-v) pair"
        return 1
    elif [ "$action" = unset ] && [ -z "$key" ] ; then
        echo "empty key(-k)"
        return 1
    fi

    case "$mode" in
        shell)
            # Process shell commands
            if [ "$action" == "set" ]; then
                echo "export $key=\"$value\""
                eval "export $key=\"$value\""
                echo "export $upper_key=\"$value\""
                eval "export $upper_key=\"$value\""
            else
                echo "unset $key"
                eval "unset $key"
                echo "unset $upper_key"
                eval "unset $upper_key"
            fi
            ;;

        systemd)
            if [ -z "$ext_arg" ]; then
                echo "Error: -E ext_arg is required for systemd mode" >&2
                return 1
            fi

            (
                override_dir="/run/systemd/system/$ext_arg.d"
                override_file="$override_dir/override.conf"

                # Initialize override file if needed
                if [[ ! -f "$override_file" ]]; then
                    sudo mkdir -p "$override_dir"
                    echo '[Service]' | sudo tee "$override_file" >/dev/null
                fi

                # Process systemd commands
                if [[ "$action" == "set" ]]; then
                    echo "Environment=\"$key=$value\"" | sudo tee -a "$override_file" 
                    echo "Environment=\"$upper_key=$value\"" | sudo tee -a "$override_file"
                else
                    # Remove matching environment variables
                    echo sed -i "/Environment=\"$key=/d" "$override_file"
                    echo sed -i "/Environment=\"$upper_key=/d" "$override_file"
                    sudo sed -i "/Environment=\"$key=/d" "$override_file"
                    sudo sed -i "/Environment=\"$upper_key=/d" "$override_file"
                fi
            )
            ;;

        *)
            echo "Unknown mode: $mode" >&2
            return 1
            ;;
    esac
}
