## Model Installation

Before running the benchmarks, you need to download the LLaMA 2 models from Hugging Face and place them in the following directory:

You can download the required model files from the links below:

- [llama-2-13b-chat.Q4_K_M.gguf](https://huggingface.co/TheBloke/Llama-2-13B-chat-GGUF/blob/main/llama-2-13b-chat.Q4_K_M.gguf)
- [llama-2-13b-chat.Q4_0.gguf](https://huggingface.co/TheBloke/Llama-2-13B-chat-GGUF/blob/main/llama-2-13b-chat.Q4_0.gguf)

We provide the script `download_data.sh` which downloads them and places them in directories that the script expects.

## Docker Images

We use the following Docker images:

```
spcleth/xaas-artifact:llamacpp-source-deploy-clariden
spcleth/xaas-artifact:llamacpp-specialized-clariden
```

All images are provided in the repository and can also be rebuilt.

## Test Cases

This repository contains four benchmark test cases:

- **Test Case 0 (naive)**: naive build with no flags, which results in a CPU-only configuration.
- **Test Case 1 (specialized)**: Host build with OpenBLAS and CUDA.
- **Test Case 2 (containerized specialized)**: Same as Test Case 1 but built inside a container.
- **Test Case 3 (XaaS)**: XaaS source container with user selection of CUDA, and ARM_SVE.

## Build

Run the following commands:

```
/bin/bash download_data.sh
```

Then, schedule building of non-containerized versions:

```
sbatch < build-scripts/testcase0/build.sh
sbatch < build-scripts/testcase1/build.sh
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
sbatch < build-scripts/testcase3/build.sh
```

This will build containers in the default `spcleth/xaas-artifact` repository. Use the enviroment variable `DOCKER_REPOSITORY` to override this.

## Execute

Submit jobs:

```
sbatch < llama-benchmarking-script/benchmark-testcase0.sh
sbatch < llama-benchmarking-script/benchmark-testcase1.sh
```

To submit container jobs, we need to use `srun` currently which is a blocking procedure. Thus, you will have to keep a Bash session alive until jobs are queued and executed.

```
/bin/bash submit_container.sh
```

It is possible to also submit those jobs through `sbatch`, but [it is experimental and discouraged by system operators](https://docs.cscs.ch/software/container-engine/run/#running-containerized-environments).

