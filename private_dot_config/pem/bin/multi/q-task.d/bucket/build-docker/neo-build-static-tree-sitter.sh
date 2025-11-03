#!/bin/sh

docker build -t tree-sitter-builder - <<EOF
# Dockerfile with caching optimizations for tree-sitter CLI
FROM alpine:3.18 AS builder

# Install dependencies in a single layer for caching
RUN apk add --no-cache \
    gcc musl-dev git curl make

# Install Rust in a separate layer
RUN curl https://sh.rustup.rs -sSf | sh -s -- -t x86_64-unknown-linux-musl -y

# Set up environment
ENV PATH="/root/.cargo/bin:\$PATH"
ENV RUSTFLAGS="-C target-feature=+crt-static"

WORKDIR /build

# Clone tree-sitter repository
RUN git clone https://github.com/tree-sitter/tree-sitter.git .

# Checkout specific version (using the version from workspace.package in Cargo.toml)
RUN git checkout v0.25.10

# Build the CLI binary using the workspace configuration
RUN . /root/.cargo/env && \
    cargo build --release --target x86_64-unknown-linux-musl --bin tree-sitter

# Final stage for minimal operations
FROM alpine:3.18
COPY --from=builder /build/target/x86_64-unknown-linux-musl/release/tree-sitter /tree-sitter
ENTRYPOINT ["/bin/sh", "-c", "cp /tree-sitter /w/tree-sitter && chown \$UID:\$GID /w/tree-sitter && chmod +x /w/tree-sitter"]
EOF

# Run the container to copy the binary to host
docker run --rm \
  -e UID="$(id -u)" \
  -e GID="$(id -g)" \
  -v "$PWD":/w \
  tree-sitter-builder
