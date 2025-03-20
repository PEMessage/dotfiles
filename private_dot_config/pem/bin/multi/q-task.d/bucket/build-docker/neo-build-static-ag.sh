#!/bin/sh

docker build -t ag-builder - <<EOF
# Dockerfile with caching optimizations
FROM alpine:3.18 AS builder

# Install dependencies in a single layer for caching
RUN apk add \
    musl-dev gcc git make autoconf automake
RUN apk add \
    pcre-dev pcre zlib-dev zlib-static xz-dev xz-static

WORKDIR /build

# Clone and build in separate layer to leverage caching
RUN git clone -b master https://github.com/satanson/the_silver_searcher . 
RUN aclocal && autoconf && autoheader && automake --add-missing && \
    CFLAGS='-fPIC -static -flto -O2' ./configure && make

# Final stage for minimal image
FROM alpine:3.18
COPY --from=builder /build/ag /ag
ENTRYPOINT ["/bin/sh", "-c", "cp /ag /w/ag && chown \$UID:\$GID /w/ag && chmod +x /w/ag"]
EOF

# Run the container to copy the binary to host
docker run --rm \
  -e UID="$(id -u)" \
  -e GID="$(id -g)" \
  -v "$PWD":/w \
  ag-builder
