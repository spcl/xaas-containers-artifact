#!/bin/bash
#PBS -A workflow_scaling
#PBS -N llama_xaas_tests
#PBS -l walltime=00:60:00
#PBS -l filesystems=flare
#PBS -q debug

# FIXME: adapt for your configuration
#module load apptainer
#module load fuse-overlayfs
module unload oneapi
source $HOME/intel/oneapi/setvars.sh

# FIXME: adapt for your configuration
export OMP_NUM_THREADS=102  # Use 102 OpenMP threads

# FIXME: change the path for the output of the result
TESTCASE_DIR="$HOME/xaas-containers-artifact/hpc-benchmarks/llama.cpp/aurora/llama-benchmarks/llamacpp-native/"

LLAMA_DIR="$HOME/xaas-containers/builds/llama.cpp"
MODEL_DIR="$HOME/xaas-containers/data"

mkdir -p $TESTCASE_DIR

# Run the benchmark
$LLAMA_DIR/build/bin/llama-bench \
  -m $MODEL_DIR/llama-2-13b-chat.Q4_K_M.gguf \
  -pg 512,128 \
  -t $OMP_NUM_THREADS \
  -r 40 \
  -o csv > $TESTCASE_DIR/testcase0_pg_results.csv
