# GROMACS + SYCL Portable Containers

This microbenchmark evaluates the performance of portable GROMACS container.

## Build Scenarios

* Test Case 0 - source container built for Ault25, AVX2_256 + CUDA + MKL 
* Test Case 1 - portable container with icpx, SYCL, CUDA plugin, and oneMath.

`gromacs-benchmarks-old` contains an old run with Ault25's source container on Ault23; it differs only in the SIMD selection.

## Test Case B

Currently, the SYCL container does not execute correctly on CUDA GPUs:

```
Unknown exception:
(exception type: N4sycl3_V114nd_range_errorE)
Number of work-groups exceed limit for dimension 2 : 65663 > 65535 -30
(PI_ERROR_INVALID_VALUE)
```

Details can be found in `portable_output_testcaseB.log`. To repeat, run the following commands (after downloading input data).

```
export CUDA_VISIBLE_DEVICES="0"

sarus run -t --mount=type=bind,source=$(pwd)/../../../data,destination="/data" --env CUDA_VISIBLE_DEVICES="0" xaas-artifact:gromacs-source-deploy-ault25 /bin/bash

HYDRA_LAUNCHER=fork mpiexec -n 1 /usr/local/gromacs/bin/gmx_mpi mdrun -s /data/gromacs/GROMACS_TestCaseB/lignocellulose.tpr -ntomp 64 -gpu_id 0 -nsteps 100
```
