## Model Installation

Before running the benchmarks, you need to download the LLaMA 2 models from Hugging Face and place them in the following directory:

You can download the required model files from the links below:

- [llama-2-13b-chat.Q4_K_M.gguf](https://huggingface.co/TheBloke/Llama-2-13B-chat-GGUF/blob/main/llama-2-13b-chat.Q4_K_M.gguf)
- [llama-2-13b-chat.Q4_0.gguf](https://huggingface.co/TheBloke/Llama-2-13B-chat-GGUF/blob/main/llama-2-13b-chat.Q4_0.gguf)

We provide the script `download_data.sh` which downloads them and places them in directories that the script expects.

## Test Cases

This repository contains four benchmark test cases:

- **Test Case 0 (naive)**: naive build with no flags, which results in a CPU-only configuration.
- **Test Case 1 (specialized)**: Host build with Intel MKL Blas and CUDA.
- **Test Case 2 (containerized specialized)**: Same as Test Case 1 but built inside a container.
- **Test Case 3 (XaaS)**: XaaS source container with user selection of CUDA, AVX_512. and MKL.

## Build

Run the following commands:

```
/bin/bash install_dependencies.sh
/bin/bash download_data.sh
```

Then, schedule building of non-containerized versions:

```
sbatch -w ault23 < build-scripts/testcase0/build.sh
sbatch -w ault23 < build-scripts/testcase1/build.sh
```

To build container version, run the following scripts on a system with Docker support:

```
/bin/bash build_containers.sh
/bin/bash push_containers.sh
```

This will build containers in the default `spcleth/xaas-artifact` repository. Use the enviroment variable `DOCKER_REPOSITORY` to override this.

Then, run the following script to get all containers on Ault:

```
/bin/bash download_containers.sh
```

## Execute

Submit jobs:

```
sbatch -w ault23 < benchmarking-scripts/benchmark_testcase0.sh
sbatch -w ault23 < benchmarking-scripts/benchmark_testcase1.sh
sbatch -w ault23 < benchmarking-scripts/benchmark_testcase2.sh
sbatch -w ault23 < benchmarking-scripts/benchmark_testcase3.sh
```
