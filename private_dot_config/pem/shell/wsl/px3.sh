
__px3_defptcl() {
    local action="$1"
    local ip="$2"
    shift 2
    __px3 -a $1 -k http_proxy -v "http://$2" "$@"
    __px3 -a $1 -k https_proxy -v "http://$2" "$@"
    # you need a mix-port support
    __px3 -a $1 -k sock5h_proxy -v "sock5h://$2" "$@"
}
__px3()
{
    local mode="shell"
    local action=
    local key=
    local upper_key=
    local value=
    local service=

    # Option parsing
    while getopts ":m:a:k:v:E:" opt; do
        case $opt in
            m) mode="$OPTARG" ;;
            a) action="$OPTARG" ;;
            k)
                key="$OPTARG" 
                upper_key=$(echo key | tr '[:lower:]' '[:upper:]' )
                ;;
            v) value="$OPTARG" ;;
            E) service="$OPTARG" ;;  # Extra argument for systemd mode
            \?) echo "Invalid option -$OPTARG" >&2; return 1 ;;
            :) echo "Option -$OPTARG requires an argument." >&2; return 1 ;;
        esac
    done
    shift $((OPTIND - 1))

    # Validation
    case "$action" in
        set|unset) ;;
        *) echo "Invalid action: $action. Must be 'set' or 'unset'." >&2; return 1 ;;
    esac
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
            if [ -z "$service" ]; then
                echo "Error: -E SERVICE is required for systemd mode" >&2
                return 1
            fi

            (
                set -x
                override_dir="/run/systemd/system/$service.d"
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
