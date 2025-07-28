#!/bin/bash

ARTIFACT_LOCATION=${ARTIFACT_LOCATION:-${SCRATCH}/xaas-containers-artifact}

DESTINATION=$1/llama-benchmarks/Q4_K_M/

mkdir -p ${DESTINATION}

cp -r ${ARTIFACT_LOCATION}/benchmarks-source/llama.cpp/clariden/llama-benchmarks/Q4_K_M/*.csv ${DESTINATION}

