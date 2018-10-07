FROM alpine:latest as git-alpine

RUN apk add git

# Newest UPX not yet in Alpine
RUN apk add xz \
    && wget -qO- https://github.com/upx/upx/releases/download/v3.95/upx-3.95-amd64_linux.tar.xz | tar x -J --strip-components=1 -C /tmp/

# UPX all the libraries and execs except musl and libpcre2-posix
RUN /tmp/upx --brute --best \
    $(realpath \
        /lib/libcrypto.so.43 \
        /lib/libssl.so.45 \
        /usr/lib/libcurl.so.4 \
        /usr/lib/libpcre2-8.so.0 \
        /usr/lib/libnghttp2.so.14 \
        /usr/lib/libssh2.so.1 \
        /usr/libexec/git-core/git \
        /usr/libexec/git-core/git-clone \
        /usr/libexec/git-core/git-remote-http \
        /usr/libexec/git-core/git-remote-https \
    )

######################################################
# BUILD MINIMAL GIT IMAGE
######################################################
FROM alpine:latest
LABEL maintainer="Wilmar den Ouden <info@wilmardenouden.nl>"

ENV PATH=/usr/libexec/git-core/

# Copy libraries to /lib
COPY --from=git-alpine \
    "/lib/ld-musl-x86_64.so.1" \
     /lib/libcrypto.so.43 \
     /lib/libssl.so.45 \
     /lib/

# Copy libraries to /usr/lib
COPY --from=git-alpine \
    /usr/lib/libcurl.so.4 \
    /usr/lib/libpcre2-8.so.0 \
    /usr/lib/libpcre2-posix.so.2 \
    /usr/lib/libnghttp2.so.14 \
    /usr/lib/libssh2.so.1 \
    /usr/lib/

# Copy git executables to /usr/libexec/git-core/
COPY --from=git-alpine \
    /usr/libexec/git-core/git \
    /usr/libexec/git-core/git-clone \
    /usr/libexec/git-core/git-remote-http \
    /usr/libexec/git-core/git-remote-https \
    /usr/libexec/git-core/

# Copy CA certs for HTTPS clone
COPY --from=git-alpine /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt

# Copy git templates dir so it doesn't show a warning
COPY --from=git-alpine /usr/share/git-core/templates /usr/share/git-core/templates