# Use the specified base image
FROM ealnuaimi/xaas:ubuntu20.04-mpich3.1.4-v1.1

# Use bash shell
SHELL ["/bin/bash", "-c"]

# Add CUDA repository key and install CUDA toolkit
RUN apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/3bf863cc.pub \
    && echo "deb https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/ /" > /etc/apt/sources.list.d/cuda.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
       cuda-toolkit-12-1 \
    && rm -rf /var/lib/apt/lists/*

# Set CUDA environment variables
ENV PATH=/usr/local/cuda-12.1/bin${PATH:+:${PATH}}
ENV LD_LIBRARY_PATH=/usr/local/cuda-12.1/lib64\${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}

# NVIDIA runtime environment variables
ENV NVIDIA_VISIBLE_DEVICES all
ENV NVIDIA_DRIVER_CAPABILITIES compute,utility
ENV NVIDIA_REQUIRE_CUDA "cuda>=12.1"


# Download and extract GROMACS source
RUN wget https://ftp.gromacs.org/gromacs/gromacs-2025.0.tar.gz \
    && tar -xvzf gromacs-2025.0.tar.gz \
    && rm gromacs-2025.0.tar.gz

# Build and install GROMACS
RUN cd gromacs-2025.0 \
    && mkdir build \
    && cd build \
    && cmake .. -DCMAKE_BUILD_TYPE=Release -DGMX_GPU=CUDA -DGMX_MPI=ON -DGMX_OPENMP=ON -DGMX_BUILD_OWN_FFTW=ON -DGMX_SIMD=AVX2_256 \
    && make -j$(nproc) \
    && make check \
    && sudo make install

# Source GROMACS environment
RUN echo "source /usr/local/gromacs/bin/GMXRC" >> ~/.bashrc

# Set entrypoint to bash
ENTRYPOINT ["/bin/bash"] 
# 