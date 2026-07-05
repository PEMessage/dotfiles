#!/bin/sh

docker build -t tr31-builder - <<EOF
# Dockerfile with caching optimizations
FROM alpine:3.18 AS builder

# Install dependencies in a single layer for caching
RUN apk add \
    musl-dev git make patch bsd-compat-headers
RUN apk add \
    cmake
RUN apk add \
    gcc
RUN apk add \
    g++

WORKDIR /build

# Clone and build in separate layer to leverage caching
RUN git clone --recurse-submodules https://github.com/openemv/tr31.git .
RUN cmake -B out \
    -DFETCH_MBEDTLS=YES \
    -DFETCH_ARGP=YES \
    -DBUILD_SHARED_LIBS=OFF \
    -DCMAKE_EXE_LINKER_FLAGS="-static -flto" \
    -DCMAKE_C_FLAGS="-O2 -flto" && \
    cmake --build out

# Final stage for minimal image
FROM alpine:3.18
COPY --from=builder /build/out/src/tr31-tool /tr31-tool
ENTRYPOINT ["/bin/sh", "-c", "cp /tr31-tool /w/tr31-tool && chown \$UID:\$GID /w/tr31-tool && chmod +x /w/tr31-tool"]
EOF

# Run the container to copy the binary to host
docker run --rm \
  -e UID="$(id -u)" \
  -e GID="$(id -g)" \
  -v "$PWD":/w \
  tr31-builder
