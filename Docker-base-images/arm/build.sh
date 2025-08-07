#/bin/bash

podman build --platform linux/arm64 --build-arg nproc=72 -t spcleth/xaas:source-base-arm-24.04 -f Dockerfile.2404 .
podman tag spcleth/xaas:source-base-arm-24.04 docker.io/spcleth/xaas:source-base-arm-24.04 && podman push docker.io/spcleth/xaas:source-base-arm-24.04
