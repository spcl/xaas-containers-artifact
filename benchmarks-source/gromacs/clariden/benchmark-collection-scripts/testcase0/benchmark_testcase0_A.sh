#!/bin/bash
#SBATCH --job-name=benchmark_gromacs_cpu
#SBATCH --output=gromacs_cpu_%j.out
#SBATCH --error=gromacs_cpu_%j.err
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=4              # Single non-MPI rank
#SBATCH --cpus-per-task=64               # Use 64 threads
#SBATCH --hint=nomultithread
#SBATCH --account=a-g200
#SBATCH --time=04:00:00

#SBATCH --uenv=prgenv-gnu/24.11:v1
#SBATCH --view=modules

# Load necessary modules
module load cray-mpich/8.1.30 cmake/3.30.5 gcc/13.3.0

# Set CPU threading environment
export OMP_NUM_THREADS=64
export GMX_FORCE_GPU_AWARE_MPI=0

# Define paths
TPR_FILE="/users/ealnuaim/GROMACS_TestCaseA/ion_channel.tpr"
BENCH_DIR="$HOME/gromacs_benchmarks/TestcaseA_benchmarks/gromacs_testcase0_testcaseA"
GROMACS_BIN="$HOME/testcase0/gromacs-2025.0/build/bin/gmx"  # non-MPI, non-GPU binary

mkdir -p "$BENCH_DIR"

WARMUP_RUNS=10
BENCHMARK_RUNS=30
TOTAL_RUNS=$((WARMUP_RUNS + BENCHMARK_RUNS))

for i in $(seq 1 $TOTAL_RUNS); do
    echo "Starting run $i..."

    RUN_DIR="$BENCH_DIR/run_${i}"
    mkdir -p "$RUN_DIR"
    cd "$RUN_DIR"

    "$GROMACS_BIN" mdrun -s "$TPR_FILE" -ntomp 64 -pin on -v -noconfout -dlb yes -nstlist 300 -nsteps 300 > mdrun_output.log 2>&1

    mv md.log ener.edr confout.gro state.cpt "$RUN_DIR/" 2>/dev/null || true

    if [ "$i" -le "$WARMUP_RUNS" ]; then
        echo "Warm-up run $i completed. Deleting files..."
        rm -rf "$RUN_DIR"
    else
        echo "Benchmark run $i completed. Results saved."
    fi

    cd "$BENCH_DIR"
done

echo "All CPU-only benchmarking runs completed."