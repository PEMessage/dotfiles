#!/bin/sh

REPO="https://github.com/openemv/tr31.git"
IMAGE="tr31-builder"
case "$1" in
  --fork|-f)
    REPO="https://github.com/PEMessage/tr31.git"
    IMAGE="tr31-fork-builder"
    ;;
esac

docker build -t "$IMAGE" - <<EOF
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
RUN git clone --recurse-submodules $REPO .
RUN cmake -B out \
    -DFETCH_MBEDTLS=YES \
    -DFETCH_ARGP=YES \
    -DBUILD_SHARED_LIBS=OFF \
    -DCMAKE_EXE_LINKER_FLAGS="-static -flto" \
    -DCMAKE_C_FLAGS="-O2 -flto" && \
    cmake --build out

# Collect ELF files from out/src (non-recursive) in a separate layer
RUN mkdir -p /out-elf && \
    for f in /build/out/src/*; do \
        if [ -f "\$f" ] && head -c 4 "\$f" | grep -q "ELF"; then cp "\$f" /out-elf/; fi; \
    done; \
    ls -l /out-elf/

# Final stage for minimal image
FROM alpine:3.18
COPY --from=builder /out-elf/ /out-elf/
ENTRYPOINT ["/bin/sh", "-c", "for f in /out-elf/*; do n=\$(basename \$f); cp \$f /w/\$n && chown \$UID:\$GID /w/\$n && chmod +x /w/\$n; done"]
EOF

# Run the container to copy the binary to host
docker run --rm \
  -e UID="$(id -u)" \
  -e GID="$(id -g)" \
  -v "$PWD":/w \
  "$IMAGE"
