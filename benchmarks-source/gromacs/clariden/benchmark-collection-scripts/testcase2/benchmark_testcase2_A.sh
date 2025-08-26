#!/bin/bash

# Run the script from inside the container 
ARTIFACT_LOCATION=${ARTIFACT_LOCATION:-${SCRATCH}/xaas-containers-artifact}
STEPS=30000
#STEPS=300

TPR_FILE="${ARTIFACT_LOCATION}/data/gromacs/GROMACS_TestCaseA/ion_channel.tpr"
BENCH_DIR="${ARTIFACT_LOCATION}/benchmarks-source/gromacs/clariden/gromacs-benchmarks/TestcaseA_benchmarks/gromacs_testcase2_testcaseA/steps_${STEPS}"
GROMACS_BIN="/usr/local/gromacs/bin/gmx_mpi"

WARMUP_RUNS=2
BENCHMARK_RUNS=30
TOTAL_RUNS=$((WARMUP_RUNS + BENCHMARK_RUNS))

export OMP_NUM_THREADS=72
export CUDA_VISIBLE_DEVICES=0

mkdir -p "$BENCH_DIR"

for i in $(seq 1 $TOTAL_RUNS); do
    echo "Starting run $i..."
    RUN_DIR="$BENCH_DIR/run_${i}"
    mkdir -p "$RUN_DIR"
    cd "$RUN_DIR"

    ${GROMACS_BIN} mdrun -s ${TPR_FILE} -ntomp 72 -nsteps ${STEPS} -gpu_id 0 > mdrun_output.log 2>&1

    if [ "$i" -le "$WARMUP_RUNS" ]; then
        echo "Warm-up run $i completed. Deleting files..."
        rm -rf "$RUN_DIR"
    else
        echo "Benchmark run $i completed. Results saved."
    fi

    cd "$BENCH_DIR"
done

echo "All benchmarking runs completed."
