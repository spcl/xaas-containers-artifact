#!/bin/bash
#SBATCH --job-name=llama_build
#SBATCH --time=00:15:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=72
#SBATCH --account=a-g200
#SBATCH --output=build_llama_advanced.out
#SBATCH --error=build_llama_advanced.err
#SBATCH --uenv=prgenv-gnu/24.11:v1
#SBATCH --view=modules

ARTIFACT_LOCATION=${ARTIFACT_LOCATION:-${SCRATCH}/xaas-containers-artifact}

# Load necessary modules inside the uenv
module load cray-mpich/8.1.30 cuda/12.6.2 cmake/3.30.5 gcc/13.3.0
echo "CC version: " $(cc --version)
echo "mpich version: " $(mpichversion)

# Navigate to the build directory
cd ${ARTIFACT_LOCATION}/benchmarks-source/llama.cpp/clariden/build-scripts/testcase1

rm -rf build && mkdir -p build

# Naive build (CPU only, no tuning)
# Source: https://github.com/ggml-org/llama.cpp/blob/master/docs/build.md
cd build && cmake ${ARTIFACT_LOCATION}/data/llama.cpp/llama.cpp \
	 -DGGML_BLAS=ON \
	 -DGGML_BLAS_VENDOR=OpenBLAS \
	 -DGGML_CUDA=ON \
	 -DCMAKE_CUDA_ARCHITECTURES="86;89;70;90" \
	 -DGGML_NATIVE=ON
cmake --build . --config Release -j $(nproc)
