#!/bin/bash

spack env create new_gromacs

spack env activate new_gromacs

spack add gromacs@2025.0 +mpi +cuda

#spack install gromacs@2025.0 +mpi +cuda
spack install 