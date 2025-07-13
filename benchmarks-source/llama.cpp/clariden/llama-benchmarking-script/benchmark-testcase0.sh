#!/bin/bash
#SBATCH --job-name=benchmark_llama_Testcase0
#SBATCH --output=benchmark_llama_Testcase0.out
#SBATCH --error=benchmark_llama_Testcase0.err
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=4              # Single non-MPI rank
#SBATCH --cpus-per-task=64               # Use 64 threads
#SBATCH --hint=nomultithread
#SBATCH --account=a-g200
#SBATCH --time=02:00:00

#SBATCH --uenv=prgenv-gnu/24.11:v1
#SBATCH --view=modules

# Load necessary modules
module load cray-mpich/8.1.30 cmake/3.30.5 gcc/13.3.0 openblas/0.3.28 cuda/12.6.2


# Set OpenMP threads (adjust if llama.cpp uses OMP)
export OMP_NUM_THREADS=16

# Create output directory if it doesn't exist
mkdir -p $SCRATCH/llama-benchmarks

# Navigate to the build directory
cd $SCRATCH/llama-builds/testcase0/llama.cpp/build/bin

# Run the benchmark
./llama-bench \
  -m $SCRATCH/llama-builds/testcase0/llama.cpp/models/13B/llama-2-13b-chat.Q4_K_M.gguf \
  -pg 512,128 \
  -t $OMP_NUM_THREADS \
  -r 40 \
  -o csv > $SCRATCH/llama-benchmarks/Q4_K_M/testcase0_pg_results.csv


  # Run the benchmark
./llama-bench \
  -m $SCRATCH/llama-builds/testcase0/llama.cpp/models/13B/llama-2-13b-chat.Q4_0.gguf \
  -pg 512,128 \
  -t $OMP_NUM_THREADS \
  -r 40 \
  -o csv > $SCRATCH/llama-benchmarks/Q4_0/testcase0_pg_results.csv