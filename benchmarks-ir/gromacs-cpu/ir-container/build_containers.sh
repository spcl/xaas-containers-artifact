#!/bin/bash

DOCKER_REPOSITORY=${DOCKER_REPOSITORY:-"spcleth/xaas-artifact"}

echo "Build portable container ${DOCKER_REPOSITORY}:gromacs-ir-portable-container"
docker build -t ${DOCKER_REPOSITORY}:gromacs-ir-portable-container -f portable_container/Dockerfile .

echo "Build specialized container ${DOCKER_REPOSITORY}:gromacs-ir-specialized-container"
docker build -t ${DOCKER_REPOSITORY}:gromacs-ir-specialized-container -f specialized_container/Dockerfile .
