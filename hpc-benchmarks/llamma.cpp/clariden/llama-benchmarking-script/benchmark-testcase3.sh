#!/bin/bash

# Script to run llama.cpp benchmarks for Testcase 2 inside the container environment
# Run this inside an srun container session:
# srun -A a-g200 --ntasks=1 --cpus-per-task=64 --hint=nomultithread --time=01:00:00 --environment=llamacpp-testcase3 --pty bash

# Set OpenMP threads
export OMP_NUM_THREADS=16

# Navigate to the benchmark binary directory (assuming you're in /llama.cpp/build/bin already)
cd /llama.cpp/build/bin

# Paths
MODEL_DIR="$SCRATCH/llama-builds/testcase0/llama.cpp/models/13B"
OUTPUT_DIR="$SCRATCH/llama-benchmarks"

# Create output directories
mkdir -p "$OUTPUT_DIR/Q4_K_M"
mkdir -p "$OUTPUT_DIR/Q4_0"

# Run benchmark for Q4_K_M
CUDA_VISIBLE_DEVICES=0 ./llama-bench \
  -m "$MODEL_DIR/llama-2-13b-chat.Q4_K_M.gguf" \
  -pg 512,128 \
  -t "$OMP_NUM_THREADS" \
  -r 40 \
  -o csv > "$OUTPUT_DIR/Q4_K_M/testcase3_pg_results.csv"

# Run benchmark for Q4_0
CUDA_VISIBLE_DEVICES=0 ./llama-bench \
  -m "$MODEL_DIR/llama-2-13b-chat.Q4_0.gguf" \
  -pg 512,128 \
  -t "$OMP_NUM_THREADS" \
  -r 40 \
  -o csv > "$OUTPUT_DIR/Q4_0/testcase3_pg_results.csv"