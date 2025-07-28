#!/bin/bash

ARTIFACT_LOCATION=${ARTIFACT_LOCATION:-${HOME}/xaas-containers-artifact}
PATCH_FILE="${ARTIFACT_LOCATION}/benchmarks-source/llama.cpp/aurora/build_scripts/naive/llama.cpp.patch"

# load cmake
module load cmake

# Navigate to the build directory
cd ${ARTIFACT_LOCATION}/benchmarks-source/llama.cpp/aurora/build_scripts/naive

git clone git@github.com:ggml-org/llama.cpp.git
git checkout 307bfa253dea07c9270e78fa53b133504e9c3c9d
git apply $PATCH_FILE

mkdir llama.cpp/build
cd llama.cpp/build

cmake .. -DLLAMA_CURL=OFF
cmake --build . --config Release --target llama-bench
