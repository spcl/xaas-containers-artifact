#!/bin/bash
#PBS -A workflow_scaling
#PBS -N llama_xaas_tests
#PBS -l walltime=00:60:00
#PBS -l filesystems=flare
#PBS -q debug

ARTIFACT_LOCATION=${ARTIFACT_LOCATION:-${HOME}/xaas-containers-artifact}

# FIXME: adapt for your configuration
export OMP_NUM_THREADS=102  # Use 102 OpenMP threads

TESTCASE_DIR="${ARTIFACT_LOCATION}/benchmarks-source/llama.cpp/aurora/llama-benchmarks/Q4_K_M/"

LLAMA_DIR="${ARTIFACT_LOCATION}/benchmarks-source/llama.cpp/aurora/build_scripts/naive/llama.cpp"
MODEL_FILE="${ARTIFACT_LOCATION}/data/llama.cpp/llama-2-13b-chat.Q4_K_M.gguf"

mkdir -p $TESTCASE_DIR

# Run the benchmark
$LLAMA_DIR/build/bin/llama-bench \
  -m ${MODEL_FILE} \
  -pg 512,128 \
  -t $OMP_NUM_THREADS \
  -r 40 \
  -o csv > $TESTCASE_DIR/testcase2_pg_results.csv
