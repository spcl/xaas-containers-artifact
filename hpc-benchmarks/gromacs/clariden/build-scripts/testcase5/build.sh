#!/bin/bash
#SBATCH --job-name=spack-gromacs
#SBATCH --output=spack-gromacs.out
#SBATCH --error=spack-gromacs.err
#SBATCH --time=4:00:00
#SBATCH --partition=normal
#SBATCH --account=a-g200
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4

spack env create testcase5
spack env activate testcase5

spack install --add gromacs@2024.4 +mpi +cuda +openmp cuda_arch=90 ^cray-mpich@8.1.30 ^cuda@12.6.2

# Run Spack commands
spack concretize --force
spack install
spack spec gromacs
spack env deactivate 