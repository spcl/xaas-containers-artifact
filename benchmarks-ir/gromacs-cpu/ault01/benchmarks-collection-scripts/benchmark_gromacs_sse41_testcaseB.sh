#!/bin/bash
#SBATCH --job-name=benchmark_gromacs   # Job name
#SBATCH --output=gromacs%j.SSE4.1.out        # Save output log
#SBATCH --error=gromacs%j.SSE4.1.err         # Save error log
#SBATCH --ntasks=1                        # 4 MPI processes
#SBATCH --nodes=1                        # 4 MPI processes
#SBATCH --cpus-per-task=36                        # 4 MPI processes
#SBATCH --time=4:00:00                    # Max time limit
#SBATCH --exclusive                       # Ensures no other jobs run on this node

module load sarus/1.6

ARTIFACT_LOCATION=${ARTIFACT_LOCATION:-${SCRATCH}/xaas-containers-artifact}
DOCKER_REPOSITORY=${DOCKER_REPOSITORY:-"spcleth/xaas-artifact"}
STEPS=200

export OMP_NUM_THREADS=${SLURM_CPUS_PER_TASK}

# Define paths (on host)
ARCH_TYPE="SSE4.1"
TESTCASE_DIR="${ARTIFACT_LOCATION}/benchmarks-ir/gromacs-cpu/ault01/gromacs-benchmarks/TestcaseB_benchmarks/gromacs_${ARCH_TYPE}_testcaseB/steps_${STEPS}"
TPR_FILE="${ARTIFACT_LOCATION}/data/gromacs/GROMACS_TestCaseB/lignocellulose.tpr"
CONTAINER_IMAGE="${DOCKER_REPOSITORY}:gromacs-deploy-_${ARCH_TYPE}"

mkdir -p "$TESTCASE_DIR"

WARMUP_RUNS=2
BENCHMARK_RUNS=30
TOTAL_RUNS=$((WARMUP_RUNS + BENCHMARK_RUNS))

echo ${OMP_NUM_THREADS}
echo "Hostname: $(hostname)"

for i in $(seq 1 $TOTAL_RUNS); do
    echo "Starting run $i..."

    RUN_DIR="$TESTCASE_DIR/run${i}"
    LOG_FILE="$RUN_DIR/mdrun_output.log"

    mkdir -p "$RUN_DIR"

    sarus run \
    --mount=type=bind,source="${TESTCASE_DIR}",destination="/scratch" \
    --mount=type=bind,source="$(dirname $TPR_FILE)",destination="/input_dir" \
    --env OMP_NUM_THREADS=${OMP_NUM_THREADS} \
    ${CONTAINER_IMAGE} /bin/bash -c " \
    export OMP_NUM_THREADS=${OMP_NUM_THREADS} && \
    export OMP_PLACES=cores && \
    mkdir -p \"/scratch/run${i}\" && \
    cd \"/scratch/run${i}\" && \
    /build/bin/gmx mdrun -s \"/input_dir/lignocellulose.tpr\" -ntomp ${OMP_NUM_THREADS} -ntmpi 1 -nsteps ${STEPS} > \"/scratch/run${i}/mdrun_output.log\" 2>&1"
 
    if [ "$i" -le "$WARMUP_RUNS" ]; then
        echo "Warm-up run $i completed. Deleting files..."
        rm -rf "$RUN_DIR"
    else
        echo "Benchmark run $i completed. Data saved in $RUN_DIR."
    fi
done

echo "All benchmarking runs are complete!"
