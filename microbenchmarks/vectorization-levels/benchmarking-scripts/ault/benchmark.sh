#!/bin/bash
#SBATCH --job-name=benchmark_gromacs_all_simd
#SBATCH --output=benchmark_simd_%j.out
#SBATCH --error=benchmark_simd_%j.err
#SBATCH --nodelist=ault23
#SBATCH --cpus-per-task=16
#SBATCH --gpus=1
#SBATCH --time=4:00:00
#SBATCH --exclusive

ARTIFACT_LOCATION=${ARTIFACT_LOCATION:-${SCRATCH}/xaas-containers-artifact}

# Load required modules
module load cuda/12.1.1 intel-oneapi-mpi/2021.3.0 intel-oneapi-mkl/2021.3.0

source ${ARTIFACT_LOCATION}/dependencies/spack/share/spack/setup-env.sh
spack load gcc@11.5
spack load gcc@11.5.0 arch=linux-centos8-zen

SIMD_BUILDS=("AVX2_128" "SSE2" "AVX_512" "SSE4.1" "SSE2" "None" "AVX_256")

# Benchmarking config
TPR_FILE="${ARTIFACT_LOCATION}/data/gromacs/GROMACS_TestCaseB/lignocellulose.tpr"
SIMD_ROOT="${ARTIFACT_LOCATION}/microbenchmarks/vectorization-levels/build-scripts/ault"
OUTPUT_DIRECTORY="${ARTIFACT_LOCATION}/microbenchmarks/vectorization-levels/benchmarks/intel/"

WARMUP_RUNS=10
BENCHMARK_RUNS=30
TOTAL_RUNS=$((WARMUP_RUNS + BENCHMARK_RUNS))

export OMP_NUM_THREADS=16
export CUDA_VISIBLE_DEVICES=0

# Loop over SIMD builds
for simd in "${SIMD_BUILDS[@]}"; do
    echo "===== Starting benchmarks for SIMD: $simd ====="

    GMX_BINARY="${SIMD_ROOT}/${simd}/install/bin/gmx"
    OUT_DIR="${OUTPUT_DIRECTORY}/${simd}"
    mkdir -p "$OUT_DIR"

    for i in $(seq 1 $TOTAL_RUNS); do
        echo "[$simd] Starting run $i..."

        RUN_DIR="$OUT_DIR/run${i}"
        mkdir -p "$RUN_DIR"

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

echo "All SIMD benchmarking runs are complete!"
