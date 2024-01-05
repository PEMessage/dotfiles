
PREV_hostip=
PREV_https_proxy=
PREV_http_proxy=

px() {
    PREV_hostip="$hostip"
    PREV_https_proxy="$https_proxy"
    PREV_http_proxy="$http_proxy"

    export hostip=$(cat /etc/resolv.conf |grep -oP '(?<=nameserver\ ).*')
    export https_proxy="http://${hostip}:7890"
    export http_proxy="http://${hostip}:7890"

    echo export hostip=$(cat /etc/resolv.conf |grep -oP '(?<=nameserver\ ).*')
    echo export https_proxy="http://${hostip}:7890"
    echo export http_proxy="http://${hostip}:7890"
}

unpx() {
    echo export hostip="$PREV_hostip"
    echo export https_proxy="$PREV_https_proxy"
    echo export http_proxy="$PREV_http_proxy"
}
