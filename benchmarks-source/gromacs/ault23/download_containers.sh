#!/bin/bash

DOCKER_REPOSITORY=${DOCKER_REPOSITORY:-"spcleth/xaas-artifact"}

sarus pull ${DOCKER_REPOSITORY}:gromacs-source-deploy-ault23
sarus pull ${DOCKER_REPOSITORY}:gromacs-source-deploy-ault23_second
