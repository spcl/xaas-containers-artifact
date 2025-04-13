FROM ealnuaimi/xaas:ubuntu22.04-mpich3.4-arm-gnu13

# Use Bash as the default shell for all RUN commands
SHELL ["/bin/bash", "-c"]

# Add CUDA repository key and install CUDA
RUN apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/sbsa/3bf863cc.pub \
    && echo "deb https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/sbsa/ /" > /etc/apt/sources.list.d/cuda.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        cuda-toolkit-12.4

# Set CUDA environment variables
ENV PATH="/usr/local/cuda-12.4/bin:$PATH"
ENV LD_LIBRARY_PATH="/usr/local/cuda-12.4/lib64:$LD_LIBRARY_PATH"

# NVIDIA runtime environment variables
ENV NVIDIA_VISIBLE_DEVICES all
ENV NVIDIA_DRIVER_CAPABILITIES compute,utility
ENV NVIDIA_REQUIRE_CUDA "cuda>=12.4"

# Install OpenBLAS
RUN apt-get update \
    && apt-get install -y --no-install-recommends libopenblas-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Clone and build llama.cpp with OpenBLAS and CUDA
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        git \
        cmake \
        build-essential \
        pkg-config \
        libcurl4-openssl-dev \
    && git clone https://github.com/ggml-org/llama.cpp \
    && cd llama.cpp \
    && cmake -B build \
        -DGGML_BLAS=ON \
        -DGGML_BLAS_VENDOR=OpenBLAS \
        -DGGML_CUDA=ON \
        -DCMAKE_CUDA_ARCHITECTURES="86;89;70;90" \
        -DGGML_NATIVE=ON \
    && cmake --build build --config Release -j8 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

CMD ["/bin/bash"]
