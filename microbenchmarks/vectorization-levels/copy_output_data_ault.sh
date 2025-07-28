#!/bin/bash

ARTIFACT_LOCATION=${ARTIFACT_LOCATION:-${SCRATCH}/xaas-containers-artifact}

DESTINATION=$1/benchmarks/intel/

mkdir -p ${DESTINATION}

cp -r ${ARTIFACT_LOCATION}/microbenchmarks/vectorization-levels/benchmarks/intel/* ${DESTINATION}

