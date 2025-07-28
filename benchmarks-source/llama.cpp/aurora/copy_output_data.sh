#!/bin/bash

ARTIFACT_LOCATION=${ARTIFACT_LOCATION:-${HOME}/xaas-containers-artifact}

DESTINATION=$1/llama-benchmarks/Q4_K_M/

mkdir -p ${DESTINATION}

cp -r ${ARTIFACT_LOCATION}/benchmarks-source/llama.cpp/aurora/llama-benchmarks/Q4_K_M/*.csv ${DESTINATION}

