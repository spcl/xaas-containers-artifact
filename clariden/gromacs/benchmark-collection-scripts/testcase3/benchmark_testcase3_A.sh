#!/bin/bash

# Run the script from inside the container 
# To run the container: srun -A a-g200 --nodes=1 --ntasks-per-node=4 --cpus-per-task=64 --hint=nomultithread --time=01:00:00 --environment=testcase3-clariden  --pty bash

TPR_FILE="/users/ealnuaim/GROMACS_TestCaseA/ion_channel.tpr"
GROMACS_BIN="/usr/local/gromacs/bin/gmx_mpi"
BENCH_DIR="/users/ealnuaim/gromacs_benchmarks/TestcaseA_benchmarks/gromacs_testcase3_testcaseA"

WARMUP_RUNS=10
BENCHMARK_RUNS=30
TOTAL_RUNS=$((WARMUP_RUNS + BENCHMARK_RUNS))

export OMP_NUM_THREADS=64
export CUDA_VISIBLE_DEVICES=0
export HYDRA_LAUNCHER=fork

mkdir -p "$BENCH_DIR"


for i in $(seq 1 $TOTAL_RUNS); do
    echo "Starting run $i..."
    RUN_DIR="$BENCH_DIR/run_${i}"
    mkdir -p "$RUN_DIR"
    cd "$RUN_DIR"

    mpiexec -n 4 "$GROMACS_BIN" mdrun \
        -s "$TPR_FILE" \
        -ntomp 64 \
        -bonded gpu -nb gpu -pme gpu -pin on -v \
        -noconfout -dlb yes -nstlist 300 -gpu_id 0 -npme 1 -nsteps 300 \
        > mdrun_output.log 2>&1

    mv md.log ener.edr confout.gro state.cpt "$RUN_DIR/" 2>/dev/null || true

    if [ "$i" -le "$WARMUP_RUNS" ]; then
        echo "Warm-up run $i completed. Deleting files..."
        rm -rf "$RUN_DIR"
    else
        echo "Benchmark run $i completed. Results saved."
    fi

    cd "$BENCH_DIR"
done

echo "All benchmarking runs completed."