#!/bin/sh

podman build -t herdr-builder - <<EOF
# Dockerfile with caching optimizations for herdr
FROM ubuntu:22.04 AS builder

RUN  sed -i s@/archive.ubuntu.com/@/mirrors.aliyun.com/@g /etc/apt/sources.list
RUN  sed -i s@/security.ubuntu.com/@/mirrors.aliyun.com/@g /etc/apt/sources.list

# Install dependencies in a single layer for caching
RUN apt-get update
RUN apt-get install -y \
    gcc g++ git curl make cmake ninja-build pkg-config xz-utils
RUN apt-get install -y \
    musl-tools

# Install Rust in a separate layer
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y --default-toolchain 1.96.1
RUN . /root/.cargo/env && \
    rustup target add x86_64-unknown-linux-musl

# Install Zig in a separate layer
RUN curl -L https://ziglang.org/download/0.15.2/zig-x86_64-linux-0.15.2.tar.xz -o /tmp/zig.tar.xz && \
    tar -C /usr/local -xJf /tmp/zig.tar.xz && \
    ln -s /usr/local/zig-x86_64-linux-0.15.2/zig /usr/local/bin/zig

# Set up environment
ENV PATH="/root/.cargo/bin:\$PATH"
ENV LIBGHOSTTY_VT_OPTIMIZE=ReleaseFast
ENV LIBGHOSTTY_VT_SIMD=true

WORKDIR /build

# Clone herdr repository from master branch
RUN git clone https://github.com/herdrdev/herdr.git . --depth 1 --branch master

# Remove zig caches to keep the build reproducible
RUN rm -rf .zig-cache vendor/libghostty-vt/.zig-cache vendor/libghostty-vt/zig-out

# Build the release binary
RUN . /root/.cargo/env && \
    cargo build --release --locked --target x86_64-unknown-linux-musl

# Final stage for minimal operations
FROM ubuntu:22.04
COPY --from=builder /build/target/x86_64-unknown-linux-musl/release/herdr /herdr
ENTRYPOINT ["/bin/sh", "-c", "cp /herdr /w/herdr && chown \$UID:\$GID /w/herdr && chmod +x /w/herdr"]
EOF

# Run the container to copy the binary to host
podman run --rm \
  -e UID="$(id -u)" \
  -e GID="$(id -g)" \
  -v "$PWD":/w \
  herdr-builder
