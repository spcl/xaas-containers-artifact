#!/bin/bash

ARTIFACT_LOCATION=${ARTIFACT_LOCATION:-${HOME}/xaas-containers-artifact}

mkdir -p ${ARTIFACT_LOCATION}/dependencies
cd ${ARTIFACT_LOCATION}/dependencies

echo "Install CMake"

wget https://github.com/Kitware/CMake/releases/download/v3.27.9/cmake-3.27.9-linux-x86_64.tar.gz
tar -xf cmake-3.27.9-linux-x86_64.tar.gz
mv cmake-3.27.9-linux-x86_64 cmake

