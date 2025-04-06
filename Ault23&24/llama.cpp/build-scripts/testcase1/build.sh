#!/bin/bash

#SBATCH --job-name=build_llama
#SBATCH --output=build_llama.out
#SBATCH --error=build_llama.err
#SBATCH --time=02:00:00
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=32G
#SBATCH --nodelist=ault23
#SBATCH --gres=gpu:1

# Load required modules
module load cuda/12.1.1 intel-oneapi-mpi/2021.3.0 git/2.10.1 intel-oneapi-mkl/2021.3.0 intel-oneapi-compilers/2021.3.0 
#module try-load OpenBLAS/0.3.5-gompi-system LAPACK/3.8.0-gompi-system

# Set working directory
BUILD_DIR="$SCRATCH/llama-builds/testcase1"
LOG_DIR="$BUILD_DIR/logs"

# Prepare directories
mkdir -p "$LOG_DIR"
cd "$BUILD_DIR" || exit 1

# Clone llama.cpp if not already present
if [ ! -d "$BUILD_DIR/llama.cpp" ]; then
    git clone --recurse-submodules https://github.com/ggml-org/llama.cpp
fi

cd llama.cpp || exit 1

# Configure and build with CUDA + Intel MKL
cmake -B build \
  -DCMAKE_C_COMPILER=icx \
  -DCMAKE_CXX_COMPILER=icpx \
  -DGGML_BLAS=ON \
  -DGGML_BLAS_VENDOR=Intel10_64lp \
  -DGGML_CUDA=ON \
  -DCMAKE_CUDA_ARCHITECTURES="86;89;70" \
  -DGGML_NATIVE=ON \
  -D BLAS_INCLUDE_DIRS=$MKLROOT/include \
  -DCMAKE_EXE_LINKER_FLAGS="-Wl,-rpath,/users/ealnuaim/spack/opt/spack/linux-centos8-zen/gcc-8.4.1/gcc-11.5.0-lubixtieinubtxpukoheitjpnwjwfres/lib64"


cmake --build build --config Release -j4
