# Function to set up proxy settings

px2dns() {
    # local hostip="$(cat /etc/resolv.conf |grep -oP '(?<=nameserver\ ).*')"
    # change to wsl recommand way, see https://learn.microsoft.com/en-us/windows/wsl/networking
    local hostip="$(ip route show | grep -i default | awk '{ print $3}')"
    __px2_defconfig set $hostip:7890
}

alias px=px2dns

px2() {
    __px2_defconfig set "$1:$2"
}

unpx() {
    __px2_defconfig unset
}


__px2_defconfig() {
    __px2_set_or_unset $1 http_proxy "http://$2"
    __px2_set_or_unset $1 https_proxy "http://$2"
    # you need a mix-port support
    __px2_set_or_unset $1 sock5h_proxy "sock5h://$2"
}

__px2_set_or_unset() {
    cmd="eval"
    if [ "$1" = "set"  ] ; then
        echo "export $2=\"$3\""
        $cmd "export $2=\"$3\""

        echo "export $(echo $2 | tr '[:lower:]' '[:upper:]')=\"$3\""
        $cmd "export $(echo $2 | tr '[:lower:]' '[:upper:]')=\"$3\""

        return
    elif [ "$1" = "unset" ] ; then
        echo "unset $2"
        $cmd "unset $2"

        echo "unset $(echo $2 | tr '[:lower:]' '[:upper:]')"
        $cmd "unset $(echo $2 | tr '[:lower:]' '[:upper:]')"

        return
    fi
}
