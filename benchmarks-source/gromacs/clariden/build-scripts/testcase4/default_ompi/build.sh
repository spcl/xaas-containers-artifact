#!/bin/bash
#SBATCH --job-name=spack-gromacs
#SBATCH --output=spack-gromacs.out
#SBATCH --error=spack-gromacs.err
#SBATCH --time=4:00:00
#SBATCH --partition=normal
#SBATCH --account=a-g200
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=72

ARTIFACT_LOCATION=${ARTIFACT_LOCATION:-${SCRATCH}/xaas-containers-artifact}
source ${ARTIFACT_LOCATION}/dependencies/spack/share/spack/setup-env.sh

spack env create gromacs_basic 
spack env activate gromacs_basic
spack compiler find

spack add gromacs@2024.4 +mpi +cuda

# Run Spack commands
spack concretize --force
spack install
spack spec gromacs
spack env deactivate 
