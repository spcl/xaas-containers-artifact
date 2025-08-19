#/bin/bash

job1=$(qsub native/benchmark_gromacs.sh)
echo "Running native benchmark, job: $job1"

job2=$(qsub -W depend=afterok:${job1} container-specialized/benchmark_gromacs.sh)
echo "Running container specialized, job: $job2"

job3=$(qsub -W depend=afterok:${job2} source-container/benchmark_gromacs.sh)
echo "Running source container, job: $job3"

job4=$(qsub -W depend=afterok:${job3} source-container-gpu/benchmark_gromacs.sh)
echo "Running source container gpu, job: $job4"

