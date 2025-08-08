## Preparation

Run the following scripts first:

```
/bin/bash install_dependencies.sh
/bin/bash download_data.sh
```

## Docker Images

We use the following Docker images:

```
spcleth/xaas-artifact:gromacs-source-deploy-ault23
spcleth/xaas-artifact:gromacs-source-deploy-ault23_second
```

## Test Cases

This repository contains several benchmark test cases:

- **Test Case 0 (naive)**: naive build with no flags, which results in a CPU-only configuration.
- **Test Case 1 (specialized)**: host build with Intel MKL Blas and CUDA.
- **Test Case 2 (XaaS, user choice 1)**: XaaS source container with gcc and no BLAS.
- **Test Case 3 (XaaS, user choice 2)**: XaaS source container with icpx and MKL.
- **Test Case 4 (Spack, simple)**: regular Spack install with cuda and mpich.
- **Test Case 5 (Spack, advanced)**: Spack install with oneapi-mkl explicitly selected.

## Build

Run the following commands:

```
/bin/bash install_dependencies.sh
/bin/bash download_data.sh
```

Schedule building of non-containerized versions:

```
sbatch -w ault23 < build-scripts/test_case_0/build.sh
sbatch -w ault23 < build-scripts/test_case_1/build.sh
sbatch -w ault23 < build-scripts/test_case_4/build.sh
sbatch -w ault23 < build-scripts/test_case_5/build.sh
```

Then, run the following script to get all containers on Ault:

```
/bin/bash download_containers.sh
```

## Execute

Submit jobs:

```
sbatch -w ault23 < benchmarks-collection-scripts/test_case_0/benchmark_gromacs.sh
sbatch -w ault23 < benchmarks-collection-scripts/test_case_1/benchmark_gromacs.sh
sbatch -w ault23 < benchmarks-collection-scripts/test_case_2/benchmark_gromacs.sh
sbatch -w ault23 < benchmarks-collection-scripts/test_case_3/benchmark_gromacs.sh
sbatch -w ault23 < benchmarks-collection-scripts/test_case_4/benchmark_gromacs.sh
sbatch -w ault23 < benchmarks-collection-scripts/test_case_5/benchmark_gromacs.sh
```

## GROMACS 2025.0

We evaluated also a newer version of Spack that provides GROMACS 2025.0.
It is recommended to run it last in case having multiple Spack variants causes
issues with shared caches:

```
/bin/bash install_dependencies_gromacs_2025.sh

sbatch -w ault23 < build-scripts/spack_2025_testcase_4/build.sh
sbatch -w ault23 < build-scripts/spack_2025_testcase_5/build.sh

sbatch -w ault23 < benchmarks-collection-scripts/spack-2025/benchmark_gromacs.sh
sbatch -w ault23 < benchmarks-collection-scripts/spack-2025-advanced/benchmark_gromacs.sh
```
