#!/bin/sh
# Credit: https://gist.github.com/Saoneth/02f08d4714e6fc035e7017c74b3ef29a
docker run -t \
    -e UID="$(id -u)" \
    -e GID="$(id -g)" \
    -v "$PWD":/w \
    -w /tmp \
    --rm \
    alpine \
    sh -c "
    apk add gcc musl-dev git curl &&
    ( curl https://sh.rustup.rs -sSf | sh -s --  -t x86_64-unknown-linux-musl  -y ) &&
    . \"\$HOME/.cargo/env\" && 

    mkdir ast-grep && cd ast-grep &&

    git clone https://github.com/ast-grep/ast-grep.git . -b 0.34.4 &&

    RUSTFLAGS='-C target-feature=+crt-static' cargo build --release --target x86_64-unknown-linux-musl --bin ast-grep

    cd 'target/x86_64-unknown-linux-musl/release'
    chown "$UID:$GID" ast-grep &&
    chmod +x ast-grep &&
    mv ast-grep /w/"
