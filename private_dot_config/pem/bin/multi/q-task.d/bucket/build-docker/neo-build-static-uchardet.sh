#!/bin/sh

docker build -t chardet-builder - <<EOF
# Dockerfile with caching optimizations
FROM alpine:3.18 AS builder

# Install dependencies in a single layer for caching
RUN apk add \
    musl-dev git make
RUN apk add \
    cmake
RUN apk add \
    g++
RUN apk add \
    gcc

WORKDIR /build

# Clone and build in separate layer to leverage caching
RUN git clone https://gitlab.freedesktop.org/uchardet/uchardet.git .
RUN cmake -B out \
    -DBUILD_STATIC=ON \
    -DCMAKE_EXE_LINKER_FLAGS="-static -flto" \
    -DCMAKE_CXX_FLAGS="-O2 -flto" \
    -DCMAKE_C_FLAGS="-O2 -flto" \
    -DBUILD_SHARED_LIBS=OFF && \
    cmake --build out

# Final stage for minimal image
FROM alpine:3.18
COPY --from=builder /build/out/src/tools/uchardet /uchardet
ENTRYPOINT ["/bin/sh", "-c", "cp /uchardet /w/uchardet && chown \$UID:\$GID /w/uchardet && chmod +x /w/uchardet"]
EOF

# Run the container to copy the binary to host
docker run --rm \
  -e UID="$(id -u)" \
  -e GID="$(id -g)" \
  -v "$PWD":/w \
  chardet-builder
