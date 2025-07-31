#!/bin/bash

ARTIFACT_LOCATION=${ARTIFACT_LOCATION:-${SCRATCH}/xaas-containers-artifact}

mkdir -p ${ARTIFACT_LOCATION}/dependencies
cd ${ARTIFACT_LOCATION}/dependencies

echo "Install Spack v1.0"
git clone --depth=2 --branch=v1.0.0 https://github.com/spack/spack.git spack_2025

echo "Install GCC 11.5"
source spack_2025/share/spack/setup-env.sh
spack install -j$(nproc) gcc@11.5.0
