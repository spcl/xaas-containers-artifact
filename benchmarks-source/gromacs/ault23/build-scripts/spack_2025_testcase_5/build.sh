#!/bin/bash

#SBATCH --job-name=spack_job    # Name of the job
#SBATCH --output=spack_job_2025.out    # File to capture standard output
#SBATCH --error=spack_job_2025.err     # File to capture standard error
#SBATCH --time=04:00:00            # Time limit (HH:MM:SS)
#SBATCH --nodes=1                  # Number of nodes
#SBATCH --ntasks=1                 # Number of tasks (processes)
#SBATCH --cpus-per-task=64          # Number of CPU cores per task
#SBATCH --mem=16G                  # Memory per node
#SBATCH --nodelist=ault23          # Specific node to use
#SBATCH --gres=gpu:1               # Request 1 GPU (if needed)

ARTIFACT_LOCATION=${ARTIFACT_LOCATION:-${SCRATCH}/xaas-containers-artifact}

source ${ARTIFACT_LOCATION}/dependencies/spack_2025/share/spack/setup-env.sh
spack load gcc@11.5.0 arch=linux-centos8-zen
spack load gcc@11.5.0

spack env create gromacs_2025_advanced
spack env activate gromacs_2025_advanced
spack compiler find

spack add gromacs@2025.0 +mpi +cuda cuda_arch=70 +openmp ^intel-oneapi-mkl ^fftw@3 target=skylake_avx512
spack install --fresh -j $(nproc)

spack env deactivate
