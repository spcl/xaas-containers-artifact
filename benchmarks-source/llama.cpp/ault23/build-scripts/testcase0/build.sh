#!/bin/bash

#SBATCH --job-name=build_llamma          # Job name
#SBATCH --output=build_llama.out
#SBATCH --error=build_llama.err
#SBATCH --time=04:00:00                # Time limit
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4              # 4 CPU cores
#SBATCH --mem=16G
#SBATCH --nodelist=ault23              # Specific node
#SBATCH --gres=gpu:1                   # Request 1 GPU

# Load modules (not used in this test case but fine to pre-load)
module load cuda/12.1.1 intel-oneapi-mpi/2021.3.0 git/2.10.1 intel-oneapi-mkl/2021.3.0


# Set working directory path
BUILD_DIR="$SCRATCH/llama-builds/testcase0"

# Create build directory
mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR" || exit 1

# Clone llama.cpp into this directory
if [ ! -d "$BUILD_DIR/llama.cpp" ]; then
    git clone https://github.com/ggml-org/llama.cpp
fi

cd llama.cpp || exit 1

# Naive build (CPU only, no tuning)
cmake -B build
cmake --build build --config Release -j 8