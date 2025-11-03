#!/bin/sh

docker build -t tree-sitter-builder - <<EOF
# Dockerfile with caching optimizations for tree-sitter CLI
FROM ubuntu:18.04 AS builder

RUN  sed -i s@/archive.ubuntu.com/@/mirrors.aliyun.com/@g /etc/apt/sources.list
RUN  sed -i s@/deb.debian.org/@/mirrors.aliyun.com/@g /etc/apt/sources.list

# Install dependencies in a single layer for caching
RUN apt-get update
RUN apt-get install -y \
    gcc g++ git curl make pkg-config

# Install Rust in a separate layer
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y

# Set up environment
ENV PATH="/root/.cargo/bin:\$PATH"

WORKDIR /build

# Clone tree-sitter repository
RUN git clone https://github.com/tree-sitter/tree-sitter.git .

# Checkout specific version (using the version from workspace.package in Cargo.toml)
RUN git checkout v0.25.10

# Build the CLI binary using the workspace configuration
RUN . /root/.cargo/env && \
    cargo build --release --bin tree-sitter

# Final stage for minimal operations
FROM ubuntu:18.04
COPY --from=builder /build/target/release/tree-sitter /tree-sitter
ENTRYPOINT ["/bin/bash", "-c", "cp /tree-sitter /w/tree-sitter && chown \$UID:\$GID /w/tree-sitter && chmod +x /w/tree-sitter"]
EOF

# Run the container to copy the binary to host
docker run --rm \
  -e UID="$(id -u)" \
  -e GID="$(id -g)" \
  -v "$PWD":/w \
  tree-sitter-builder
