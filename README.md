# XaaS Source and IR Containers: SC25 Paper Artifact

The artifact contains scripts, data, and commands needed to reproduce results presented in the paper "XaaS Containers: Performance-Portable Representation with Source and IR containers".

# Configuration 

## Supported Systems

The artifact has been evaluated on the following systems:
- Ault01-04 nodes of the CSCS Ault system with Intel CPUs.
- Ault23 node of the CSCS Ault system, with Intel CPUs and NVIDIA GPU.
- Alps.Clariden of CSCS, with NVIDIA GH200.
- ALCF Aurora, with Intel CPU and GPUs.
Each system has a separate definition in the `system_discovery` directory, which we use to generate source containers.
All batch job scripts are ready for submission on those systems. You can adjust them to your needs, e.g., by changing partition name, number of nodes, artifact location, scratch filesystem, etc.

## Software Requirements

In addition to supercomputing systems, we use a development machine for two tasks:
* One system to build containers for Ault and Aurora.
* One system to execute LLM benchmarks.

There are no specific requirements except for two software packages:
* Python 3.10 or later.
* Docker to build containers (alternatively, you can use Podman - see below).

For all other software on supercomputing systems, we use existing installations or provide scripts to install dependencies.

## Container Generation

To create containers - our source & IR containers and the specialized containers used as a baseline - you need
a system with Docker installed and supported. All scripts use Docker, but they can be easily changed to work with Podman.

The method of building containers depends on the system:
* For Ault23 and Aurora, we create x86 images that need to be built on a separate system supporting Docker, since neither of those systems provides the possibility of building containers.
* For Clariden, we create arm64 images that can be build on the Alps system; we provide batch scripts for that.

When building containers outside of the supercomputing systems, it is necessary to push them to a remote repository, and later download them on the supercomputer.
We provide scripts for each such step. For that step, one needs to override the default Docker repository (see description below). Alternatively, all Docker images
are provided and can be downloaded directly from the main Docker repository.

## Environment Variables

There are two important environment variables that you might want to set before running the benchmarks:
- `ARTIFACT_LOCATION`. By default, the scripts expect the artifact to be located in `$SCRATCH` on Ault/Clariden, and `$HOME` on Aurora. This variable can be used to override this.
- `DOCKER_REPOSITORY`. By default, all containers and their dependent images are placed in `spcleth/xaas-artifact` Docker repository. Few exceptions are base images and images used by the IR pipeline,
which are placed in `spcleth/xaas`. When generating new artifact images, which need to be pushed to a remote repository, you can override this variable to point to your own repository. The scripts will then push the images to that repository, download them on the supercomputer, and correctly submit batch jobs.

## Install XaaS

Clone `github.com/spcleth/xaas` repository to your local machine. This repository contains the XaaS framework, which is used to generate source and IR containers.
Since it is a Python package, the installation is straightforward:

```
git clone https://github.com/spcl/xaas-containers.git
cd xaas-containers && pip install .
```

# Benchmarks

Each benchmark is contained in a separate directory. In `analysis`, you can find Python scripts needed to postprocess results. Please use the provided `requirements.txt` to install dependencies needed for plotting.

## LLM System Discovery

Main directory: `benchmark-llms`. Produces Table 4 from the paper.

## Source Containers

Main directory: `benchmarks-source/gromacs`. and `benchmarks-source/llama.cpp` Produces Figure 9 (GROMACS) and Figure 10 (llama.cpp).

## IR Containers

Main directory: `benchmarks-ir`. Produces Figure 11.

## Microbenchmarks

### GROMACS Vectorization Performance

Main directory: `microbenchmarks/vectorization-levels`. Produces Figure 2 from the paper.
