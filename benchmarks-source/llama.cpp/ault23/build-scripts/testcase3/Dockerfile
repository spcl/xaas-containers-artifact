FROM ealnuaimi/xaas:ubuntu20.04-mpich3.1.4-v1.1 AS SOURCE

# Use Bash as the default shell for all RUN commands
SHELL ["/bin/bash", "-c"]

# Copy source code and set working directory
COPY llama.cpp /llama.cpp
WORKDIR /llama.cpp

# Add CUDA repository and install CUDA Toolkit
RUN apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/3bf863cc.pub && \
    echo "deb https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/ /" > /etc/apt/sources.list.d/cuda.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends cuda-toolkit-12.1

# Set CUDA environment variables
ENV PATH="/usr/local/cuda-12.1/bin:$PATH"
ENV LD_LIBRARY_PATH="/usr/local/cuda-12.1/lib64:$LD_LIBRARY_PATH"

# NVIDIA runtime environment variables
ENV NVIDIA_VISIBLE_DEVICES=all
ENV NVIDIA_DRIVER_CAPABILITIES=compute,utility
ENV NVIDIA_REQUIRE_CUDA="cuda>=12.1"

# Build llama.cpp with CUDA and OpenMP
# This is the command that is produced by XaaS  
# RUN cmake -B build \
#         -DGGML_USE_CUDA=ON \
#         -DGGML_USE_OPENMP=ON \
#         -DGGML_USE_CUBLAS=ON \
#         -DGGML_CUDA_FORCE_MMQ=ON \
#         -DGGML_CUDA_FORCE_CUBLAS=ON \
#         -DGGML_CUDA_F16=ON \
#         -DGGML_CUDA_PEER_MAX_BATCH_SIZE=128 \
#         -DGGML_BACKEND_DL=OFF \
#         -DCMAKE_CUDA_ARCHITECTURES="70" && \
#     cmake --build build --config Release -j $(nproc)


# This is the edited command (the one that was used to build the image)
# manual edits to standerdize the compilers used + vectorization level 

RUN cmake -B build \
-DGGML_CUDA=ON -DGGML_CUDA_FORCE_CUBLAS=ON \
-DGGML_CUDA_FORCE_MMQ=ON \
-DGGML_CUDA_F16=ON -DGGML_CUDA_PEER_MAX_BATCH_SIZE=256 \
-DGGML_AVX512=ON -DGGML_NATIVE=OFF -DGGML_BACKEND_DL=OFF \
-DCMAKE_CUDA_ARCHITECTURES="86;89;70;75" \
-DCMAKE_C_COMPILER=icx -DCMAKE_CXX_COMPILER=icpx \
cmake --build build --config Release -j$(nproc)


# Default command
CMD ["/bin/bash"]