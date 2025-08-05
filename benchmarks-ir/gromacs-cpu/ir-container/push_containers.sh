#!/bin/bash

DOCKER_REPOSITORY=${DOCKER_REPOSITORY:-"spcleth/xaas-artifact"}

for container in "gromacs-ir-portable-container" "gromacs-ir-specialized-container" "gromacs-deploy-_AVX_512" \
  "gromacs-deploy-_AVX2_256" "gromacs-deploy-_AVX2_128" "gromacs-deploy-_AVX_256" "gromacs-deploy-_SSE4.1" "gromacs-ir"; do

  echo "Push container ${DOCKER_REPOSITORY}:${container}"
  docker push ${DOCKER_REPOSITORY}:${container}

done
