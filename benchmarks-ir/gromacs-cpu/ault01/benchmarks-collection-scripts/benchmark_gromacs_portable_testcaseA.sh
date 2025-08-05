#!/bin/bash
#SBATCH --job-name=benchmark_gromacs   # Job name
#SBATCH --output=gromacs%j.portable.out        # Save output log
#SBATCH --error=gromacs%j.portable.err
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --nodes=1
#SBATCH --time=4:00:00
#SBATCH --exclusive

ARTIFACT_LOCATION=${ARTIFACT_LOCATION:-${SCRATCH}/xaas-containers-artifact}
DOCKER_REPOSITORY=${DOCKER_REPOSITORY:-"spcleth/xaas-artifact"}
STEPS=200

module load sarus/1.6

export OMP_NUM_THREADS=${SLURM_CPUS_PER_TASK}

# Define paths (on host)
ARCH_TYPE="portable"
TESTCASE_DIR="${ARTIFACT_LOCATION}/benchmarks-ir/gromacs-cpu/ault01/gromacs-benchmarks/TestcaseA_benchmarks/gromacs_${ARCH_TYPE}_testcaseA/steps_${STEPS}"
TPR_FILE="${ARTIFACT_LOCATION}/data/gromacs/GROMACS_TestCaseA/ion_channel.tpr"
CONTAINER_IMAGE="${DOCKER_REPOSITORY}:gromacs-ir-portable-container"

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
    /build/bin/gmx mdrun -s \"/input_dir/ion_channel.tpr\" -ntomp ${OMP_NUM_THREADS} -ntmpi 1 -nsteps ${STEPS} > \"/scratch/run${i}/mdrun_output.log\" 2>&1"
 
    if [ "$i" -le "$WARMUP_RUNS" ]; then
        echo "Warm-up run $i completed. Deleting files..."
        rm -rf "$RUN_DIR"
    else
        echo "Benchmark run $i completed. Data saved in $RUN_DIR."
    fi
done

echo "All benchmarking runs are complete!"
