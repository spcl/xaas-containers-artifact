#!/bin/bash

# === Step 1: Start interactive session ===
srun --nodelist=ault23 --mem=32G --gres=gpu:1 --time=04:00:00 --pty /bin/bash

# === Step 2: Load required modules ===
module load cuda/12.1.1 intel-oneapi-mpi/2021.3.0 \
            git/2.10.1 intel-oneapi-mkl/2021.3.0 \
            intel-oneapi-compilers/2021.3.0 \
            sarus

# === Step 3: Launch the container ===
sarus run -t \
    --mount=type=bind,source=/usr/lib64/libcuda.so,destination=/usr/lib64/libcuda.so \
    --mount=type=bind,source=/usr/lib64/libcuda.so.1,destination=/usr/lib64/libcuda.so.1 \
    --mount=type=bind,source=/usr/lib64/libcuda.so.570.86.15,destination=/usr/lib64/libcuda.so.570.86.15 \
    --mount=type=bind,source=/usr/lib64/libnvidia-ml.so,destination=/usr/lib64/libnvidia-ml.so \
    --mount=type=bind,source=/usr/lib64/libnvidia-ml.so.1,destination=/usr/lib64/libnvidia-ml.so.1 \
    --mount=type=bind,source=/usr/lib64/libnvidia-ml.so.570.86.15,destination=/usr/lib64/libnvidia-ml.so.570.86.15 \
    --mount=type=bind,source=/usr/bin/nvidia-smi,destination=/usr/bin/nvidia-smi \
    --mount=type=bind,source=/dev/nvidia0,destination=/dev/nvidia0 \
    --mount=type=bind,source=/dev/nvidiactl,destination=/dev/nvidiactl \
    --mount=type=bind,source=/dev/nvidia-uvm,destination=/dev/nvidia-uvm \
    --mount=type=bind,source=/proc/driver/nvidia,destination=/proc/driver/nvidia \
    --mount=type=bind,source="$SCRATCH",destination="/host_home" \
    --mount=type=bind,source=/scratch/ealnuaim/llama-builds/testcase0/llama.cpp/models/13B,destination=/mnt \
    ealnuaimi/llama-cpp-testcase3-ault:latest /bin/bash

# === Inside the container ===

source /opt/intel/oneapi/setvars.sh

# Go to llama.cpp root
cd ../llama.cpp/

# Clean previous builds
rm -rf build

# Reconfigure with portable flags
cmake -B build \
  -DGGML_CUDA=ON \
  -DGGML_CUDA_FORCE_CUBLAS=ON \
  -DGGML_CUDA_FORCE_MMQ=ON \
  -DGGML_CUDA_F16=ON \
  -DGGML_CUDA_PEER_MAX_BATCH_SIZE=256 \
  -DGGML_AVX512=ON \
  -DGGML_NATIVE=OFF \
  -DGGML_BACKEND_DL=OFF \
  -DCMAKE_CUDA_ARCHITECTURES="86;89;70;75" \
  -DCMAKE_C_COMPILER=icx \
  -DCMAKE_CXX_COMPILER=icpx

cmake --build build --config Release -j$(nproc)

# Set up env and run benchmarks
cd build/bin
export OMP_NUM_THREADS=16

# Benchmark: Q4_K_M
CUDA_VISIBLE_DEVICES="0" ./llama-bench \
  -m /mnt/llama-2-13b-chat.Q4_K_M.gguf \
  -pg 512,128 \
  -t $OMP_NUM_THREADS \
  -r 40 \
  -o csv > /host_home/llama-benchmarks/Q4_K_M/testcase3_pg_results.csv

# Benchmark: Q4_0
CUDA_VISIBLE_DEVICES="0" ./llama-bench \
  -m /mnt/llama-2-13b-chat.Q4_0.gguf \
  -pg 512,128 \
  -t $OMP_NUM_THREADS \
  -r 40 \
  -o csv > /host_home/llama-benchmarks/Q4_0/testcase3_pg_results.csv