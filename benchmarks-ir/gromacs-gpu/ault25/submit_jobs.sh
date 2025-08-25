#!/bin/bash

cd benchmarks-collection-scripts

sbatch -w ault25 <benchmark_avx2_256_testcaseA.sh
sbatch -w ault25 <benchmark_avx2_256_testcaseB.sh
sbatch -w ault25 <benchmark_specialized_testcaseA.sh
sbatch -w ault25 <benchmark_specialized_testcaseB.sh
