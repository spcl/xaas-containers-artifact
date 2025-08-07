#!/bin/bash

ARTIFACT_LOCATION=${ARTIFACT_LOCATION:-${HOME}/xaas-containers-artifact}
PATCH_FILE="${ARTIFACT_LOCATION}/benchmarks-source/llama.cpp/aurora/build_scripts/native/llama.cpp.patch"

# load cmake
module load cmake

# Navigate to the build directory
cd ${ARTIFACT_LOCATION}/benchmarks-source/llama.cpp/aurora/build_scripts/native

git clone git@github.com:ggml-org/llama.cpp.git
cd llama.cpp
git checkout 307bfa253dea07c9270e78fa53b133504e9c3c9d
git apply $PATCH_FILE

mkdir build
cd build

cmake .. -DGGML_SYCL=ON -DCMAKE_C_COMPILER=icx -DCMAKE_CXX_COMPILER=icpx -DLLAMA_CURL=OFF
cmake --build . --config Release --target llama-bench
