#!/bin/bash

DOCKER_REPOSITORY=${DOCKER_REPOSITORY:-"spcleth/xaas-artifact"}

docker push ${DOCKER_REPOSITORY}:llamacpp-specialized-ault23
docker push ${DOCKER_REPOSITORY}:llamacpp-source-deploy-ault23
