FROM intel/hpckit:latest

# Update package lists
RUN apt-get update && \
    # Install dependencies for GROMACS
    apt-get install -y build-essential python3 pip libfftw3-dev libxml2-dev wget tar && \
    # Clean up to reduce the size of the container
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN pip install cmake

SHELL ["/bin/bash", "-c"] 

RUN wget https://ftp.gromacs.org/gromacs/gromacs-2025.0.tar.gz && tar -xzf gromacs-2025.0.tar.gz && mv gromacs-2025.0 /opt/gromacs

RUN apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/3bf863cc.pub \
    && echo "deb https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/ /" > /etc/apt/sources.list.d/cuda.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        cuda-toolkit-12.2

ENV PATH="/usr/local/cuda-12.2/bin:$PATH"
ENV LD_LIBRARY_PATH="/usr/local/cuda-12.2/lib64:$LD_LIBRARY_PATH"

ADD oneapi-for-nvidia-gpus-2024.2.1-cuda-12.0-linux.sh .
RUN /bin/bash oneapi-for-nvidia-gpus-2024.2.1-cuda-12.0-linux.sh -y && rm oneapi-for-nvidia-gpus-2024.2.1-cuda-12.0-linux.sh

RUN ln -s /usr/local/cuda/lib64/stubs/libcuda.so /usr/local/cuda/lib64/stubs/libcuda.so.1

# install oneMath
RUN git clone --recursive --branch v0.8 https://github.com/uxlfoundation/oneMath.git && cd oneMath && mkdir build && cd build && cmake .. -DCMAKE_CXX_COMPILER=icpx -DCMAKE_C_COMPILER=icx -DCMAKE_BUILD_TYPE=Release -DENABLE_MKLCPU_BACKEND=TRUE -DENABLE_MKLGPU_BACKEND=TRUE -DENABLE_CUFFT_BACKEND=TRUE -DBUILD_FUNCTIONAL_TESTS=FALSE -DBUILD_EXAMPLES=FALSE && make -j$(nproc) install

# to build the version with Intel support, add "spir64" to the list of targets
RUN mkdir -p /opt/gromacs/build && cd /opt/gromacs/build && cmake .. -DGMX_MPI=ON -DGMX_SIMD=SSE4.1 -DCMAKE_C_COMPILER=icx -DCMAKE_CXX_COMPILER=icpx -DGMX_GPU=SYCL -DGMX_SYCL=DPCPP -DSYCL_CXX_FLAGS_EXTRA="-fsycl-targets=nvptx64-nvidia-cuda" -DGMX_GPU_NB_CLUSTER_SIZE=8 -DGMX_FFT_LIBRARY=fftw3 -DGMX_BUILD_OWN_FFTW=ON -DGMX_EXTERNAL_BLAS=FALSE -DGMX_EXTERNAL_BLAS=FALSE -DGMX_EXTERNAL_LAPACK=FALSE -DGMX_GPU_FFT_LIBRARY=ONEMATH && make -j$(nproc) && make install

RUN rm /usr/local/cuda/lib64/stubs/libcuda.so.1

ENV PATH="/usr/local/gromacs/bin:${PATH}"

CMD ["gmx_mpi"]
