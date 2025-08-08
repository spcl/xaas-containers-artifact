#!/bin/bash

ARTIFACT_LOCATION=${ARTIFACT_LOCATION:-${SCRATCH}/xaas-containers-artifact}

pids=()

srun -A a-g200  --ntasks=1 --nodes=1 --partition=normal --ntasks-per-node=1 --cpus-per-task=72 --hint=nomultithread --time=00:30:00 --environment=/iopsstor/scratch/cscs/mcopik/xaas-containers-artifact/benchmarks-source/llama.cpp/clariden/build-scripts/testcase3/environment.toml -o llama_xaas.o -e llama_xaas.e /bin/bash ${ARTIFACT_LOCATION}/benchmarks-source/llama.cpp/clariden/llama-benchmarking-script/benchmark-testcase3.sh &
pids+=($!)

srun -A a-g200  --ntasks=1 --nodes=1 --partition=normal --ntasks-per-node=1 --cpus-per-task=72 --hint=nomultithread --time=00:30:00 --environment=/iopsstor/scratch/cscs/mcopik/xaas-containers-artifact/benchmarks-source/llama.cpp/clariden/build-scripts/testcase2/environment.toml -o llama_specialized.o -e llama_specialized.e /bin/bash ${ARTIFACT_LOCATION}/benchmarks-source/llama.cpp/clariden/llama-benchmarking-script/benchmark-testcase2.sh &
pids+=($!)

echo "Started ${#pids[@]} jobs with PIDs: ${pids[*]}"

# Wait for all jobs to complete
for pid in "${pids[@]}"; do
    wait $pid
    echo "Job with PID $pid completed"
done

echo "All jobs finished"
