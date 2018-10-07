#!/bin/bash
echo "Pushing ${DOCKER_NAMESPACE}/${CONTAINER_NAME}:${ANSIBLE_VERSION}"
echo "${DOCKER_PASSWORD}" | docker login -u "${DOCKER_USERNAME}" --password-stdin
docker push ${DOCKER_NAMESPACE}/${CONTAINER_NAME}