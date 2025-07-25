# XaaS Source and IR Containers: SC25 Paper Artifact

## Supported Systems

The artifact has been evaluated on the following systems:
- Ault23 node of the CSCS Ault system, with Intel CPUs and NVIDIA GPU
- Alps.Clariden of CSCS, with NVIDIA GH200
- ALCF Aurora, with Intel CPU and GPUs.

Each system has a separate definition in the `system_discovery` directory, which we use to generate source containers.

All batch job scripts are ready for submission on those systems.
You can adjust them to your needs, e.g., by changing partition name, number of nodes, artifact location, scratch filesystem, etc..

## Requirements

Install XaaS

Python version + libraries

## LLM System Discovery

Main directory: `benchmark-llms`.

### Execute Benchmarks

### Analysis

Produces Table 4; multiple scripts.

## Source Containers

Main directory: `benchmarks-source`.

### Generate Containers

### Run Benchmarks

### Analysis

Produces Figure 9 (GROMACS) and Figure 10 (llama.cpp).

## IR Containers

Main directory: `benchmarks-ir`.

### Analysis

Produces Figure 11.

## Microbenchmarks

### GROMACS Vectorization Performance

Main directory: `microbenchmarks/vectorization-levels`

### Build

### Execute

### Analysis

Produces Figure 2.

### Distributed Containers

Produces new Figure 12.
