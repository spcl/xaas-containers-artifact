#!/bin/bash

ARTIFACT_LOCATION=${ARTIFACT_LOCATION:-${SCRATCH}/xaas-containers-artifact}

DESTINATION=$1/gromacs-benchmarks/TestcaseB_benchmarks/

mkdir -p ${DESTINATION}

cp -r ${ARTIFACT_LOCATION}/benchmarks-source/gromacs/ault23/gromacs-benchmarks/TestcaseB_benchmarks/gromacs_testcase0_testcaseB ${DESTINATION}
cp -r ${ARTIFACT_LOCATION}/benchmarks-source/gromacs/ault23/gromacs-benchmarks/TestcaseB_benchmarks/gromacs_testcase3_testcaseB ${DESTINATION}
cp -r ${ARTIFACT_LOCATION}/benchmarks-source/gromacs/ault23/gromacs-benchmarks/TestcaseB_benchmarks/gromacs_testcase4_testcaseB ${DESTINATION}

