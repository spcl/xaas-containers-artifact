#!/bin/bash

docker build -t spcleth/xaas-artifact:gromacs-source-deploy-ault25 -f Dockerfile.deployment-ault25.

docker push spcleth/xaas-artifact:gromacs-source-deploy-ault25
