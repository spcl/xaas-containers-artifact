FROM ubuntu:20.04

#TODO
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

# Add Ubuntu Toolchain PPA for the latest GCC
RUN apt-get update && apt-get install -y software-properties-common \
    && add-apt-repository ppa:ubuntu-toolchain-r/test -y \
    && apt-get update \
    && apt-get install -y gcc-11 g++-11 gcc-13 g++-13 \
    && update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-11 100 \
    && update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-11 100 \
    && update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-13 50 \
    && update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-13 50 \
    && gcc --version

# Add LLVM repository for the latest Clang
RUN wget -O - https://apt.llvm.org/llvm-snapshot.gpg.key | apt-key add - \
    && echo "deb http://apt.llvm.org/focal/ llvm-toolchain-focal-17 main" | tee -a /etc/apt/sources.list \
    && apt-get update \
    && apt-get install -y clang-17 lldb-17 lld-17 \
    && update-alternatives --install /usr/bin/clang clang /usr/bin/clang-17 100 \
    && update-alternatives --install /usr/bin/clang++ clang++ /usr/bin/clang++-17 100 \
    && clang --version

# Install the latest GNU Make
RUN apt-get install -y make 

# Install CMake (latest version from Kitware)
RUN wget -O - https://apt.kitware.com/keys/kitware-archive-latest.asc 2>/dev/null | gpg --dearmor - | tee /usr/share/keyrings/kitware-archive-keyring.gpg >/dev/null \
    && echo 'deb [signed-by=/usr/share/keyrings/kitware-archive-keyring.gpg] https://apt.kitware.com/ubuntu/ focal main' | tee /etc/apt/sources.list.d/kitware.list >/dev/null \
    && apt-get update \
    && apt-get install -y cmake 

# Download and install MPICH 3.4
RUN wget https://www.mpich.org/static/downloads/3.4/mpich-3.4.tar.gz \
    && tar -xzf mpich-3.4.tar.gz \
    && cd mpich-3.4 \
    && ./configure --prefix=/usr/local/mpich --with-device=ch4:ofi --enable-fast=all,O3 \
    && make -j$(nproc) \
    && make install \
    && cd .. \
    && rm -rf mpich-3.4 mpich-3.4.tar.gz

# Set environment variables
ENV PATH=/usr/local/mpich/bin:$PATH \
    LD_LIBRARY_PATH=/usr/local/mpich/lib:$LD_LIBRARY_PATH

