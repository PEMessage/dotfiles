#!/bin/sh

docker build -t kmp-lsp-builder - <<EOF
# Dockerfile with caching optimizations for kmp-lsp
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

# Clone kmp-lsp repository
RUN git clone https://github.com/Hessesian/kmp-lsp.git .

# Build the release binary
RUN . /root/.cargo/env && \
    cargo build --release --target x86_64-unknown-linux-musl --bin kmp-lsp

# Build kmp-jar-indexer sidecar (GraalVM native-image)
FROM ghcr.io/graalvm/graalvm-community:21 AS sidecar

RUN microdnf install -y git && microdnf clean all

WORKDIR /build
RUN git clone https://github.com/Hessesian/kmp-lsp.git .

WORKDIR /build/java-sidecar
RUN ./gradlew nativeCompile

# Final stage for minimal operations
FROM alpine:3.18
COPY --from=builder /build/target/x86_64-unknown-linux-musl/release/kmp-lsp /kmp-lsp
COPY --from=sidecar /build/java-sidecar/build/native/nativeCompile/kmp-jar-indexer /kmp-jar-indexer
ENTRYPOINT ["/bin/sh", "-c", "cp /kmp-lsp /w/kmp-lsp && cp /kmp-jar-indexer /w/kmp-jar-indexer && chown \$UID:\$GID /w/kmp-lsp /w/kmp-jar-indexer && chmod +x /w/kmp-lsp /w/kmp-jar-indexer"]
EOF

# Run the container to copy the binary to host
docker run --rm \
  -e UID="$(id -u)" \
  -e GID="$(id -g)" \
  -v "$PWD":/w \
  kmp-lsp-builder
