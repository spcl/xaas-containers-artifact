#!/bin/bash

#SBATCH --job-name=spack_job    # Name of the job
#SBATCH --output=spack_job.out    # File to capture standard output
#SBATCH --error=spack_job.err     # File to capture standard error
#SBATCH --time=04:00:00            # Time limit (HH:MM:SS)
#SBATCH --nodes=1                  # Number of nodes
#SBATCH --ntasks=1                 # Number of tasks (processes)
#SBATCH --cpus-per-task=4          # Number of CPU cores per task
#SBATCH --mem=16G                  # Memory per node
#SBATCH --nodelist=ault24          # Specific node to use
#SBATCH --gres=gpu:1               # Request 1 GPU (if needed)

# Ault24 has similar features as ault23 

spack load gcc@11.5.0

# Load Spack environment
source $HOME/spack/share/spack/setup-env.sh

spack env create new_gromacs

spack env activate new_gromacs

spack add gcc@11.5.0
spack install gcc@11.5.0

spack add gromacs@2025.0 +mpi +cuda

#spack install gromacs@2025.0 +mpi +cuda
spack install 

spack env deactivate