#!/bin/bash

enroot import -x mount -o osu-ompi.sqsh podman://docker.io/spcleth/xaas-artifact:osu7.5-ompi5.0.8-ofi1.15-cuda12.8
enroot import -x mount -o osu-ompi-cxi.sqsh podman://docker.io/spcleth/xaas-artifact:osu7.5-ompi5.0.8-ofi2.2-cuda12.8-cxi

enroot import -x mount -o osu-mpich.sqsh podman://docker.io/spcleth/xaas-artifact:osu7.5-mpich4.3.0-ofi1.15-cuda12.8
enroot import -x mount -o osu-mpich-cxi.sqsh podman://docker.io/spcleth/xaas-artifact:osu7.5-mpich4.3.0-ofi2.2-cuda12.8-cxi

