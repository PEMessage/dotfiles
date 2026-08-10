#!/usr/bin/env bash

set -e
# Get current user info
CURRENT_USER=$(id -un)
CURRENT_GROUP=$(id -gn)
CURRENT_UID=$(id -u)
CURRENT_GID=$(id -g)

# Check if the linux26-builder image exists
if ! docker image inspect linux26-builder-i386 >/dev/null 2>&1; then
    echo "linux26-builder image not found, building it now..."
    docker build -t linux26-builder-i386 --build-arg USERNAME="$CURRENT_USER" \
                                      --build-arg GROUPNAME="$CURRENT_GROUP" \
                                      --build-arg UID="$CURRENT_UID" \
                                      --build-arg GID="$CURRENT_GID" - <<EOF
FROM i386/ubuntu:14.04

RUN sed -i 's@archive.ubuntu.com@mirrors.aliyun.com@g' /etc/apt/sources.list && \
    sed -i 's@security.ubuntu.com@mirrors.aliyun.com@g' /etc/apt/sources.list && \
    sed -i 's/http:/https:/g' /etc/apt/sources.list

RUN apt-get update 
RUN apt-get install -y build-essential
RUN apt-get install -y libncurses5-dev automake pkg-config libevent-dev bear bash sudo wget
RUN apt-get install -y make bin86 gcc-multilib
RUN apt-get install -y install-info

# Thanks to: https://github.com/ultraji/linux-0.12/blob/5202224e0f656cc0ea93b7cd6bf7418298527922/src/code/setup.sh#L31
SHELL ["/bin/bash", "-c"]
RUN set -x && mkdir -p /tmp/gcc-2.95 && \
    cd /tmp/gcc-2.95 && \
    DOWNLOAD_LIST=(\
        "gcc-2.95_2.95.4-24_i386.deb" \
        "cpp-2.95_2.95.4-24_i386.deb" \
        "g++-2.95_2.95.4-24_i386.deb" \
        "libstdc++2.10-glibc2.2_2.95.4-24_i386.deb" \
        "libstdc++2.10-dev_2.95.4-24_i386.deb" \
    ) && \
    for deb in \${DOWNLOAD_LIST[*]}; do \
        wget http://old-releases.ubuntu.com/ubuntu/pool/universe/g/gcc-2.95/\${deb} || \
        { echo "Failed to download \${deb}"; exit 1; }; \
    done && \
    dpkg -i *.deb >/dev/null && \
    apt-get install -y -f >/dev/null && \
    cd / && \
    rm -rf /tmp/gcc-2.95

RUN set -x && mkdir -p /tmp/gcc-3.4 && \
    cd /tmp/gcc-3.4 && \
    DOWNLOAD_LIST=(\
        "gcc-3.4-base_3.4.6-6ubuntu5_i386.deb" \
        "gcc-3.4_3.4.6-6ubuntu5_i386.deb" \
        "g++-3.4_3.4.6-6ubuntu5_i386.deb" \
        "cpp-3.4_3.4.6-6ubuntu5_i386.deb" \
        "libstdc++6-dev_3.4.6-6ubuntu5_i386.deb" \
        "libstdc++6-pic_3.4.6-6ubuntu5_i386.deb" \
    ) && \
    for deb in \${DOWNLOAD_LIST[*]}; do \
        wget http://old-releases.ubuntu.com/ubuntu/pool/universe/g/gcc-3.4/\${deb} || \
        { echo "Failed to download \${deb}"; exit 1; }; \
    done && \
    dpkg -i *.deb >/dev/null && \
    apt-get install -y -f >/dev/null && \
    cd / && \
    rm -rf /tmp/gcc-3.4

# Create user matching host user
ARG USERNAME
ARG GROUPNAME
ARG UID
ARG GID
RUN if [ "\$GID" -ne 0 ]; then groupadd -g \$GID \$GROUPNAME; fi && \
    useradd -m -u \$UID -g \$GID -s /bin/bash \$USERNAME && \
    echo "\$USERNAME ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Setup environment
USER \$USERNAME
WORKDIR /home/\$USERNAME/src
ENV HOME /home/\$USERNAME

CMD ["help"]
EOF
else
    echo "linux26-builder image already exists, skipping build"
fi

set -x
# Run the container
docker run --rm -it \
    -v "$PWD":/home/$CURRENT_USER/src \
    linux26-builder-i386 /bin/bash "$@"
