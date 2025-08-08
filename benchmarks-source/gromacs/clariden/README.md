## Preparation

Run the following scripts first:

```
/bin/bash install_dependencies.sh
/bin/bash download_data.sh
```

## Docker Images

We use the following Docker images:

```
spcleth/xaas-artifact:gromacs-source-deploy-clariden
```

## Test Cases

This repository contains five benchmark test cases:

- **Test Case 0 (naive)**: naive build with no flags, which results in a CPU-only configuration.
- **Test Case 1 (specialized)**: Host build with CUDA and openBLAS.
- **Test Case 2 (XaaS, user choice)**: XaaS source container with gcc and CUDA.
- **Test Case 4 (Spack, simple)**: regular Spack install with cuda and mpich.
- **Test Case 5 (Spack, advanced)**: Spack install with cray-mpich explicitly selected.

## Build

Then, schedule building of non-containerized versions:

```
sbatch -w ault23 < build-scripts/testcase0/build.sbatch
sbatch -w ault23 < build-scripts/testcase1/build.sbatch
sbatch -w ault23 < build-scripts/testcase4/build.sh
sbatch -w ault23 < build-scripts/testcase5/build.sh
```

Containers can be either rebuilt from scratch or imported to the system. All container operation have to run on compute nodes, as Podman requires access to dedicated filesystem.

### Download Containers

Just run and wait for the batch job to complete:

```
sbatch < download_containers.sh
```

### Rebuild Containers

If you want to rebuild container versions, then run the following scripts. Pushing to remote repositories is disabled by default, as it requires a login with Podman.

```
sbatch < build-scripts/testcase2/build.sh
```

This will build containers in the default `spcleth/xaas-artifact` repository. Use the enviroment variable `DOCKER_REPOSITORY` to override this.

## Execute

Submit jobs:

```
sbatch -t 01:00:00 < benchmark-collection-scripts/testcase0/benchmark_testcase0_B.sh
sbatch -t 01:00:00 < benchmark-collection-scripts/testcase1/benchmark_testcase1_B.sh
sbatch -t 01:00:00 < benchmark-collection-scripts/testcase4/benchmark_testcase4_B.sh
sbatch -t 01:00:00 < benchmark-collection-scripts/testcase5/benchmark_testcase5_B.sh
```

For the XaaS container, we need to execute the job manually since the usage of environments within `sbatch` are currently discouraged:

```
/bin/bash submit_container.sh
```

It is possible to also submit this job through `sbatch`, but [it is experimental and discouraged by system operators](https://docs.cscs.ch/software/container-engine/run/#running-containerized-environments).

