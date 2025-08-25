#!/bin/bash

module load sarus

DOCKER_REPOSITORY=${DOCKER_REPOSITORY:-"spcleth/xaas-artifact"}

sarus pull ${DOCKER_REPOSITORY}:gromacs-gpu-deploy-CUDA_AVX_512
sarus pull ${DOCKER_REPOSITORY}:gromacs-gpu-specialized-container-avx-512
