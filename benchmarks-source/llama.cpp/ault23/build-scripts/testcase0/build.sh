#!/bin/bash

#SBATCH --job-name=build_llama          # Job name
#SBATCH --output=build_llama.out
#SBATCH --error=build_llama.err
#SBATCH --time=04:00:00                # Time limit
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=64              # 4 CPU cores
#SBATCH --mem=16G
#SBATCH --nodelist=ault23              # Specific node
#SBATCH --gres=gpu:1                   # Request 1 GPU

ARTIFACT_LOCATION=${ARTIFACT_LOCATION:-${SCRATCH}/xaas-containers-artifact}

module load cuda/12.1.1 intel-oneapi-mpi/2021.3.0 git/2.10.1 intel-oneapi-mkl/2021.3.0

source ${ARTIFACT_LOCATION}/dependencies/spack/share/spack/setup-env.sh
spack load gcc@11.5 arch=linux-centos8-zen
spack load gcc@11.5 

# Navigate to the build directory
cd ${ARTIFACT_LOCATION}/benchmarks-source/llama.cpp/ault23/build-scripts/testcase0

rm -rf build && mkdir -p build

# Naive build (CPU only, no tuning)
# Source: https://github.com/ggml-org/llama.cpp/blob/master/docs/build.md
cd build && cmake ${ARTIFACT_LOCATION}/data/llama.cpp/llama.cpp
cmake --build . --config Release -j $(nproc)
