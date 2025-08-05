#!/bin/bash

module load sarus

DOCKER_REPOSITORY=${DOCKER_REPOSITORY:-"spcleth/xaas-artifact"}

sarus pull ${DOCKER_REPOSITORY}:gromacs-deploy-_SSE4.1
sarus pull ${DOCKER_REPOSITORY}:gromacs-deploy-_AVX_256
sarus pull ${DOCKER_REPOSITORY}:gromacs-deploy-_AVX2_128
sarus pull ${DOCKER_REPOSITORY}:gromacs-deploy-_AVX2_256
sarus pull ${DOCKER_REPOSITORY}:gromacs-deploy-_AVX_512
sarus pull ${DOCKER_REPOSITORY}:gromacs-ir-portable-container
sarus pull ${DOCKER_REPOSITORY}:gromacs-ir-specialized-container
