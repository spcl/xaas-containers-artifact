#!/bin/bash

DOCKER_REPOSITORY=${DOCKER_REPOSITORY:-"spcleth/xaas-artifact"}

echo "Using xaas installation in $(which xaas)"
echo "Creating repositories in Docker repository: ${DOCKER_REPOSITORY}"

echo "Download GROMACS source code"
if [ ! -f gromacs-2025.0.tar.gz ]; then
  wget -q https://ftp.gromacs.org/gromacs/gromacs-2025.0.tar.gz
  tar -xf gromacs-2025.0.tar.gz
fi

echo "Create GROMACS container for x86_64"
yq ".docker_repository = \"${DOCKER_REPOSITORY}\"" gromacs_source.yml >gromacs_source_x86_64.yml
xaas source container gromacs_source_x86_64.yml

echo "Create GROMACS container for arm64"
yq ".docker_repository = \"${DOCKER_REPOSITORY}\" | .cpu_architecture = \"arm64\"" gromacs_source.yml >gromacs_source_arm64.yml
xaas source container gromacs_source_arm64.yml
