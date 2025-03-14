#!/bin/bash

#SBATCH --job-name=spack_job    # Name of the job
#SBATCH --output=spack_job.out    # File to capture standard output
#SBATCH --error=spack_job.err     # File to capture standard error
#SBATCH --time=04:00:00            # Time limit (HH:MM:SS)
#SBATCH --nodes=1                  # Number of nodes
#SBATCH --ntasks=1                 # Number of tasks (processes)
#SBATCH --cpus-per-task=4          # Number of CPU cores per task
#SBATCH --mem=16G                  # Memory per node
#SBATCH --nodelist=ault23          # Specific node to use
#SBATCH --gres=gpu:1               # Request 1 GPU (if needed)


spack load gcc@11.5.0

# Load Spack environment
source $HOME/spack/share/spack/setup-env.sh

spack env activate gromacs_basic

spack install gromacs@2024.4 +mpi +cuda

spack env deactivate