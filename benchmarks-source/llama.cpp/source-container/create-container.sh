#!/bin/bash

DOCKER_REPOSITORY=${DOCKER_REPOSITORY:-"spcleth/xaas-artifact"}

echo "Using xaas installation in $(which xaas)"
echo "Creating images in Docker repository: ${DOCKER_REPOSITORY}"

echo "Download llama.cpp source code"
if [ ! -d llama.cpp ]; then
  git clone git@github.com:ggml-org/llama.cpp.git
  cd llama.cpp && git checkout 307bfa253dea07c9270e78fa53b133504e9c3c9d && cd ..
fi

echo "Create llama.cpp container for x86_64"
yq ".docker_repository = \"${DOCKER_REPOSITORY}\"" llama_source.yml >llama_source_x86_64.yml
xaas source container llama_source_x86_64.yml

echo "Create llama.cpp container for arm64"
yq ".docker_repository = \"${DOCKER_REPOSITORY}\" | .cpu_architecture = \"arm64\"" llama_source.yml >llama_source_arm64.yml
xaas source container llama_source_arm64.yml
