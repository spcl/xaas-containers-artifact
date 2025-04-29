#!/bin/bash
#SBATCH --job-name=benchmark_gromacs
#SBATCH --output=gromacs_%j.out
#SBATCH --error=gromacs_%j.err
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=4              # 4 MPI ranks per node
#SBATCH --cpus-per-task=64                # 64 threads per rank
#SBATCH --hint=nomultithread
#SBATCH --account=a-g200
#SBATCH --time=04:00:00

#SBATCH --uenv=prgenv-gnu/24.11:v1
#SBATCH --view=modules

# Load necessary modules inside the uenv
module load cray-mpich/8.1.30 cuda/12.6.2 cmake/3.30.5 gcc/13.3.0

# Set required environment variables for GROMACS + GH200
export MPICH_GPU_SUPPORT_ENABLED=1
export FI_CXI_RX_MATCH_MODE=software
export GMX_GPU_DD_COMMS=true
export GMX_GPU_PME_PP_COMMS=true
export GMX_FORCE_UPDATE_DEFAULT_GPU=true
export GMX_ENABLE_DIRECT_GPU_COMM=1
export GMX_FORCE_GPU_AWARE_MPI=1

# Define paths
TPR_FILE="$HOME/GROMACS_TestCaseB/lignocellulose.tpr"
MPS_WRAPPER="$HOME/mps-wrapper.sh"
GROMACS_ROOT="$HOME/testcase1"

mkdir -p "$HOME/gromacs_benchmarks/TestcaseB_benchmarks"
chmod +x "$MPS_WRAPPER"

WARMUP_RUNS=10
BENCHMARK_RUNS=30
TOTAL_RUNS=$((WARMUP_RUNS + BENCHMARK_RUNS))

# List of SIMD builds to test
SIMD_LEVELS=("ARM_SVE" "ARM_NEON_ASIMD")

for SIMD in "${SIMD_LEVELS[@]}"; do
    echo "Starting benchmarking for SIMD: $SIMD..."

    GROMACS_BIN="${GROMACS_ROOT}/gromacs-2025.0-install-${SIMD}/bin/gmx_mpi"
    BENCH_DIR="$HOME/gromacs_benchmarks/TestcaseB_benchmarks/gromacs_${SIMD}_testcaseB"

    mkdir -p "$BENCH_DIR"

    for i in $(seq 1 $TOTAL_RUNS); do
        echo "Run $i for $SIMD..."

        RUN_DIR="$BENCH_DIR/run_${i}"
        mkdir -p "$RUN_DIR"
        cd "$RUN_DIR"

        srun --cpu-bind=socket "$MPS_WRAPPER" "$GROMACS_BIN" mdrun \
            -s "$TPR_FILE" \
            -ntomp 64 \
            -bonded gpu \
            -nb gpu \
            -pin on \
            -v \
            -noconfout \
            -dlb yes \
            -nstlist 300 \
            -gpu_id 0 \
            -nsteps 300 > mdrun_output.log 2>&1

        mv md.log ener.edr confout.gro state.cpt "$RUN_DIR/" 2>/dev/null || true

        if [ "$i" -le "$WARMUP_RUNS" ]; then
            echo "Warm-up run $i completed for $SIMD. Deleting files..."
            rm -rf "$RUN_DIR"
        else
            echo "Benchmark run $i completed for $SIMD. Results saved."
        fi

        cd "$BENCH_DIR"
    done

    echo "Completed all runs for SIMD: $SIMD."
done

echo "All benchmarking runs completed for all SIMD levels."