#!/bin/bash

cd benchmarks-collection-scripts

sbatch --exclude="ault[06-07,09-13,15,17-25,27-44]" < benchmark_gromacs_avx2_128_testcaseA.sh
sbatch --exclude="ault[06-07,09-13,15,17-25,27-44]" < benchmark_gromacs_avx2_128_testcaseB.sh
sbatch --exclude="ault[06-07,09-13,15,17-25,27-44]" < benchmark_gromacs_avx2_256_testcaseA.sh
sbatch --exclude="ault[06-07,09-13,15,17-25,27-44]" < benchmark_gromacs_avx2_256_testcaseB.sh
sbatch --exclude="ault[06-07,09-13,15,17-25,27-44]" < benchmark_gromacs_avx256_testcaseB.sh 
sbatch --exclude="ault[06-07,09-13,15,17-25,27-44]" < benchmark_gromacs_avx256_testcaseA.sh
sbatch --exclude="ault[06-07,09-13,15,17-25,27-44]" < benchmark_gromacs_avx512_testcaseA.sh
sbatch --exclude="ault[06-07,09-13,15,17-25,27-44]" < benchmark_gromacs_avx512_testcaseB.sh
sbatch --exclude="ault[06-07,09-13,15,17-25,27-44]" < benchmark_gromacs_sse41_testcaseB.sh 
sbatch --exclude="ault[06-07,09-13,15,17-25,27-44]" < benchmark_gromacs_sse41_testcaseA.sh

sbatch --exclude="ault[06-07,09-13,15,17-25,27-44]" < benchmark_gromacs_portable_testcaseA.sh
sbatch --exclude="ault[06-07,09-13,15,17-25,27-44]" < benchmark_gromacs_portable_testcaseB.sh

sbatch --exclude="ault[06-07,09-13,15,17-25,27-44]" < benchmark_gromacs_specialized_testcaseA.sh 
sbatch --exclude="ault[06-07,09-13,15,17-25,27-44]" < benchmark_gromacs_specialized_testcaseB.sh
