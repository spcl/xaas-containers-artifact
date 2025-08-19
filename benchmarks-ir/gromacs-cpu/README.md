
Containers will be be build and tagged with the default `spcleth/xaas-artifact` repository.
To change it, use the environment variable `DOCKER_REPOSITORY`.

## Build Containers

Everything happens in the `ir-container` directory.

### Build IR Containers

Run:

```
/bin/bash download_data.sh
python create-container.py gromacs-2025.0
```

This will take around 10-15 minutes to create several Docker containers:

```
spcleth/xaas-artifact:gromacs-deploy-_AVX_512
spcleth/xaas-artifact:gromacs-deploy-_AVX2_256
spcleth/xaas-artifact:gromacs-deploy-_AVX2_128
spcleth/xaas-artifact:gromacs-deploy-_AVX_256
spcleth/xaas-artifact:gromacs-deploy-_SSE4.1
spcleth/xaas-artifact:gromacs-ir
```

In addition, it following create the following "working" images which are no longer needed after deployment and can be removed:

```
spcleth/xaas:builder-gromacs-deps-fftw3-3.3.10-AVX_512
spcleth/xaas:builder-gromacs-deps-fftw3-3.3.10-SSE4.1
spcleth/xaas:builder-gromacs-deps-fftw3-3.3.10-AVX2_128
spcleth/xaas:builder-gromacs-deps-fftw3-3.3.10-AVX2_256
spcleth/xaas:builder-gromacs-deps-fftw3-3.3.10-AVX_256
```

### Build Baselines

Then, build the portable and specialized containers:

```
/bin/bash build_containers.sh
```

### Push Containers

All containers - XaaS IR and baselines - will be pushed to a remote DockerHub repository.

```
/bin/bash push_containers.sh
```

## Submit on Cluster

On the cluster with Sarus containers, we will pull the containers, submit jobs, and then gather results.

Everything happens in the `ault01` directory.

### Pull Containers

```
/bin/bash download_containers.sh
```

### Download Dependencies

We need to gather input files for GROMACS runs.

```
/bin/bash download_data.sh
```

### Submit Jobs 

```
/bin/bash submit_jobs.sh
```

### Gather data

```
/bin/bash copy_output_data.sh <output-dir>
```

This will copy all results into `<output-dir>` while preserving the directory structure.

Then, you can copy the results to the local directory in artifact, where the plotting script expects the data.

```
scp -r <system-name>:<output-dir> ../ault01
```

## Docker Images

The build depends on the following Docker images:

```
spcleth/xaas:deps-fftw3-3.3.10-AVX_512
spcleth/xaas:deps-fftw3-3.3.10-AVX2_128
spcleth/xaas:deps-fftw3-3.3.10-AVX2_256
spcleth/xaas:deps-fftw3-3.3.10-AVX_256
spcleth/xaas:deps-fftw3-3.3.10-SSE2
spcleth/xaas:deps-fftw3-3.3.10-SSE4.1
spcleth/xaas:llvm-19-dev
spcleth/xaas:features-analyzer-dev
spcleth/xaas:llvm-19
```
