#!/bin/bash

ARTIFACT_LOCATION=${ARTIFACT_LOCATION:-${SCRATCH}/xaas-containers-artifact}

mkdir -p ${ARTIFACT_LOCATION}/data/gromacs
cd ${ARTIFACT_LOCATION}/data/gromacs
wget https://ftp.gromacs.org/gromacs/gromacs-2025.0.tar.gz
tar -xf gromacs-2025.0.tar.gz

wget https://repository.prace-ri.eu/ueabs/GROMACS/2.2/GROMACS_TestCaseA.tar.xz
tar -xf GROMACS_TestCaseA.tar.xz
wget https://repository.prace-ri.eu/ueabs/GROMACS/2.2/GROMACS_TestCaseB.tar.xz
tar -xf GROMACS_TestCaseB.tar.xz

