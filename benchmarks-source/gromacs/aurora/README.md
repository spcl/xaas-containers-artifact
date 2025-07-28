# GROMACS on Aurora

This repository contains scripts for automatically collecting performance and execution metrics for different builds.  

We want to use test case B from [UEABS](https://repository.prace-ri.eu/git/UEABS/ueabs/-/tree/master/gromacs?ref_type=heads). There is one input file that needs to downloaded, extracted, and put on the high-performance filesystem.
The script `download_data.sh` should take care of that.

## Usage Instructions

There is a template for the general execution. Please adapt to your requirements.

Before running the scripts, make sure to update the following paths:

- **Build Directory:** Set the script to point to the correct build directory.
- **UEABS Test Case Input:** Specify the path to the UEABS benchmark test case input.
- **Results Directory:** Define the directory where the collected performance metrics should be stored.  

## Test Cases

- Portable Container - Clang, SSE4.1 vectorization, SYCL for GPUs.
- Specialized container - Intel Compiler, MKL, SYCL for GPUs.
- Spack installation (no container) - specialized to platform.
- XaaS Source container - run `spcleth/xaas-artifact:source-gromacs-aurora` through the container method of the platform.
- XaaS IR container - run FIXME through the container method of the platform.
