FROM docker.io/spcleth/xaas:source-base-arm-24.04

RUN wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2404/sbsa/cuda-keyring_1.1-1_all.deb && \
    dpkg -i cuda-keyring_1.1-1_all.deb && \
    apt-get update && \
    apt-get install -y --no-install-recommends cuda-toolkit-12.6

ENV PATH="/usr/local/cuda-12.6/bin:$PATH"
ENV LD_LIBRARY_PATH="/usr/local/cuda-12.6/lib64:$LD_LIBRARY_PATH"

# NVIDIA runtime environment variables
ENV NVIDIA_VISIBLE_DEVICES all
ENV NVIDIA_DRIVER_CAPABILITIES compute,utility
ENV NVIDIA_REQUIRE_CUDA "cuda>=12.4"

# Install OpenBLAS
RUN apt-get update \
    && apt-get install -y --no-install-recommends libopenblas-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

ADD llama.cpp /llama.cpp

RUN cd /llama.cpp && cmake -B build \
        -DGGML_BLAS=ON \
        -DGGML_BLAS_VENDOR=OpenBLAS \
        -DGGML_CUDA=ON \
        -DCMAKE_CUDA_ARCHITECTURES="86;89;70;90" \
        -DGGML_NATIVE=ON \
        -DLLAMA_CURL=OFF \
    && cmake --build build --config Release -j8 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

CMD ["/bin/bash"]
