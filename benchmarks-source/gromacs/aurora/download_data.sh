#!/bin/bash

ARTIFACT_LOCATION=${ARTIFACT_LOCATION:-${HOME}/xaas-containers-artifact}

mkdir -p ${ARTIFACT_LOCATION}/data/gromacs
cd ${ARTIFACT_LOCATION}/data/gromacs

wget https://repository.prace-ri.eu/ueabs/GROMACS/2.2/GROMACS_TestCaseA.tar.xz
tar -xf GROMACS_TestCaseA.tar.xz
wget https://repository.prace-ri.eu/ueabs/GROMACS/2.2/GROMACS_TestCaseB.tar.xz
tar -xf GROMACS_TestCaseB.tar.xz

