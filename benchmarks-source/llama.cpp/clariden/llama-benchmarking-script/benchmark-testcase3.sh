#!/bin/bash

# Script to run llama.cpp benchmarks for Testcase 2 inside the container environment
# Run this inside an srun container session:
# srun -A a-g200 --ntasks=1 --cpus-per-task=64 --hint=nomultithread --time=01:00:00 --environment=llamacpp-testcase3 --pty bash

ARTIFACT_LOCATION=${ARTIFACT_LOCATION:-${SCRATCH}/xaas-containers-artifact}

export OMP_NUM_THREADS=72

BIN_DIR="/source/build/bin/"
TESTCASE_DIR="${ARTIFACT_LOCATION}/benchmarks-source/llama.cpp/clariden/llama-benchmarks/Q4_K_M"
MODEL_FILE="${ARTIFACT_LOCATION}/data/llama.cpp/llama-2-13b-chat.Q4_K_M.gguf"

mkdir -p "$OUTPUT_DIR/Q4_K_M"
mkdir -p "$OUTPUT_DIR/Q4_0"

cd ${BIN_DIR}

CUDA_VISIBLE_DEVICES=0 ./llama-bench \
  -m ${MODEL_FILE} \
  -pg 512,128 \
  -t "$OMP_NUM_THREADS" \
  -r 40 \
  -o csv > "${TESTCASE_DIR}/testcase3_pg_results.csv"

MODEL_FILE="${ARTIFACT_LOCATION}/data/llama.cpp/llama-2-13b-chat.Q4_0.gguf"
TESTCASE_DIR="${ARTIFACT_LOCATION}/benchmarks-source/llama.cpp/clariden/llama-benchmarks/Q4_0"

CUDA_VISIBLE_DEVICES=0 ./llama-bench \
  -m ${MODEL_FILE} \
  -pg 512,128 \
  -t "$OMP_NUM_THREADS" \
  -r 40 \
  -o csv > "${TESTCASE_DIR}/testcase3_pg_results.csv"
