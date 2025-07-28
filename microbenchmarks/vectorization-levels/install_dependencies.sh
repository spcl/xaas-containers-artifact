#!/bin/bash

ARTIFACT_LOCATION=${ARTIFACT_LOCATION:-${SCRATCH}/xaas-containers-artifact}

mkdir -p ${ARTIFACT_LOCATION}/dependencies
cd ${ARTIFACT_LOCATION}/dependencies

echo "Install CMake"

wget https://github.com/Kitware/CMake/releases/download/v3.31.8/cmake-3.31.8-linux-x86_64.tar.gz
tar -xf cmake-3.31.8-linux-x86_64.tar.gz
mv cmake-3.31.8-linux-x86_64 cmake

echo "Install Spack"
git clone --depth=2 --branch=v1.0.0-alpha.4 https://github.com/spack/spack.git spack

echo "Install GCC 11.5"
spack install -j$(nproc) gcc@11.5.0
