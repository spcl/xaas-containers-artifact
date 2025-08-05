#!/bin/bash

ARTIFACT_LOCATION=${ARTIFACT_LOCATION:-${SCRATCH}/xaas-containers-artifact}

DESTINATION=$1/gromacs-benchmarks/TestcaseA_benchmarks

mkdir -p ${DESTINATION}

for case in "SSE4.1" "AVX2_128" "AVX2_256" "AVX_256" "AVX_512" "portable" "specialized"; do
  for run in $(seq 3 32); do
    mkdir -p ${DESTINATION}/gromacs_${case}_testcaseA/steps_200/run${run}
    cp -r ${ARTIFACT_LOCATION}/benchmarks-ir/gromacs-cpu/ault01/gromacs-benchmarks/TestcaseA_benchmarks/gromacs_${case}_testcaseA/steps_200/run${run}/*.log ${DESTINATION}/gromacs_${case}_testcaseA/steps_200/run${run}
  done
done

DESTINATION=$1/gromacs-benchmarks/TestcaseB_benchmarks

mkdir -p ${DESTINATION}

for case in "SSE4.1" "AVX2_128" "AVX2_256" "AVX_256" "AVX_512" "portable" "specialized"; do
  for run in $(seq 3 32); do
    mkdir -p ${DESTINATION}/gromacs_${case}_testcaseB/steps_200/run${run}
    cp -r ${ARTIFACT_LOCATION}/benchmarks-ir/gromacs-cpu/ault01/gromacs-benchmarks/TestcaseB_benchmarks/gromacs_${case}_testcaseB/steps_200/run${run}/*.log ${DESTINATION}/gromacs_${case}_testcaseB/steps_200/run${run}
  done
done
