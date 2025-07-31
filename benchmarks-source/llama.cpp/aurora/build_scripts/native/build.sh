#!/bin/bash

ARTIFACT_LOCATION=${ARTIFACT_LOCATION:-${HOME}/xaas-containers-artifact}

# FIXME: replace with oneapi 2025.0 available on Aurora
ONEAPI_PATH=""
PATCH_FILE="${ARTIFACT_LOCATION}/benchmarks-source/llama.cpp/aurora/build_scripts/native/llama.cpp.patch"

# FIXME: replace with oneapi 2025.0 available on Aurora
# The system oneapi will conflict with the proper one api
module unload oneapi

# FIXME: replace with oneapi 2025.0 available on Aurora
# Set the correct oneapi variables
source $ONEAPI_PATH/setvars.sh

# Navigate to the build directory
cd ${ARTIFACT_LOCATION}/benchmarks-source/llama.cpp/aurora/build_scripts/native

git clone git@github.com:ggml-org/llama.cpp.git
git checkout 307bfa253dea07c9270e78fa53b133504e9c3c9d
git apply $PATCH_FILE

mkdir llama.cpp/build
cd llama.cpp/build

#/opt/aurora/24.180.3/spack/unified/0.8.0/install/linux-sles15-x86_64/gcc-12.2.0/cmake-3.27.9-ph5bjg4/bin/cmake .. -DGGML_SYCL=ON -DCMAKE_C_COMPILER=icx -DCMAKE_CXX_COMPILER=icpx -DLLAMA_CURL=OFF
#/opt/aurora/24.180.3/spack/unified/0.8.0/install/linux-sles15-x86_64/gcc-12.2.0/cmake-3.27.9-ph5bjg4/bin/cmake --build . --config Release --target llama-bench
${ARTIFACT_LOCATION}/data/gromacs/cmake/bin/cmake .. -DGGML_SYCL=ON -DCMAKE_C_COMPILER=icx -DCMAKE_CXX_COMPILER=icpx -DLLAMA_CURL=OFF
${ARTIFACT_LOCATION}/data/gromacs/cmake/bin/cmake --build . --config Release --target llama-bench
