#!/bin/bash

ARTIFACT_LOCATION=${ARTIFACT_LOCATION:-${SCRATCH}/xaas-containers-artifact}

DESTINATION=$1/gromacs-benchmarks/TestcaseA_benchmarks

mkdir -p ${DESTINATION}

for case in "CUDA_AVX_512" "specialized"; do
  for run in $(seq 3 32); do
    mkdir -p ${DESTINATION}/gromacs-gpu/ault23/gromacs_${case}_testcaseA/steps_20000/run${run}
    cp -r ${ARTIFACT_LOCATION}/benchmarks-ir/gromacs-gpu/ault23/gromacs-benchmarks/TestcaseA_benchmarks/gromacs_${case}_testcaseA/steps_20000/run${run}/*.log ${DESTINATION}/gromacs-gpu/ault23/gromacs_${case}_testcaseA/steps_20000/run${run}
  done
done

DESTINATION=$1/gromacs-benchmarks/TestcaseB_benchmarks

mkdir -p ${DESTINATION}

for case in "CUDA_AVX2_256" "specialized"; do
  for run in $(seq 3 32); do
    mkdir -p ${DESTINATION}/gromacs-gpu/ault23/gromacs_${case}_testcaseB/steps_1000/run${run}
    cp -r ${ARTIFACT_LOCATION}/benchmarks-ir/gromacs-gpu/ault23/gromacs-benchmarks/TestcaseB_benchmarks/gromacs_${case}_testcaseB/steps_1000/run${run}/*.log ${DESTINATION}/gromacs-gpu/ault23/gromacs_${case}_testcaseB/steps_1000/run${run}
  done
done
