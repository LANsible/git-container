FROM alpine:latest as git-alpine
RUN apk add git
RUN adduser -h /dev/shm -u 10001 -S user

######################################################
# BUILD MINIMAL POWERSHELL IMAGE
######################################################
FROM scratch
LABEL maintainer="Wilmar den Ouden <wilmaro@intermax.nl>"

# Copy git executables
COPY --from=git-alpine /usr/bin/git /usr/bin/

# Copy libraries
COPY --from=git-alpine "/lib/ld-musl-x86_64.so.1" /lib/
COPY --from=git-alpine /lib/libz.so.1 /lib/
COPY --from=git-alpine /usr/lib/libpcre2-8* /usr/lib/

# Copy users from builder
COPY --from=git-alpine /etc/passwd /etc/passwd

USER user
ENTRYPOINT ["/usr/bin/git"]