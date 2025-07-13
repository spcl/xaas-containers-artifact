## Model Installation

Before running the benchmarks, you need to download the LLaMA 2 models from Hugging Face and place them in the following directory:

You can download the required model files from the links below:

- [llama-2-13b-chat.Q4_K_M.gguf](https://huggingface.co/TheBloke/Llama-2-13B-chat-GGUF/blob/main/llama-2-13b-chat.Q4_K_M.gguf)
- [llama-2-13b-chat.Q4_0.gguf](https://huggingface.co/TheBloke/Llama-2-13B-chat-GGUF/blob/main/llama-2-13b-chat.Q4_0.gguf)

You need to create the `models/13B/` directory manually if it doesn't exist.




## Test Cases

This repository contains four benchmark test cases:

- **Test Case 0 (naive)**: CPU-only build.
- **Test Case 1 (expert)**: Host build with OpenBLAS and CUDA.
- **Test Case 2 (containerized expert)**: Same as Test Case 1 but built inside a container.
- **Test Case 3 (XaaS)**: CUDA backend with cuBLAS and fine-tuning options.

### Test Case 0: Naive CPU-only Build

```bash
cmake -B build && cmake --build build --config Release -j 8
```

### Test Case 1: Expert Build on Host (OpenBLAS + CUDA)

```bash
cmake -B build \
 -DGGML_BLAS=ON \
 -DGGML_BLAS_VENDOR=OpenBLAS \
 -DGGML_CUDA=ON \
 -DCMAKE_CUDA_ARCHITECTURES="86;89;70;90" \
 -DGGML_NATIVE=ON \
 && cmake --build build --config Release -j8
```

### Test Case 2: Expert Build in Container

> Same as Test Case 1.

```bash
cmake -B build \
 -DGGML_BLAS=ON \
 -DGGML_BLAS_VENDOR=OpenBLAS \
 -DGGML_CUDA=ON \
 -DCMAKE_CUDA_ARCHITECTURES="86;89;70;90" \
 -DGGML_NATIVE=ON \
 && cmake --build build --config Release -j8
```

### Test Case 3: XaaS - CUDA + cuBLAS + Fine-tuning

```bash
cmake -B build \
 -DGGML_CUDA=ON \
 -DGGML_CUDA_FORCE_CUBLAS=ON \
 -DGGML_CUDA_FORCE_MMQ=ON \
 -DGGML_CUDA_F16=ON \
 -DGGML_CUDA_PEER_MAX_BATCH_SIZE=256 \
 -DGGML_NATIVE=ON \
 -DGGML_BACKEND_DL=OFF \
 -DCMAKE_CUDA_ARCHITECTURES="86;89;70;75;90"

cmake --build build --config Release -j$(nproc)
```