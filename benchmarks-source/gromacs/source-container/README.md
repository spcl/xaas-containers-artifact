# llama.cpp - Source Containers

Use the `DOCKER_REPOSITORY` vairable to specify the Docker repository where the source containers will be pushed. The default is `spcleth/xaas-artifact`.


## Generate Source Containers

To create source containers for `gromacs`, you can use the following command. These containers are built from the source code of `gromacs` in version 2025.0, and are available for different architectures.

```
/bin/bash create-container.sh
```

This will create two images:

```
spcleth/xaas-artifact:gromacs-source-x86_64
spcleth/xaas-artifact:gromacs-source-arm64
```

Containers can be pushed to the remote repository:

```
/bin/bash push-source-container.sh
```

## Deploy Source Containers

To generate deployment images for the three systems, run `deploy-container.sh <spec-file>`. Passing `0` as an additional argument can disable building container, i.e., only a Dockerfile is generated.

```
/bin/bash deploy-container.sh specializations/ault23.yml
/bin/bash deploy-container.sh specializations/ault23_second.yml
/bin/bash deploy-container.sh specializations/aurora.yml
/bin/bash deploy-container.sh specializations/clariden.yml
```

This will produce four images:

```
spcleth/xaas-artifact:gromacs-source-deploy-ault23
spcleth/xaas-artifact:gromacs-source-deploy-ault23_second
spcleth/xaas-artifact:gromacs-source-deploy-aurora
spcleth/xaas-artifact:gromacs-source-deploy-clariden
```

The Clariden image requires multi-platform support, as it generates an arm64 image.
We also provide a build script as `testcase3` in Clariden directory, allowing to build the image directly on the Alps.Clariden system.

Additionally, we provide a second Aurora test case that uses a manual fix for GPU compatibility:

```
/bin/bash build-aurora-manual-fix.sh
```

This will produce one image:

```
spcleth/xaas-artifact:gromacs-source-deploy-ault23
spcleth/xaas-artifact:gromacs-source-deploy-ault23_second
spcleth/xaas-artifact:gromacs-source-deploy-aurora-
spcleth/xaas-artifact:gromacs-source-deploy-clariden
```

Containers can be pushed to the remote repository:

```
/bin/bash push-containers.sh
```
