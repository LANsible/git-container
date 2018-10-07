FROM alpine:latest as git-alpine
RUN apk add git
RUN adduser -h /dev/shm -u 10001 -S user

######################################################
# BUILD MINIMAL POWERSHELL IMAGE
######################################################
FROM scratch

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

# Add label last as it's just metadata and uses a lot of parameters
LABEL maintainer="Wilmar den Ouden <info@wilmardenouden.nl>" \
      readme.md="https://github.com/PowerShell/PowerShell/blob/master/docker/README.md" \
      description="This Dockerfile contains the git binary and needed libraries only." \
      org.label-schema.url="https://github.com/LANsible/git-container/blob/master/README.md" \
      org.label-schema.vcs-url="https://github.com/LANsible/git-container" \
      org.label-schema.name="git" \
      org.label-schema.vendor="LANsible" \
      org.label-schema.vcs-ref=${TRAVIS_COMMIT} \
      org.label-schema.version=${TRAVIS_BRANCH} \
      org.label-schema.schema-version="1.0" \
      org.label-schema.docker.cmd="docker run ${DOCKER_NAMESPACE}/${CONTAINER_NAME} git --version" \