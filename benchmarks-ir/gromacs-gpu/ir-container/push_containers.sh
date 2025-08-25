#!/bin/bash

DOCKER_REPOSITORY=${DOCKER_REPOSITORY:-"spcleth/xaas-artifact"}

for container in "gromacs-gpu-specialized-container-avx2-256" "gromacs-gpu-specialized-container-avx-512" \
  "gromacs-gpu-deploy-CUDA_AVX_512" "gromacs-gpu-deploy-CUDA_AVX2_256"; do
  echo "Push container ${DOCKER_REPOSITORY}:${container}"
  docker push ${DOCKER_REPOSITORY}:${container}
done
