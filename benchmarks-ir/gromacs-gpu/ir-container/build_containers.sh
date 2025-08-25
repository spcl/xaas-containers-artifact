#!/bin/bash

DOCKER_REPOSITORY=${DOCKER_REPOSITORY:-"spcleth/xaas-artifact"}

echo "Build portable container ${DOCKER_REPOSITORY}:gromacs-gpu-specialized-container-avx-512"
docker build -t ${DOCKER_REPOSITORY}:gromacs-gpu-specialized-container-avx-512 -f specialized_container/Dockerfile.ault23 . && docker push ${DOCKER_REPOSITORY}:gromacs-gpu-specialized-container-avx-512

echo "Build specialized container ${DOCKER_REPOSITORY}:gromacs-gpu-specialized-container-avx2-256"
docker build -t ${DOCKER_REPOSITORY}:gromacs-gpu-specialized-container-avx2-256 -f specialized_container/Dockerfile.ault25 . && docker ${DOCKER_REPOSITORY}:gromacs-gpu-specialized-container-avx2-256
