FROM ealnuaimi/xaas:ubuntu20.04-mpich3.1.4-v1.1

# Use Bash as the default shell for all RUN commands
SHELL ["/bin/bash", "-c"]

# Add CUDA repository key and install CUDA Toolkit
RUN apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/3bf863cc.pub && \
    echo "deb https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/ /" > /etc/apt/sources.list.d/cuda.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends cuda-toolkit-12.1

# Set CUDA environment variables
RUN echo 'export PATH=/usr/local/cuda-12.1/bin${PATH:+:${PATH}}' >> ~/.bashrc && \
    echo 'export LD_LIBRARY_PATH=/usr/local/cuda-12.1/lib64${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}' >> ~/.bashrc && \
    source ~/.bashrc

# NVIDIA runtime environment variables
ENV NVIDIA_VISIBLE_DEVICES=all
ENV NVIDIA_DRIVER_CAPABILITIES=compute,utility
ENV NVIDIA_REQUIRE_CUDA="cuda>=12.1"

# Update and install basic dependencies
RUN apt update && apt install -y gpg-agent wget

# Add Intel oneAPI GPG key and repository
RUN wget -O- https://apt.repos.intel.com/intel-gpg-keys/GPG-PUB-KEY-INTEL-SW-PRODUCTS.PUB | \
    gpg --dearmor | \
    tee /usr/share/keyrings/oneapi-archive-keyring.gpg > /dev/null

RUN echo "deb [signed-by=/usr/share/keyrings/oneapi-archive-keyring.gpg] https://apt.repos.intel.com/oneapi all main" > \
    /etc/apt/sources.list.d/oneAPI.list

# Update package list and install Intel MKL
RUN apt update && \
    apt install -y intel-oneapi-mkl intel-oneapi-mkl-devel

# Source MKL environment variables (note: may not persist across layers)
RUN source /opt/intel/oneapi/mkl/latest/env/vars.sh

# Copy GROMACS source and build
COPY gromacs-2025.0 /gromacs-2025.0
WORKDIR /gromacs-2025.0

RUN mkdir -p build && \
    cd build && \
    cmake .. \
        -DGMX_SIMD=AVX_512 \
        -DGMX_BUILD_OWN_FFTW=ON \
        -DGMX_GPU=CUDA \
        -DGMX_MPI=ON \
        -DGMX_GPU_FFT_LIBRARY=cuFFT \
        -DGMX_OPENMP=ON && \
    make -j$(nproc) && \
    make check && \
    sudo make install && \
    source /usr/local/gromacs/bin/GMXRC && \
    cd ../..

# Default command
CMD ["/bin/bash"]