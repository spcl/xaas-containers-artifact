#!/bin/bash
#PBS -A workflow_scaling
#PBS -N llama_xaas_tests
#PBS -l walltime=00:60:00
#PBS -l filesystems=flare
#PBS -q prod

ARTIFACT_LOCATION=${ARTIFACT_LOCATION:-${HOME}/xaas-containers-artifact}

# FIXME: adapt for your configuration
module load apptainer
module load fuse-overlayfs

# FIXME: adapt for your configuration
export OMP_NUM_THREADS=102  # Use 102 OpenMP threads

# FIXME: change the path for the output of the result
TESTCASE_DIR="${ARTIFACT_LOCATION}/benchmarks-source/llama.cpp/aurora/llama-benchmarks/Q4_K_M/"

LLAMA_DIR="/source"
MODEL_FILE="${ARTIFACT_LOCATION}/data/llama.cpp/llama-2-13b-chat.Q4_K_M.gguf"

CONTAINER_PATH="${ARTIFACT_LOCATION}/data/gromacs/images/"

mkdir -p $TESTCASE_DIR

# Run the benchmark
apptainer exec ${CONTAINER_PATH}/source-llamacpp-aurora.sing $LLAMA_DIR/build/bin/llama-bench \
  -m ${MODEL_FILE} \
  -pg 512,128 \
  -t $OMP_NUM_THREADS \
  -r 40 \
  -o csv > $TESTCASE_DIR/testcase1_pg_results.csv
