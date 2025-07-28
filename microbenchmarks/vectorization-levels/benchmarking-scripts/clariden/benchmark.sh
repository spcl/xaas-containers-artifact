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

ARTIFACT_LOCATION=${ARTIFACT_LOCATION:-${SCRATCH}/xaas-containers-artifact}

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
TPR_FILE="${ARTIFACT_LOCATION}/data/gromacs/GROMACS_TestCaseB/lignocellulose.tpr"
SIMD_ROOT="${ARTIFACT_LOCATION}/microbenchmarks/vectorization-levels/build-scripts/clariden"
OUTPUT_DIRECTORY="${ARTIFACT_LOCATION}/microbenchmarks/vectorization-levels/benchmarks/arm/"

WARMUP_RUNS=10
BENCHMARK_RUNS=30
TOTAL_RUNS=$((WARMUP_RUNS + BENCHMARK_RUNS))

# List of SIMD builds to test
SIMD_LEVELS=("None" "SVE" "NEON_ASIMD")

# Loop over SIMD builds
for simd in "${SIMD_LEVELS[@]}"; do
    echo "===== Starting benchmarks for SIMD: $simd ====="

    GMX_BINARY="${SIMD_ROOT}/${simd}/install/bin/gmx"
    OUT_DIR="${OUTPUT_DIRECTORY}/${simd}"
    mkdir -p "$OUT_DIR"

    for i in $(seq 1 $TOTAL_RUNS); do
        echo "[$simd] Starting run $i..."

        RUN_DIR="$OUT_DIR/run${i}"
        mkdir -p "$RUN_DIR"

	# -ntomp 64 -pin on -v -noconfout -dlb yes -nstlist 300 -nsteps 300
        #"$GMX_BINARY" mdrun -s "$TPR_FILE" -ntmpi 1 -ntomp 64 -nsteps 100 > "$RUN_DIR/mdrun_output.log" 2>&1
        "$GMX_BINARY" mdrun -s "$TPR_FILE" -ntmpi 1 -ntomp 16 -nsteps 100 > "$RUN_DIR/mdrun_output.log" 2>&1

        mv md.log traj* ener.edr confout.gro state.cpt "$RUN_DIR/" 2>/dev/null

        if [ "$i" -le "$WARMUP_RUNS" ]; then
            echo "[$simd] Warm-up run $i completed. Deleting..."
            rm -rf "$RUN_DIR"
        else
            echo "[$simd] Benchmark run $i completed."
        fi
    done

    echo "===== Completed SIMD: $simd ====="
done


echo "All benchmarking runs completed for all SIMD levels."
