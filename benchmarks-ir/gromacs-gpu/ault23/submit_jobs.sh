#!/bin/bash

cd benchmarks-collection-scripts

sbatch -w ault23 <benchmark_avx_512_testcaseA.sh
sbatch -w ault23 <benchmark_avx_512_testcaseB.sh
sbatch -w ault23 <benchmark_specialized_testcaseA.sh
sbatch -w ault23 <benchmark_specialized_testcaseB.sh
