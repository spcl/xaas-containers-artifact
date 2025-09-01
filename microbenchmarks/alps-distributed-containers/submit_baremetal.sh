#!/bin/bash

PARTITION=normal
TIME=00:20:00

mkdir -p results/baremetal2
cd results/baremetal2

pids=()

## MPI

# no container, standard execution
srun -A a-g200 --cpu-bind=ldoms,verbose --ntasks=2 --nodes=1 --partition=${PARTITION} --ntasks-per-node=2 --time=${TIME} -o mpich_ldoms.out -e mpich_ldoms.err ../../osu-install/libexec/osu-micro-benchmarks/mpi/pt2pt/osu_bw -z25,50,75,90,95,99 -i 10000 -x 10 &
pids+=($!)

srun -A a-g200 --cpu-bind=sockets,verbose --ntasks=2 --nodes=1 --partition=${PARTITION} --ntasks-per-node=2 --time=${TIME} -o mpich_sockets.out -e mpich_sockets.err ../../osu-install/libexec/osu-micro-benchmarks/mpi/pt2pt/osu_bw -z25,50,75,90,95,99 -i 10000 -x 10 &
pids+=($!)

srun -A a-g200 --cpu-bind=map_cpu:1,2,verbose --ntasks=2 --nodes=1 --partition=${PARTITION} --ntasks-per-node=2 --time=${TIME} -o mpich_cores.out -e mpich_cores.err ../../osu-install/libexec/osu-micro-benchmarks/mpi/pt2pt/osu_bw -z25,50,75,90,95,99 -i 10000 -x 10 &
pids+=($!)

# no container, no local
#MPICH_NO_LOCAL=1 srun -A a-g200 --cpu-bind=ldoms,verbose --ntasks=2 --nodes=1 --partition=${PARTITION} --ntasks-per-node=2 --time=${TIME} -o mpich_no_local.out -e mpich_no_local.err ../osu-7.5/libexec/osu-micro-benchmarks/mpi/pt2pt/osu_bw -z25,50,75,90,95,99 -i 10000 -x 1 &
#pids+=($!)

echo "Started ${#pids[@]} jobs with PIDs: ${pids[*]}"

# Wait for all jobs to complete
for pid in "${pids[@]}"; do
    wait $pid
    echo "Job with PID $pid completed"
done

echo "All jobs finished"
