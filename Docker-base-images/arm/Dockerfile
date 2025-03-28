FROM ubuntu:22.04

# Base Image for x86_64 architecture

# Set non-interactive mode for apt-get to avoid prompts
ENV DEBIAN_FRONTEND=noninteractive

# Update system and install dependencies
# libfabric-dev, gfortran, libssl-dev are mpich dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    wget \
    curl \
    software-properties-common \
    lsb-release \
    gfortran \
    libssl-dev \
    libfabric-dev \
    gnupg \ 
    autoconf \ 
    automake \
    libtool-bin \
    sudo 


RUN apt-get update && apt-get install -y \
    gcc-11 g++-11 \
    build-essential \
    software-properties-common \
    && update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-11 100 \
    && update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-11 100 \
    && gcc --version

# Add LLVM 17 repo for Ubuntu 22.04 (jammy)
RUN wget -O - https://apt.llvm.org/llvm-snapshot.gpg.key | gpg --dearmor -o /usr/share/keyrings/llvm.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/llvm.gpg] http://apt.llvm.org/jammy/ llvm-toolchain-jammy-17 main" \
    | tee /etc/apt/sources.list.d/llvm.list && \
    apt-get update && \
    apt-get install -y clang-17 lldb-17 lld-17 && \
    update-alternatives --install /usr/bin/clang clang /usr/bin/clang-17 100 && \
    update-alternatives --install /usr/bin/clang++ clang++ /usr/bin/clang++-17 100 && \
    clang --version
# Install the latest GNU Make
RUN apt-get install -y make 

# Install latest CMake from Kitware for Ubuntu 22.04 (Jammy)
RUN wget -O - https://apt.kitware.com/keys/kitware-archive-latest.asc \
    | gpg --dearmor -o /usr/share/keyrings/kitware.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/kitware.gpg] https://apt.kitware.com/ubuntu/ jammy main" \
    > /etc/apt/sources.list.d/kitware.list && \
    apt-get update && \
    apt-get install -y cmake

# Download and install MPICH 3.4
RUN wget https://www.mpich.org/static/downloads/3.4/mpich-3.4.tar.gz && \
    tar -xzf mpich-3.4.tar.gz && \
    cd mpich-3.4 && \
    ./configure FFLAGS=-fallow-argument-mismatch --prefix=/usr/local/mpich --with-device=ch4:ofi --enable-fast=all,O3 && \
    make -j$(nproc) && \
    make install && \
    cd .. && \
    rm -rf mpich-3.4 mpich-3.4.tar.gz

# Set environment variables
ENV PATH=/usr/local/mpich/bin:$PATH \
    LD_LIBRARY_PATH=/usr/local/mpich/lib:$LD_LIBRARY_PATH

