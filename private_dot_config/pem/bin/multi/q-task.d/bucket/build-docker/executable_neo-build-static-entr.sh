#!/bin/sh

docker build -t entr-builder - <<EOF
# Dockerfile with caching optimizations
FROM alpine:3.18 AS builder

# Install dependencies in a single layer for caching
RUN apk add \
    musl-dev gcc make git

WORKDIR /build

# Clone and build in separate layer to leverage caching
RUN git clone https://github.com/eradman/entr.git .
RUN CFLAGS='-O2 -flto' ./configure && \
    make LDFLAGS='-static -flto' test && make LDFLAGS='-static -flto' install

# Final stage for minimal image
FROM alpine:3.18
COPY --from=builder /usr/local/bin/entr /entr
ENTRYPOINT ["/bin/sh", "-c", "cp /entr /w/entr && chown \$UID:\$GID /w/entr && chmod +x /w/entr"]
EOF

# Run the container to copy the binary to host
docker run --rm \
  -e UID="$(id -u)" \
  -e GID="$(id -g)" \
  -v "$PWD":/w \
  entr-builder
