#!/bin/bash
#SBATCH --job-name=benchmark_llama_Testcase1
#SBATCH --output=benchmark_llama_Testcase1.out
#SBATCH --error=benchmark_llama_Testcase1.err
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=72
#SBATCH --hint=nomultithread
#SBATCH --account=a-g200
#SBATCH --time=02:00:00
#SBATCH --uenv=prgenv-gnu/24.11:v1
#SBATCH --view=modules

ARTIFACT_LOCATION=${ARTIFACT_LOCATION:-${SCRATCH}/xaas-containers-artifact}

# Load necessary modules
module load cray-mpich/8.1.30 cmake/3.30.5 gcc/13.3.0 openblas/0.3.28 cuda/12.6.2

export OMP_NUM_THREADS=72

BIN_DIR="${ARTIFACT_LOCATION}/benchmarks-source/llama.cpp/clariden/build-scripts/testcase1"
TESTCASE_DIR="${ARTIFACT_LOCATION}/benchmarks-source/llama.cpp/clariden/llama-benchmarks/Q4_K_M"
MODEL_FILE="${ARTIFACT_LOCATION}/data/llama.cpp/llama-2-13b-chat.Q4_K_M.gguf"

mkdir -p "$TESTCASE_DIR"

cd ${BIN_DIR}/build/bin

CUDA_VISIBLE_DEVICES="0" ./llama-bench \
  -m ${MODEL_FILE} \
  -pg 512,128 \
  -t $OMP_NUM_THREADS \
  -r 40 \
  -o csv > ${TESTCASE_DIR}/testcase1_pg_results.csv

MODEL_FILE="${ARTIFACT_LOCATION}/data/llama.cpp/llama-2-13b-chat.Q4_0.gguf"
TESTCASE_DIR="${ARTIFACT_LOCATION}/benchmarks-source/llama.cpp/clariden/llama-benchmarks/Q4_0"

CUDA_VISIBLE_DEVICES="0" ./llama-bench \
  -m ${MODEL_FILE} \
  -pg 512,128 \
  -t $OMP_NUM_THREADS \
  -r 40 \
  -o csv > ${TESTCASE_DIR}/testcase1_pg_results.csv
