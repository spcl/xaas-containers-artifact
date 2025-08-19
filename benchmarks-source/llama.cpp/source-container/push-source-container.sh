#!/bin/bash

DOCKER_REPOSITORY=${DOCKER_REPOSITORY:-"spcleth/xaas-artifact"}

echo "Creating images in Docker repository: ${DOCKER_REPOSITORY}"

echo "Pushing llama.cpp source container for x86_64"
docker push ${DOCKER_REPOSITORY}/llama.cpp-source-x86_64
echo "Pushing llama.cpp source container for arm64"
docker push ${DOCKER_REPOSITORY}/llama.cpp-source-arm64
