#!/bin/bash
#SBATCH --job-name=spack-gromacs
#SBATCH --output=spack-gromacs.out
#SBATCH --error=spack-gromacs.err
#SBATCH --time=4:00:00
#SBATCH --partition=normal
#SBATCH --account=a-g200
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4

spack env create testcase4
spack env activate testcase4

spack add gromacs@2024.4 +mpi +cuda

# Run Spack commands
spack concretize --force
spack install
spack spec gromacs
spack env deactivate 