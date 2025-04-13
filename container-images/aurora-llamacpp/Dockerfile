# ---- Stage 1: Source Container ----
    FROM ubuntu:20.04 AS source-stage

    SHELL ["/bin/bash", "-c"]
    
    # Avoid interactive frontend
    ENV DEBIAN_FRONTEND=noninteractive
    
    # Install dependencies required to prepare the source tree
    RUN apt-get update && \
        apt-get install -y --no-install-recommends \
            ca-certificates \
            git && \
        rm -rf /var/lib/apt/lists/*
    
    # Copy llama.cpp source into container
    COPY llama.cpp /llama.cpp
    
    # ---- Stage 2: Build with oneAPI SYCL and MKL ----
    FROM intel/oneapi-hpckit:latest AS build-stage
    
    SHELL ["/bin/bash", "-c"]

    ARG CMAKE_VERSION=3.28.3
    RUN apt update && apt install -y wget tar && \
    wget https://github.com/Kitware/CMake/releases/download/v${CMAKE_VERSION}/cmake-${CMAKE_VERSION}-linux-x86_64.tar.gz && \
    tar -xzf cmake-${CMAKE_VERSION}-linux-x86_64.tar.gz --strip-components=1 -C /usr/local && \
    rm cmake-${CMAKE_VERSION}-linux-x86_64.tar.gz
    
    # Install build dependencies
    RUN apt-get update && \
        apt-get install -y --no-install-recommends \
            cmake \
            build-essential \
            pkg-config \
            libcurl4-openssl-dev && \
        rm -rf /var/lib/apt/lists/*
    
    # Copy source code from source-stage
    COPY --from=source-stage /llama.cpp /llama.cpp
    
    WORKDIR /llama.cpp
    
    # Build with SYCL + Intel MKL BLAS
    RUN source /opt/intel/oneapi/setvars.sh && \
        cmake -B build \
            -DCMAKE_C_COMPILER=icx \
            -DCMAKE_CXX_COMPILER=icpx \
            -DGGML_SYCL=ON \
            -DGGML_BLAS=ON \
            -DGGML_BLAS_VENDOR=Intel10_64lp \
            -DBLAS_INCLUDE_DIRS=${MKLROOT}/include \
            -DCMAKE_EXE_LINKER_FLAGS="-Wl,-rpath,${MKLROOT}/lib/intel64" && \
        cmake --build build --config Release -j $(nproc)
    
    CMD ["/bin/bash"]