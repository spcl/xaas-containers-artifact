#!/bin/bash

ARTIFACT_LOCATION=${ARTIFACT_LOCATION:-${HOME}/xaas-containers-artifact}

DESTINATION=$1/gromacs-benchmarks/TestcaseB_benchmarks/

mkdir -p ${DESTINATION}

cp -r ${ARTIFACT_LOCATION}/benchmarks-source/gromacs/aurora/gromacs-benchmarks/TestcaseB_benchmarks/gromacs_native_testcaseB ${DESTINATION}
cp -r ${ARTIFACT_LOCATION}/benchmarks-source/gromacs/aurora/gromacs-benchmarks/TestcaseB_benchmarks/gromacs_specialized_testcaseB ${DESTINATION}
cp -r ${ARTIFACT_LOCATION}/benchmarks-source/gromacs/aurora/gromacs-benchmarks/TestcaseB_benchmarks/gromacs_source-container-default_testcaseB ${DESTINATION}
cp -r ${ARTIFACT_LOCATION}/benchmarks-source/gromacs/aurora/gromacs-benchmarks/TestcaseB_benchmarks/gromacs_source-container-gpu_testcaseB ${DESTINATION}

