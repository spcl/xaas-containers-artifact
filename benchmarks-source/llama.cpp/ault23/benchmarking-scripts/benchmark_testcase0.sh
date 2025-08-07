#!/bin/bash
#SBATCH --job-name=llama_benchmark_pg         # More descriptive job name
#SBATCH --output=llama_pg_%j.out              # Standard output log
#SBATCH --error=llama_pg_%j.err               # Error log
#SBATCH --nodelist=ault23                     # Assign the job to a specific node
#SBATCH --ntasks=1                            # 1 MPI rank (not really needed here, but kept for clarity)
#SBATCH --cpus-per-task=64                    # CPUs allocated to the task
#SBATCH --time=1:00:00                        # Max wall time
#SBATCH --exclusive                           # Exclusive access to the node

ARTIFACT_LOCATION=${ARTIFACT_LOCATION:-${SCRATCH}/xaas-containers-artifact}

# Set OpenMP threads (adjust if llama.cpp uses OMP)
export OMP_NUM_THREADS=64

BIN_DIR="${ARTIFACT_LOCATION}/benchmarks-source/llama.cpp/ault23/build-scripts/testcase0"
TESTCASE_DIR="${ARTIFACT_LOCATION}/benchmarks-source/llama.cpp/ault23/llama-benchmarks/Q4_K_M"
MODEL_FILE="${ARTIFACT_LOCATION}/data/llama.cpp/llama-2-13b-chat.Q4_K_M.gguf"

mkdir -p "$TESTCASE_DIR"

cd ${BIN_DIR}/build/bin

./llama-bench \
  -m ${MODEL_FILE} \
  -pg 512,128 \
  -t $OMP_NUM_THREADS \
  -r 40 \
  -o csv > ${TESTCASE_DIR}/testcase0_pg_results.csv

MODEL_FILE="${ARTIFACT_LOCATION}/data/llama.cpp/llama-2-13b-chat.Q4_0.gguf"
TESTCASE_DIR="${ARTIFACT_LOCATION}/benchmarks-source/llama.cpp/ault23/llama-benchmarks/Q4_0"

./llama-bench \
  -m ${MODEL_FILE} \
  -pg 512,128 \
  -t $OMP_NUM_THREADS \
  -r 40 \
  -o csv > ${TESTCASE_DIR}/testcase0_pg_results.csv
