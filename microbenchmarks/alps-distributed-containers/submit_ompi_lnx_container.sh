#!/bin/bash

PARTITION=normal
TIME=00:20:00

cd results/ompi_container_lnx

container=ompi
pmi=pmix

srun --mpi=${pmi} -A a-g200 --cpu-bind=ldoms,verbose --ntasks=2 --nodes=1 --partition=${PARTITION} --ntasks-per-node=2 --environment=$(pwd)/../../submission/${container}-hook-lnx.toml --time=${TIME} -o ${container}-nohook-ldoms.out -e ${container}-nohook-ldoms.err /usr/local/libexec/osu-micro-benchmarks/mpi/pt2pt/osu_bw -z25,50,75,90,95,99 -i 10000 -x 10 &
pids+=($!)

srun --mpi=${pmi} -A a-g200 --cpu-bind=sockets,verbose --ntasks=2 --nodes=1 --partition=${PARTITION} --ntasks-per-node=2 --environment=$(pwd)/../../submission/${container}-hook-lnx.toml --time=${TIME} -o ${container}-nohook-sockets.out -e ${container}-nohook-sockets.err /usr/local/libexec/osu-micro-benchmarks/mpi/pt2pt/osu_bw -z25,50,75,90,95,99 -i 10000 -x 10 &
pids+=($!)

srun --mpi=${pmi} -A a-g200 --cpu-bind=map_cpu:1,2,verbose --ntasks=2 --nodes=1 --partition=${PARTITION} --ntasks-per-node=2 --environment=$(pwd)/../../submission/${container}-hook-lnx.toml --time=${TIME} -o ${container}-nohook-cores.out -e ${container}-nohook-cores.err /usr/local/libexec/osu-micro-benchmarks/mpi/pt2pt/osu_bw -z25,50,75,90,95,99 -i 10000 -x 10 &
pids+=($!)

echo "Started ${#pids[@]} jobs with PIDs: ${pids[*]}"

# Wait for all jobs to complete
for pid in "${pids[@]}"; do
    wait $pid
    echo "Job with PID $pid completed"
done

echo "All jobs finished"
