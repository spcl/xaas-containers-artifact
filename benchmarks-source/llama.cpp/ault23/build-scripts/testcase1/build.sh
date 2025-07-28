#!/bin/bash

#SBATCH --job-name=build_llama_advanced
#SBATCH --output=build_llama_advanced.out
#SBATCH --error=build_llama_advanced.err
#SBATCH --time=02:00:00
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=64
#SBATCH --mem=32G
#SBATCH --nodelist=ault23
#SBATCH --gres=gpu:1

ARTIFACT_LOCATION=${ARTIFACT_LOCATION:-${SCRATCH}/xaas-containers-artifact}

# Load required modules
module load cuda/12.1.1 intel-oneapi-mpi/2021.3.0 git/2.10.1 intel-oneapi-mkl/2021.3.0 intel-oneapi-compilers/2021.3.0 

# Navigate to the build directory
cd ${ARTIFACT_LOCATION}/benchmarks-source/llama.cpp/ault23/build-scripts/testcase1

rm -rf build && mkdir -p build

# Configure and build with CUDA + Intel MKL
cd build && cmake ${ARTIFACT_LOCATION}/data/llama.cpp/llama.cpp \
  -DCMAKE_C_COMPILER=icx \
  -DCMAKE_CXX_COMPILER=icpx \
  -DGGML_BLAS=ON \
  -DGGML_BLAS_VENDOR=Intel10_64lp \
  -DGGML_CUDA=ON \
  -DCMAKE_CUDA_ARCHITECTURES="86;89;70" \
  -DGGML_NATIVE=ON \
  -D BLAS_INCLUDE_DIRS=$MKLROOT/include \
  -DCMAKE_EXE_LINKER_FLAGS="-Wl,-rpath,/users/ealnuaim/spack/opt/spack/linux-centos8-zen/gcc-8.4.1/gcc-11.5.0-lubixtieinubtxpukoheitjpnwjwfres/lib64"

cmake --build . --config Release -j $(nproc)
