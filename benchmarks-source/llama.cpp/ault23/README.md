## Model Installation

Before running the benchmarks, you need to download the LLaMA 2 models from Hugging Face and place them in the following directory:

You can download the required model files from the links below:

- [llama-2-13b-chat.Q4_K_M.gguf](https://huggingface.co/TheBloke/Llama-2-13B-chat-GGUF/blob/main/llama-2-13b-chat.Q4_K_M.gguf)
- [llama-2-13b-chat.Q4_0.gguf](https://huggingface.co/TheBloke/Llama-2-13B-chat-GGUF/blob/main/llama-2-13b-chat.Q4_0.gguf)

You need to create the `models/13B/` directory manually if it doesn't exist.




## Test Cases

This repository contains four benchmark test cases:

- **Test Case 0 (naive)**: CPU-only build.
- **Test Case 1 (specialized)**: Host build with Intel MKL Blas and CUDA.
- **Test Case 2 (containerized specialized)**: Same as Test Case 1 but built inside a container.
- **Test Case 3 (XaaS)**: CUDA backend with cuBLAS and fine-tuning options.

### Test Case 0: Naive CPU-only Build

```bash
cmake -B build && cmake --build build --config Release -j 8
```

### Test Case 1: Specialized Build on Host (Intel MKL + CUDA)

```bash
cmake -B build \
 -DCMAKE_C_COMPILER=icx \
 -DCMAKE_CXX_COMPILER=icpx \
 -DGGML_BLAS=ON \
 -DGGML_BLAS_VENDOR=Intel10_64lp \
 -DGGML_CUDA=ON \
 -DCMAKE_CUDA_ARCHITECTURES="86;89;70" \
 -DGGML_NATIVE=ON \
 -DBLAS_INCLUDE_DIRS=$MKLROOT/include \
 -DCMAKE_EXE_LINKER_FLAGS="-Wl,-rpath,/users/ealnuaim/spack/opt/spack/linux-centos8-zen/gcc-8.4.1/gcc-11.5.0-lubixtieinubtxpukoheitjpnwjwfres/lib64"

cmake --build build --config Release -j4
```

### Test Case 2: Specialized Build in Container

> Before building, make sure to source the Intel compilers:
>
> ```bash
> source /opt/intel/oneapi/setvars.sh
> ```

```bash
cmake -B build \
 -DCMAKE_C_COMPILER=icx \
 -DCMAKE_CXX_COMPILER=icpx \
 -DGGML_BLAS=ON \
 -DGGML_BLAS_VENDOR=Intel10_64lp \
 -DGGML_CUDA=ON \
 -DCMAKE_CUDA_ARCHITECTURES="86;89;70" \
 -DGGML_NATIVE=OFF \
 -DBLAS_INCLUDE_DIRS=$MKLROOT/include \
 -DCMAKE_EXE_LINKER_FLAGS="-Wl,-rpath,/usr/lib/gcc/x86_64-linux-gnu/11"

cmake --build build --config Release -j4
```

### Test Case 3: XaaS - CUDA + cuBLAS + Fine-tuning

```bash
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
```