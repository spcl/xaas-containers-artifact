#!/bin/bash

DOCKER_REPOSITORY=${DOCKER_REPOSITORY:-"spcleth/xaas-artifact"}

echo "Creating images in Docker repository: ${DOCKER_REPOSITORY}"

name="${DOCKER_REPOSITORY}:llama.cpp-source-deploy-ault23"
if docker image inspect ${name} >/dev/null 2>&1; then
  echo "Pushing llama.cpp container for Ault23"
  docker push ${name}
fi

name="${DOCKER_REPOSITORY}:llama.cpp-source-deploy-aurora"
if docker image inspect ${name} >/dev/null 2>&1; then
  echo "Pushing llama.cpp container for Aurora"
  docker push ${name}
fi

name="${DOCKER_REPOSITORY}:llama.cpp-source-deploy-clariden"
if docker image inspect ${name} >/dev/null 2>&1; then
  echo "Pushing llama.cpp container for Clariden"
  docker push ${name}
fi
