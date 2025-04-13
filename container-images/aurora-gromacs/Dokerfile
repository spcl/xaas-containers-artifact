# ---- Stage 1: Source/IR Container ----
    FROM ealnuaimi/xaas:ubuntu20.04-mpich3.1.4-v1.1 AS source-stage

    SHELL ["/bin/bash", "-c"]
    
    # Copy GROMACS source code
    COPY gromacs-2025.0 /gromacs-2025.0
    
    # ---- Stage 2: Target System Build with Intel oneAPI ----
    FROM intel/hpckit:latest AS build-stage
    
    SHELL ["/bin/bash", "-c"]
    
    # Copy only the GROMACS source from the source-stage
    COPY --from=source-stage /gromacs-2025.0 /gromacs-2025.0
    
    WORKDIR /gromacs-2025.0
    
    # Build GROMACS using Intel compilers and MKL
    RUN source /opt/intel/oneapi/setvars.sh && \
        mkdir build && cd build && \
        cmake .. \
          -DGMX_BUILD_OWN_FFTW=ON \
          -DCMAKE_BUILD_TYPE=Release \
          -DCMAKE_C_COMPILER=icx \
          -DCMAKE_CXX_COMPILER=icpx \
          -DGMX_GPU=SYCL \
          -DGMX_FFT_LIBRARY=mkl \
          -DGMX_MPI=ON \
          -DGMX_OPENMP=ON \
          -DGMX_SIMD=AVX_512 \
          -DGMX_GPU_FFT_LIBRARY=MKL \
          -DGMX_GPU_NB_CLUSTER_SIZE=4 && \
        make -j$(nproc) && \
        make check && \
        make install
    
    CMD ["/bin/bash"]