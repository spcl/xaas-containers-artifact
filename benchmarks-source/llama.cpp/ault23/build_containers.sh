#!/bin/bash

DOCKER_REPOSITORY=${DOCKER_REPOSITORY:-"spcleth/xaas-artifact"}

git clone git@github.com:ggml-org/llama.cpp.git
cd llama.cpp && git checkout 307bfa253dea07c9270e78fa53b133504e9c3c9d && cd ..
mv llama.cpp build-scripts/testcase2/

docker build -t ${DOCKER_REPOSITORY}:llamacpp-specialized-ault23 -f build-scripts/testcase2/Dockerfile build-scripts/testcase2
