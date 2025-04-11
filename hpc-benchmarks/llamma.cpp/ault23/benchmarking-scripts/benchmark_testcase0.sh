#!/bin/bash
#SBATCH --job-name=llama_benchmark_pg         # More descriptive job name
#SBATCH --output=llama_pg_%j.out              # Standard output log
#SBATCH --error=llama_pg_%j.err               # Error log
#SBATCH --nodelist=ault23                     # Assign the job to a specific node
#SBATCH --ntasks=1                            # 1 MPI rank (not really needed here, but kept for clarity)
#SBATCH --cpus-per-task=64                    # CPUs allocated to the task
#SBATCH --time=1:00:00                        # Max wall time
#SBATCH --exclusive                           # Exclusive access to the node

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