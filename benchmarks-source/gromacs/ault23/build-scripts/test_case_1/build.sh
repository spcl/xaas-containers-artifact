#!/bin/bash

#SBATCH --job-name=build_job2    # Name of the job
#SBATCH --output=build_job_testcase1.out    # File to capture standard output
#SBATCH --error=build_job_testcase1.err     # File to capture standard error
#SBATCH --time=04:00:00            # Time limit (HH:MM:SS)
#SBATCH --nodes=1                  # Number of nodes
#SBATCH --ntasks=1                 # Number of tasks (processes)
#SBATCH --cpus-per-task=64          # Number of CPU cores per task
#SBATCH --mem=16G                  # Memory per node
#SBATCH --nodelist=ault23          # Specific node to use
#SBATCH --gres=gpu:1               # Request 1 GPU (if needed)

ARTIFACT_LOCATION=${ARTIFACT_LOCATION:-${SCRATCH}/xaas-containers-artifact}

# Load required modules
module load cuda/12.1.1 intel-oneapi-mpi/2021.3.0 git/2.10.1 intel-oneapi-mkl/2021.3.0
module try-load OpenBLAS/0.3.5-gompi-system LAPACK/3.8.0-gompi-system

source ${ARTIFACT_LOCATION}/dependencies/spack/share/spack/setup-env.sh
spack load gcc@11.5

# Navigate to the build directory
cd ${ARTIFACT_LOCATION}/benchmarks-source/gromacs/ault23/build-scripts/test_case_1

rm -rf build && mkdir -p build
mkdir -p install

# build command
cd build && ${ARTIFACT_LOCATION}/data/gromacs/cmake/bin/cmake ${ARTIFACT_LOCATION}/data/gromacs/gromacs-2025.0 -DGMX_SIMD=AVX_512 -DGMX_BUILD_OWN_FFTW=ON -DGMX_GPU=CUDA -DGMX_MPI=ON -DGMX_OPENMP=ON -DCMAKE_INSTALL_PREFIX=$(pwd)/../install

# Compile with parallel jobs using all available processors
make -j$(nproc)

# Run checks
make check

# Install (requires sudo privileges)
make install
