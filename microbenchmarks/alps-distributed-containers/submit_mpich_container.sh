#!/bin/bash

PARTITION=normal
TIME=00:20:00

mkdir -p results/mpich_container
cd results/mpich_container

container=mpich
pmi=pmi2

srun --mpi=${pmi} -A a-g200 --cpu-bind=ldoms,verbose --ntasks=2 --nodes=1 --partition=${PARTITION} --ntasks-per-node=2 --environment=$(pwd)/../../submission/${container}-hook.toml --time=${TIME} -o ${container}-hook-ldoms.out -e ${container}-hook-ldoms.err /usr/local/libexec/osu-micro-benchmarks/mpi/pt2pt/osu_bw -z25,50,75,90,95,99 -i 10000 -x 10 &
pids+=($!)

srun --mpi=${pmi} -A a-g200 --cpu-bind=sockets,verbose --ntasks=2 --nodes=1 --partition=${PARTITION} --ntasks-per-node=2 --environment=$(pwd)/../../submission/${container}-hook.toml --time=${TIME} -o ${container}-hook-sockets.out -e ${container}-hook-sockets.err /usr/local/libexec/osu-micro-benchmarks/mpi/pt2pt/osu_bw -z25,50,75,90,95,99 -i 10000 -x 10 &
pids+=($!)

srun --mpi=${pmi} -A a-g200 --cpu-bind=map_cpu:1,2,verbose --ntasks=2 --nodes=1 --partition=${PARTITION} --ntasks-per-node=2 --environment=$(pwd)/../../submission/${container}-hook.toml --time=${TIME} -o ${container}-hook-cores.out -e ${container}-hook-cores.err /usr/local/libexec/osu-micro-benchmarks/mpi/pt2pt/osu_bw -z25,50,75,90,95,99 -i 10000 -x 10 &
pids+=($!)

srun --mpi=${pmi} -A a-g200 --cpu-bind=ldoms,verbose --ntasks=2 --nodes=1 --partition=${PARTITION} --ntasks-per-node=2 --environment=$(pwd)/../../submission/${container}-nohook.toml --time=${TIME} -o ${container}-nohook-ldoms.out -e ${container}-nohook-ldoms.err /usr/local/libexec/osu-micro-benchmarks/mpi/pt2pt/osu_bw -z25,50,75,90,95,99 -i 10000 -x 10 &
pids+=($!)

srun --mpi=${pmi} -A a-g200 --cpu-bind=map_cpu:1,2,verbose --ntasks=2 --nodes=1 --partition=${PARTITION} --ntasks-per-node=2 --environment=$(pwd)/../../submission/${container}-nohook.toml --time=${TIME} -o ${container}-nohook-cores.out -e ${container}-nohook-cores.err /usr/local/libexec/osu-micro-benchmarks/mpi/pt2pt/osu_bw -z25,50,75,90,95,99 -i 10000 -x 10 &
pids+=($!)

srun --mpi=${pmi} -A a-g200 --cpu-bind=sockets,verbose --ntasks=2 --nodes=1 --partition=${PARTITION} --ntasks-per-node=2 --environment=$(pwd)/../../submission/${container}-nohook.toml --time=${TIME} -o ${container}-nohook-sockets.out -e ${container}-nohook-sockets.err /usr/local/libexec/osu-micro-benchmarks/mpi/pt2pt/osu_bw -z25,50,75,90,95,99 -i 10000 -x 10 &
pids+=($!)

echo "Started ${#pids[@]} jobs with PIDs: ${pids[*]}"

# Wait for all jobs to complete
for pid in "${pids[@]}"; do
    wait $pid
    echo "Job with PID $pid completed"
done

echo "All jobs finished"
