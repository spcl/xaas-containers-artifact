#!/bin/bash

#SBATCH --job-name=spack_job    # Name of the job
#SBATCH --output=spack_job.out    # File to capture standard output
#SBATCH --error=spack_job.err     # File to capture standard error
#SBATCH --time=04:00:00            # Time limit (HH:MM:SS)
#SBATCH --nodes=1                  # Number of nodes
#SBATCH --ntasks=1                 # Number of tasks (processes)
#SBATCH --cpus-per-task=64          # Number of CPU cores per task
#SBATCH --mem=16G                  # Memory per node
#SBATCH --nodelist=ault23          # Specific node to use
#SBATCH --gres=gpu:1               # Request 1 GPU (if needed)

ARTIFACT_LOCATION=${ARTIFACT_LOCATION:-${SCRATCH}/xaas-containers-artifact}

source ${ARTIFACT_LOCATION}/dependencies/spack/share/spack/setup-env.sh
spack load gcc@11.5.0 arch=linux-centos8-zen

spack env create gromacs_basic
spack env activate gromacs_basic
spack compiler find

# reproduce the same set of versions that we previously had generated
# but it should not be necessary
spack add cuda@12.8
spack add openmpi@5.0.6
spack add gromacs@2024.4 +mpi +cuda
spack install -j$(nproc) 

spack env deactivate
