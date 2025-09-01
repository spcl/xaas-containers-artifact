#!/bin/bash

podman build --platform linux/arm64 --build-arg libfabric_version=1.15.0 -t docker.io/spcleth/xaas-artifact:comm-ofi1.15-ucx1.18-cuda12.8 -f Containerfile.comm-fwk .
#podman build --platform linux/arm64 -t docker.io/spcleth/xaas-artifact:comm-ofi2.2-ucx1.18-cuda12.8 -f Containerfile.comm-fwk .
podman build --platform linux/arm64 -t docker.io/spcleth/xaas-artifact:comm-ofi2.2-ucx1.18-cuda12.8-cxi -f Containerfile.comm-fwk.cxi .

podman build --build-arg base_tag=comm-ofi1.15-ucx1.18-cuda12.8 --platform linux/arm64 -t docker.io/spcleth/xaas-artifact:comm-mpich4.3.0-ofi1.15-cuda12.8 -f Containerfile.mpich .
#podman build --build-arg base_tag=comm-ofi2.2-ucx1.18-cuda12.8 --platform linux/arm64 -t docker.io/spcleth/xaas-artifact:comm-mpich4.3.0-ofi2.2-cuda12.8 -f Containerfile.mpich .
podman build --build-arg base_tag=comm-ofi2.2-ucx1.18-cuda12.8-cxi --platform linux/arm64 -t docker.io/spcleth/xaas-artifact:comm-mpich4.3.0-ofi2.2-cuda12.8-cxi -f Containerfile.mpich .

podman build --build-arg base_tag=comm-ofi1.15-ucx1.18-cuda12.8 --platform linux/arm64 -t docker.io/spcleth/xaas-artifact:comm-ompi5.0.8-ofi1.15-cuda12.8 -f Containerfile.ompi .
#podman build --build-arg base_tag=comm-ofi2.2-ucx1.18-cuda12.8 --platform linux/arm64 -t docker.io/spcleth/xaas-artifact:comm-ompi5.0.8-ofi2.2-cuda12.8 -f Containerfile.ompi .
podman build --build-arg base_tag=comm-ofi2.2-ucx1.18-cuda12.8-cxi --platform linux/arm64 -t docker.io/spcleth/xaas-artifact:comm-ompi5.0.8-ofi2.2-cuda12.8-cxi -f Containerfile.ompi .

podman build --build-arg base_tag=comm-ompi5.0.8-ofi1.15-cuda12.8 --platform linux/arm64 -t docker.io/spcleth/xaas-artifact:osu7.5-ompi5.0.8-ofi1.15-cuda12.8 -f Containerfile.osu .
#podman build --build-arg base_tag=comm-ompi5.0.8-ofi2.2-cuda12.8 --platform linux/arm64 -t docker.io/spcleth/xaas-artifact:osu7.5-ompi5.0.8-ofi2.2-cuda12.8 -f Containerfile.osu .
podman build --build-arg base_tag=comm-ompi5.0.8-ofi2.2-cuda12.8-cxi --platform linux/arm64 -t docker.io/spcleth/xaas-artifact:osu7.5-ompi5.0.8-ofi2.2-cuda12.8-cxi -f Containerfile.osu .

podman build --build-arg base_tag=comm-mpich4.3.0-ofi1.15-cuda12.8 --platform linux/arm64 -t docker.io/spcleth/xaas-artifact:osu7.5-mpich4.3.0-ofi1.15-cuda12.8 -f Containerfile.osu .
#podman build --build-arg base_tag=comm-mpich4.3.0-ofi2.2-cuda12.8 --platform linux/arm64 -t docker.io/spcleth/xaas-artifact:osu7.5-mpich4.3.0-ofi2.2-cuda12.8 -f Containerfile.osu .
podman build --build-arg base_tag=comm-mpich4.3.0-ofi2.2-cuda12.8-cxi --platform linux/arm64 -t docker.io/spcleth/xaas-artifact:osu7.5-mpich4.3.0-ofi2.2-cuda12.8-cxi -f Containerfile.osu .
