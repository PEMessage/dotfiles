


# See: https://docs.docker.com/engine/install/linux-postinstall/

prompt_for_command() {
    while true; do
        echo "Are you sure to run this: '$*' ?"
        read -p "pls input (y) to continue: " input
        if [ "$input" = "y" ]; then
            break
        fi
    done
}
GROUP_NAME=docker
if [ ! "$(getent group "$GROUP_NAME")" ]  ; then
    prompt_for_command 'sudo groupadd docker'
    sudo groupadd docker
else
    echo "[Info]: already exist docker group"
fi

if [ ! "$(id -nG | grep docker)" ]  ; then
    prompt_for_command "sudo usermod -aG docker $USER"
    sudo usermod -aG docker $USER
else
    echo "[Info]: '$USER' already in docker group"
fi
