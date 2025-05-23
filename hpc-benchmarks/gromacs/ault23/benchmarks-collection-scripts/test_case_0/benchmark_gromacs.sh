#!/bin/bash
#SBATCH --job-name=benchmark_gromacs   # Job name
#SBATCH --output=gromacs_%j.out        # Save output log
#SBATCH --error=gromacs_%j.err         # Save error log
#SBATCH --nodelist=ault23                # Assign the job to ault23
#SBATCH --cpus-per-task=16                # 16 OpenMP threads
#SBATCH --gpus=1                          # Request 1 GPU
#SBATCH --time=4:00:00                    # Max time limit (adjust as needed)
#SBATCH --exclusive                       # Ensures no other jobs run on this node

# Load required modules
module load cuda/12.1.1 intel-oneapi-mpi/2021.3.0 intel-oneapi-mkl/2021.3.0

# Source the GROMACS binary
source $HOME/naive_build/gromacs-2025.0/bin/GMXRC

# Set environment variables
export OMP_NUM_THREADS=16  # Use 16 OpenMP threads
export CUDA_VISIBLE_DEVICES=0  # Ensure GPU visibility

# Define paths
TESTCASE_DIR="$HOME/benchmarks_phase1/TestcaseB_benchmarks/gromacs_naive_testcaseB"
TPR_FILE="$HOME/GROMACS_TestCaseB/lignocellulose.tpr"

mkdir -p "$TESTCASE_DIR"


WARMUP_RUNS=10
BENCHMARK_RUNS=30
TOTAL_RUNS=$((WARMUP_RUNS + BENCHMARK_RUNS))

for i in $(seq 1 $TOTAL_RUNS); do
    echo "Starting run $i..."

    RUN_DIR="$TESTCASE_DIR/run${i}"
    mkdir -p "$RUN_DIR"

    gmx mdrun -s "$TPR_FILE" -ntmpi 1 -ntomp 16 -nsteps 100 > "$RUN_DIR/mdrun_output.log" 2>&1

 
    mv md.log traj* ener.edr confout.gro state.cpt "$RUN_DIR/" 2>/dev/null

    if [ "$i" -le "$WARMUP_RUNS" ]; then
        echo "Warm-up run $i completed. Deleting files..."
        rm -rf "$RUN_DIR"
    else
        echo "Benchmark run $i completed. Data saved in $RUN_DIR."
    fi
done

echo "All benchmarking runs are complete!"