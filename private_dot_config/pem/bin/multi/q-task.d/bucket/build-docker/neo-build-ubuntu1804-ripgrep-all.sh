#!/bin/sh

docker build -t ripgrep-all-builder - <<EOF
# Dockerfile with caching optimizations for ripgrep-all
FROM ubuntu:18.04 AS builder

RUN  sed -i s@/archive.ubuntu.com/@/mirrors.aliyun.com/@g /etc/apt/sources.list
RUN  sed -i s@/deb.debian.org/@/mirrors.aliyun.com/@g /etc/apt/sources.list

# Install dependencies in a single layer for caching
RUN apt-get update
RUN apt-get install -y \
    build-essential git curl pkg-config libssl-dev

# Install Rust in a separate layer
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y

# Set up environment
ENV PATH="/root/.cargo/bin:\$PATH"

WORKDIR /build

# Clone ripgrep-all repository
RUN git clone --depth 1 https://github.com/phiresky/ripgrep-all.git .

# Build the release binary
RUN . /root/.cargo/env && \
    cargo build --release

# Final stage for minimal operations
FROM ubuntu:18.04
COPY --from=builder /build/target/release/rga /rga
COPY --from=builder /build/target/release/rga-preproc /rga-preproc
COPY --from=builder /build/target/release/rga-fzf /rga-fzf
COPY --from=builder /build/target/release/rga-fzf-open /rga-fzf-open
ENTRYPOINT ["/bin/bash", "-c", "for f in rga rga-preproc rga-fzf rga-fzf-open; do cp /\$f /w/\$f && chown \$UID:\$GID /w/\$f && chmod +x /w/\$f; done"]
EOF

# Run the container to copy the binary to host
docker run --rm \
  -e UID="$(id -u)" \
  -e GID="$(id -g)" \
  -v "$PWD":/w \
  ripgrep-all-builder
