#!/bin/bash
#SBATCH --job-name=benchmark_gromacs
#SBATCH --output=gromacs_%j.out
#SBATCH --error=gromacs_%j.err
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=72
#SBATCH --hint=nomultithread
#SBATCH --account=a-g200
#SBATCH --time=04:00:00
#SBATCH --uenv=prgenv-gnu/24.11:v1
#SBATCH --view=modules

ARTIFACT_LOCATION=${ARTIFACT_LOCATION:-${SCRATCH}/xaas-containers-artifact}
STEPS=3000
#STEPS=300

source ${ARTIFACT_LOCATION}/dependencies/spack/share/spack/setup-env.sh
spack env activate gromacs_advanced
spack load gromacs@2024.4
source GMXRC

# Set required environment variables for GROMACS + GH200
export MPICH_GPU_SUPPORT_ENABLED=1
export FI_CXI_RX_MATCH_MODE=software
export GMX_GPU_DD_COMMS=true
export GMX_GPU_PME_PP_COMMS=true
export GMX_FORCE_UPDATE_DEFAULT_GPU=true

# Define paths
TPR_FILE="${ARTIFACT_LOCATION}/data/gromacs/GROMACS_TestCaseB/lignocellulose.tpr"
BENCH_DIR="${ARTIFACT_LOCATION}/benchmarks-source/gromacs/clariden/gromacs-benchmarks/TestcaseB_benchmarks/gromacs_testcase5_testcaseB/steps_${STEPS}"
GROMACS_BIN="gmx_mpi" 

mkdir -p "$BENCH_DIR"

WARMUP_RUNS=2
BENCHMARK_RUNS=30
TOTAL_RUNS=$((WARMUP_RUNS + BENCHMARK_RUNS))

echo "GROMACS configuration"
ldd $(which ${GROMACS_BIN})
srun ${GROMACS_BIN} --version

for i in $(seq 1 $TOTAL_RUNS); do
    echo "Starting run $i..."

    RUN_DIR="$BENCH_DIR/run_${i}"
    mkdir -p "$RUN_DIR"
    cd "$RUN_DIR"

    #srun --cpu-bind=socket "$GROMACS_BIN" mdrun -s "$TPR_FILE" -ntomp 72 -gpu_id 0 -nsteps 300 > mdrun_output.log 2>&1
    #srun --cpu-bind=cores "$GROMACS_BIN" mdrun -s "$TPR_FILE" -ntomp 72 -gpu_id 0 -nsteps 300 > mdrun_output.log 2>&1
    srun "$GROMACS_BIN" mdrun -s "$TPR_FILE" -ntomp 72 -gpu_id 0 -nsteps ${STEPS} > mdrun_output.log 2>&1

    #mv md.log ener.edr confout.gro state.cpt "$RUN_DIR/" 2>/dev/null || true

    if [ "$i" -le "$WARMUP_RUNS" ]; then
        echo "Warm-up run $i completed. Deleting files..."
        rm -rf "$RUN_DIR"
    else
        echo "Benchmark run $i completed. Results saved."
    fi

    cd "$BENCH_DIR"
done

echo "All benchmarking runs completed."
