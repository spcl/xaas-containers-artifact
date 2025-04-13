# Base container with Ubuntu 20.04 and MPICH
FROM ealnuaimi/xaas:ubuntu20.04-mpich3.1.4-v1.1

SHELL ["/bin/bash", "-c"]

# Install essential packages (minimal and fast)
RUN apt update && apt install -y wget gnupg && \
    rm -rf /var/lib/apt/lists/*

# Add ROCm repository and GPG key (using apt-key for ROCm compatibility)
RUN apt update && apt install -y wget gnupg && \
    wget -qO - https://repo.radeon.com/rocm/rocm.gpg.key | apt-key add - && \
    echo "deb [arch=amd64] https://repo.radeon.com/rocm/apt/6.0.3/ ubuntu main" > /etc/apt/sources.list.d/rocm.list && \
    apt update && \
    apt install -y rocm-dev rocblas rocfft rocm-llvm rocprim-dev & \
    rm -rf /var/lib/apt/lists/*

# Copy GROMACS source
COPY gromacs-2025.0 /gromacs-2025.0

# Set working directory
WORKDIR /gromacs-2025.0


# Build GROMACS with HIP and rocFFT
RUN mkdir build && cd build && \
    cmake .. \
        -DCMAKE_BUILD_TYPE=Release \
 -DCMAKE_HIP_COMPILER=/opt/rocm/llvm/bin/amdclang++ \
    -DCMAKE_PREFIX_PATH=/opt/rocm \
        -DGMX_SIMD=AVX2_256 \
        -DGMX_OPENMP=ON \
        -DGMX_MPI=ON \
        -DGMX_GPU=HIP \
        -DGMX_BUILD_OWN_FFTW=ON \
    -DGMX_FFT_LIBRARY=fftw3 \
        -DGMX_GPU_FFT_LIBRARY=rocFFT && \
    make -j$(nproc) && \
    make check && \
    make install && \
    echo "source /usr/local/gromacs/bin/GMXRC" >> ~/.bashrc

# Default command
CMD ["/bin/bash"]