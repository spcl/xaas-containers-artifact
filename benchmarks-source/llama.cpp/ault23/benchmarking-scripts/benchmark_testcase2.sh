#!/bin/bash
#SBATCH --job-name=llama_benchmark_pg         # More descriptive job name
#SBATCH --output=llama_pg_%j.out              # Standard output log
#SBATCH --error=llama_pg_%j.err               # Error log
#SBATCH --nodelist=ault23                     # Assign the job to a specific node
#SBATCH --ntasks=1                            # 1 MPI rank (not really needed here, but kept for clarity)
#SBATCH --gpus=1                              # 1 GPU (if used by llama.cpp)
#SBATCH --cpus-per-task=64                    # CPUs allocated to the task
#SBATCH --time=1:00:00                        # Max wall time
#SBATCH --exclusive                           # Exclusive access to the node

ARTIFACT_LOCATION=${ARTIFACT_LOCATION:-${SCRATCH}/xaas-containers-artifact}
DOCKER_REPOSITORY=${DOCKER_REPOSITORY:-"spcleth/xaas-artifact"}
DOCKER_IMAGE="llamacpp-specialized-ault23"

TESTCASE_DIR="${ARTIFACT_LOCATION}/benchmarks-source/llama.cpp/ault23/llama-benchmarks/Q4_K_M"
MODEL_FILE="${ARTIFACT_LOCATION}/data/llama.cpp/llama-2-13b-chat.Q4_K_M.gguf"

export OMP_NUM_THREADS=64

module load sarus

mkdir -p "$TESTCASE_DIR"

export CUDA_VISIBLE_DEVICES=0

srun sarus run \
  --mount=type=bind,source="$(dirname $MODEL_FILE)",destination="/input_dir" \
  --mount=type=bind,source="${TESTCASE_DIR}",destination="/result_dir" \
  --env OMP_NUM_THREADS=${OMP_NUM_THREADS} \
  --env CUDA_VISIBLE_DEVICES=${CUDA_VISIBLE_DEVICES} \
  ${DOCKER_REPOSITORY}:${DOCKER_IMAGE} bash -c '
  source /opt/intel/oneapi/setvars.sh > /dev/null 2>&1 && \
  /llama.cpp/build/bin/llama-bench -m /input_dir/llama-2-13b-chat.Q4_K_M.gguf -pg 512,128 -t ${OMP_NUM_THREADS} -r 40 -o csv > /result_dir/testcase2_pg_results.csv'

TESTCASE_DIR="${ARTIFACT_LOCATION}/benchmarks-source/llama.cpp/ault23/llama-benchmarks/Q4_0"

srun sarus run \
  --mount=type=bind,source="$(dirname $MODEL_FILE)",destination="/input_dir" \
  --mount=type=bind,source="${TESTCASE_DIR}",destination="/result_dir" \
  --env OMP_NUM_THREADS=${OMP_NUM_THREADS} \
  --env CUDA_VISIBLE_DEVICES=${CUDA_VISIBLE_DEVICES} \
  ${DOCKER_REPOSITORY}:${DOCKER_IMAGE} bash -c '
  source /opt/intel/oneapi/setvars.sh > /dev/null 2>&1 && \
  /llama.cpp/build/bin/llama-bench -m /input_dir/llama-2-13b-chat.Q4_0.gguf -pg 512,128 -t ${OMP_NUM_THREADS} -r 40 -o csv > /result_dir/testcase2_pg_results.csv'

