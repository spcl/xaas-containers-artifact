#!/bin/bash

ARTIFACT_REPOSITORY=${ARTIFACT_REPOSITORY:-"spcleth/xaas-artifact"}

echo "Building container ${ARTIFACT_REPOSITORY}:gromacs-aurora-specialized"

docker build -t $ARTIFACT_REPOSITORY:gromacs-aurora-specialized -f ./build_scripts/container-specialized/Dockerfile -
docker push $ARTIFACT_REPOSITORY:gromacs-aurora-specialized
