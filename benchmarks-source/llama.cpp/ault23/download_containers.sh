#!/bin/bash

DOCKER_REPOSITORY=${DOCKER_REPOSITORY:-"spcleth/xaas-artifact"}

sarus pull ${DOCKER_REPOSITORY}:llamacpp-specialized-ault23
sarus pull ${DOCKER_REPOSITORY}:llamacpp-source-deploy-ault23
