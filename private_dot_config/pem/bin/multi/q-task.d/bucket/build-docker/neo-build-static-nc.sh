#!/bin/sh

VERSION=0.7.1
docker build -t nc-builder - <<EOF
# Dockerfile with caching optimizations
FROM alpine:3.18 AS builder

# Install dependencies in a single layer for caching
RUN apk add \
    musl-dev gcc make wget

WORKDIR /build

# Clone and build in separate layer to leverage caching
RUN wget --output-document download.tar.gz https://sourceforge.net/projects/netcat/files/netcat/$VERSION/netcat-$VERSION.tar.gz/download
RUN tar -z -xvf download.tar.gz
RUN cd netcat-$VERSION && CFLAGS='-static -flto -O2' LDFLAGS='-static -flto' ./configure && make

# Final stage for minimal image
FROM alpine:3.18
COPY --from=builder /build/netcat-$VERSION/src/netcat /nc
ENTRYPOINT ["/bin/sh", "-c", "cp /nc /w/nc && chown \$UID:\$GID /w/nc && chmod +x /w/nc"]
EOF

# Run the container to copy the binary to host
docker run --rm \
  -e UID="$(id -u)" \
  -e GID="$(id -g)" \
  -v "$PWD":/w \
  nc-builder
