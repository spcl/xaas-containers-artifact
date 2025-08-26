#!/bin/bash

ARTIFACT_LOCATION=${ARTIFACT_LOCATION:-${SCRATCH}/xaas-containers-artifact}

pids=()

srun -A a-g200 --ntasks=1 --nodes=1 --partition=normal --ntasks-per-node=1 --cpus-per-task=72 --hint=nomultithread --time=00:30:00 --environment=${ARTIFACT_LOCATION}/benchmarks-source/gromacs/clariden/build-scripts/testcase2/environment.toml -o llama_xaas.o -e llama_xaas.e /bin/bash ${ARTIFACT_LOCATION}/benchmarks-source/gromacs/clariden/benchmark-collection-scripts/testcase2/benchmark_testcase2_A.sh &
pids+=($!)

srun -A a-g200 --ntasks=1 --nodes=1 --partition=normal --ntasks-per-node=1 --cpus-per-task=72 --hint=nomultithread --time=00:30:00 --environment=${ARTIFACT_LOCATION}/benchmarks-source/gromacs/clariden/build-scripts/testcase2/environment.toml -o llama_xaas.o -e llama_xaas.e /bin/bash ${ARTIFACT_LOCATION}/benchmarks-source/gromacs/clariden/benchmark-collection-scripts/testcase2/benchmark_testcase2_B.sh &
pids+=($!)

echo "Started ${#pids[@]} jobs with PIDs: ${pids[*]}"

# Wait for all jobs to complete
for pid in "${pids[@]}"; do
  wait $pid
  echo "Job with PID $pid completed"
done

echo "All jobs finished"
