#!/bin/bash

ARTIFACT_LOCATION=${ARTIFACT_LOCATION:-${HOME}/xaas-containers-artifact}

# FIXME: replace with oneapi 2025.0 available on Aurora
ONEAPI_PATH=""
PATCH_FILE="${ARTIFACT_LOCATION}/benchmarks-source/llama.cpp/aurora/build_scripts/naive/llama.cpp.patch"

# FIXME: replace with oneapi 2025.0 available on Aurora
# The system oneapi will conflict with the proper one api
module unload oneapi

# FIXME: replace with oneapi 2025.0 available on Aurora
# Set the correct oneapi variables
source $ONEAPI_PATH/setvars.sh

# Navigate to the build directory
cd ${ARTIFACT_LOCATION}/benchmarks-source/llama.cpp/aurora/build_scripts/naive

git clone git@github.com:ggml-org/llama.cpp.git
git checkout 307bfa253dea07c9270e78fa53b133504e9c3c9d
git apply $PATCH_FILE

mkdir llama.cpp/build
cd llama.cpp/build

${ARTIFACT_LOCATION}/data/gromacs/cmake/bin/cmake ..
${ARTIFACT_LOCATION}/data/gromacs/cmake/bin/cmake --build . --config Release --target llama-bench
