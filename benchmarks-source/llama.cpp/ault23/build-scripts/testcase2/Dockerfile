FROM ealnuaimi/xaas:ubuntu20.04-mpich3.1.4-v1.1 AS SOURCE

# Use Bash as the default shell for all RUN commands
SHELL ["/bin/bash", "-c"]

# Copy source and set working directory
COPY llama.cpp /llama.cpp
WORKDIR /llama.cpp

# Add CUDA repository key and install CUDA Toolkit
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

 # Add Intel oneAPI GPG key
RUN wget -O- https://apt.repos.intel.com/intel-gpg-keys/GPG-PUB-KEY-INTEL-SW-PRODUCTS.PUB | gpg --dearmor | tee /usr/share/keyrings/oneapi-archive-keyring.gpg > /dev/null

# Add Intel oneAPI repository
RUN echo "deb [signed-by=/usr/share/keyrings/oneapi-archive-keyring.gpg] https://apt.repos.intel.com/oneapi all main" > /etc/apt/sources.list.d/oneAPI.list

# Update package list again
RUN apt update

# Install Intel MKL
RUN apt install -y intel-oneapi-mkl intel-oneapi-mkl-devel

# mkl has to be sourced to be recognized by gromacs
RUN source /opt/intel/oneapi/mkl/latest/env/vars.sh

RUN cmake -B build \
    -DCMAKE_C_COMPILER=icx \
    -DCMAKE_CXX_COMPILER=icpx \
    -DGGML_BLAS=ON \
    -DGGML_BLAS_VENDOR="Intel10_64lp" \
    -DGGML_CUDA=ON \
    -DCMAKE_CUDA_ARCHITECTURES="86;89;70" \
    -DGGML_NATIVE=OFF \
    -DBLAS_INCLUDE_DIRS="$MKLROOT/include" \
    -DCMAKE_EXE_LINKER_FLAGS="-Wl,-rpath,/usr/lib/gcc/x86_64-linux-gnu/11" && \
    cmake --build build --config Release -j4



# Default command
CMD ["/bin/bash"]