
px() {
    __px3_smartone --autoipport -a set "$@"
}
unpx() {
    __px3_smartone --autoipport -a unset "$@"
}

px2() {
    local ip="$1"
    local port="$2"
    shift 2
    __px3_smartone -a set -i "$ip" -p "$port" "$@"
}
unpx2() {
    local ip="$1"
    local port="$2"
    shift 2
    __px3_smartone -a unset -i "$ip" -p "$port" "$@"
}


__px3_smartone() {
    local fnd opt narg autoipport
    # Credit: https://github.com/rupa/z/blob/master/z.sh
    while [ "$1" ]; do case "$1" in
        --) while [ "$1" ]; do shift; narg="$narg $1";done;;
        -*)
            opt="$1"
            shift
            case $opt in
                -d|--docker)
                    fnd="$fnd -m systemd -E docker.service,system"
                ;;
                -p|--podman)
                    fnd="$fnd -m systemd -E podman.service,user"
                ;;
                -g|--gradle)
                    echo
                    echo "# px -g >> gradle.properties"
                    echo "# org.gradle.java.home=/usr/lib/jvm/java-1.XX.0-openjdk-amd64/"
                    fnd="$fnd -m gradle"
                ;;
                -n|--npm)
                    fnd="$fnd -m npm"
                ;;
                --autoipport)
                    autoipport=1
                ;;
                *)
                    fnd="$fnd $opt"
                ;;
            esac
        ;;
        *) fnd="$fnd $1" ; shift;;
    esac ; done
    eval set -- "$fnd"


    if [ "$autoipport" = 1 ] ; then
        if [ "$PEM_OS_VARIANT" = wsl2 ]  ||
            uname -a | grep -i wsl2 >/dev/null 2>&1 ; then
            if [ "$(wslinfo  --networking-mode 2>/dev/null)" = mirrored ] ; then
                local hostip="localhost"
            else
                local hostip="$(ip route show | grep -i default | awk '{ print $3}' | head -n1)"
            fi
            __px3_alltype  -i "$hostip" -p "7890" "$@"
        fi
    else
        __px3_alltype "$@"
    fi

}

__px3_callcount=0
__px3_alltype() {
    __px3_callcount=0
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

    # Old bash will not reset this variable, manully reset it
    local OPTIND=1
    local opt=
    local OPTARG=

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
                export PEM_PROXY_ALL
                PEM_PROXY_ALL+="export $key=\"$value\" ; "
                PEM_PROXY_ALL+="export $upper_key=\"$value\" ;"
            else
                echo "unset $key"
                eval "unset $key"
                echo "unset $upper_key"
                eval "unset $upper_key"
                export PEM_PROXY_ALL=""
            fi
            ;;

        gradle)
            (
                override_file="local.properties"
                if [ "$key" = "http_proxy" ]; then
                    inter="http"
                elif [ "$key" = "https_proxy" ]; then
                    inter="https"
                elif [ "$key" = "sock5h_proxy" ]; then
                    inter="sock"
                else
                    echo "Gradle Unknow key" >&2
                    return 1
                fi

                hostkey=systemProp.$inter.proxyHost
                portkey=systemProp.$inter.proxyPort
                # Process shell commands
                if [ "$action" == "set" ]; then
                    echo "$hostkey=$ip"
                    echo "$portkey=$port"
                else
                    true
                fi
            )
            ;;
        npm)
            if [ "$key" = "http_proxy" ]; then
                inner_key="npm_config_proxy"
            elif [ "$key" = "https_proxy" ]; then
                inner_key="npm_config_https_proxy"
            else
                return 1
            fi

            if [ "$action" == "set" ]; then
                echo "export $inner_key=\"$value\""
                eval "export $inner_key=\"$value\""
            else
                echo "unset $inner_key"
                eval "unset $inner_key"
            fi
            ;;

        systemd)
            if [ -z "$ext_arg" ]; then
                echo "Error: -E ext_arg is required for systemd mode" >&2
                return 1
            fi


            (
                service="$(echo $ext_arg | cut -d , -f 1)"
                mode="$(echo $ext_arg | cut -d , -f 2)"
                SUDO=sudo


                if [ "$mode" = system ] ; then
                    override_dir="/run/systemd/system/$service.d"
                    override_file="$override_dir/override.conf"
                    do_init() {
                        echo "# sudo systemctl daemon-reload"
                        echo "# sudo systemctl restart $service"
                        if [[ ! -f "$override_file" ]] ; then
                            $SUDO mkdir -p "$override_dir"
                            # Initialize override file if needed
                            echo '[Service]' | $SUDO tee "$override_file"
                        fi
                    }

                    do_set_action() {
                        echo "$@" | $SUDO tee -a "$override_file"
                    }

                    do_unset_action() {
                        echo "$@"
                        $SUDO "$@"
                    }
                else
                    do_init() {
                        echo "# mkdir -p \$HOME/.config/systemd/user/$service.d"
                        echo "# px -p > \$HOME/.config/systemd/user/$service.d/override.conf"
                        echo "# sudo systemctl daemon-reload"
                        echo "# sudo systemctl restart podman"
                        echo '[Service]'
                    }
                    do_set_action() {
                        echo "$@"
                    }
                    do_unset_action() {
                        echo "Unsupport action"
                    }
                fi


                # Process systemd commands
                if [[ "$action" == "set" ]]; then
                    if [ "$__px3_callcount" = 0 ] ; then
                        do_init
                    fi
                    do_set_action "Environment=\"$key=$value\""
                    do_set_action "Environment=\"$upper_key=$value\""
                else
                    # Remove matching environment variables
                    do_unset_action sed -i "/Environment=\"$key=/d" "$override_file"
                    do_unset_action sed -i "/Environment=\"$upper_key=/d" "$override_file"
                fi
            )
            ;;

        *)
            echo "Unknown mode: $mode" >&2
            return 1
            ;;
    esac
    __px3_callcount=$((__px3_callcount + 1))
}
