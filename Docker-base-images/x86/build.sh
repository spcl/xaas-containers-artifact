#!/bin/bash

docker build --build-arg nproc=8 -t spcleth/xaas:source-base-x86-24.04 -f Dockerfile.2404.ofi .
