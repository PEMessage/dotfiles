#!/bin/bash

set -e
# Get current user info
CURRENT_USER=$(id -un)
CURRENT_GROUP=$(id -gn)
CURRENT_UID=$(id -u)
CURRENT_GID=$(id -g)

# Check if the linux26-builder image exists
if ! docker image inspect linux26-builder >/dev/null 2>&1; then
    echo "linux26-builder image not found, building it now..."
    docker build -t linux26-builder --build-arg USERNAME="$CURRENT_USER" \
                                      --build-arg GROUPNAME="$CURRENT_GROUP" \
                                      --build-arg UID="$CURRENT_UID" \
                                      --build-arg GID="$CURRENT_GID" - <<EOF
FROM i386/ubuntu:14.04

RUN sed -i 's@archive.ubuntu.com@mirrors.aliyun.com@g' /etc/apt/sources.list && \
    sed -i 's@security.ubuntu.com@mirrors.aliyun.com@g' /etc/apt/sources.list && \
    sed -i 's/http:/https:/g' /etc/apt/sources.list

RUN apt-get update 
RUN apt-get install -y build-essential
RUN apt-get install -y libncurses5-dev automake pkg-config libevent-dev bear bash sudo

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
    linux26-builder /bin/bash
