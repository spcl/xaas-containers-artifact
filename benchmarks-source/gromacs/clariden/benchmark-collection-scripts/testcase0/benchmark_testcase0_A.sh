#!/bin/bash
#SBATCH --job-name=benchmark_gromacs_cpu
#SBATCH --output=gromacs_cpu_%j.out
#SBATCH --error=gromacs_cpu_%j.err
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=72
#SBATCH --hint=nomultithread
#SBATCH --account=a-g200
#SBATCH --time=01:00:00
#SBATCH --uenv=prgenv-gnu/24.11:v1
#SBATCH --view=modules

ARTIFACT_LOCATION=${ARTIFACT_LOCATION:-${SCRATCH}/xaas-containers-artifact}
STEPS=30000

# Load necessary modules
module load cray-mpich/8.1.30 cmake/3.30.5 gcc/13.3.0

# Set CPU threading environment
export OMP_NUM_THREADS=72
export GMX_FORCE_GPU_AWARE_MPI=0

source ${ARTIFACT_LOCATION}/benchmarks-source/gromacs/clariden/build-scripts/testcase0/install/bin/GMXRC

# Define paths
TPR_FILE="${ARTIFACT_LOCATION}/data/gromacs/GROMACS_TestCaseA/ion_channel.tpr"
BENCH_DIR="${ARTIFACT_LOCATION}/benchmarks-source/gromacs/clariden/gromacs-benchmarks/TestcaseA_benchmarks/gromacs_testcase0_testcaseA/steps_${STEPS}"
GROMACS_BIN="${ARTIFACT_LOCATION}/benchmarks-source/gromacs/clariden/build-scripts/testcase0/install/bin/gmx" 

mkdir -p "$BENCH_DIR"

WARMUP_RUNS=2
BENCHMARK_RUNS=30
TOTAL_RUNS=$((WARMUP_RUNS + BENCHMARK_RUNS))

echo "GROMACS configuration"
ldd ${GROMACS_BIN}
srun ${GROMACS_BIN} --version

for i in $(seq 1 $TOTAL_RUNS); do
    echo "Starting run $i..."

    RUN_DIR="$BENCH_DIR/run_${i}"
    mkdir -p "$RUN_DIR"
    cd "$RUN_DIR"

    srun "$GROMACS_BIN" mdrun -s "$TPR_FILE" -ntomp 72 -nsteps ${STEPS} > mdrun_output.log 2>&1

    #mv md.log ener.edr confout.gro state.cpt "$RUN_DIR/" 2>/dev/null || true

    if [ "$i" -le "$WARMUP_RUNS" ]; then
        echo "Warm-up run $i completed. Deleting files..."
        rm -rf "$RUN_DIR"
    else
        echo "Benchmark run $i completed. Results saved."
    fi

    cd "$BENCH_DIR"
done

echo "All CPU-only benchmarking runs completed."
