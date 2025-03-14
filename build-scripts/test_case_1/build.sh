#!/bin/bash

#SBATCH --job-name=build_job2    # Name of the job
#SBATCH --output=build_job2.out    # File to capture standard output
#SBATCH --error=build_job2.err     # File to capture standard error
#SBATCH --time=04:00:00            # Time limit (HH:MM:SS)
#SBATCH --nodes=1                  # Number of nodes
#SBATCH --ntasks=1                 # Number of tasks (processes)
#SBATCH --cpus-per-task=4          # Number of CPU cores per task
#SBATCH --mem=16G                  # Memory per node
#SBATCH --nodelist=ault23          # Specific node to use
#SBATCH --gres=gpu:1               # Request 1 GPU (if needed)

# Load required modules
module load cuda/12.1.1 intel-oneapi-mpi/2021.3.0 git/2.10.1 intel-oneapi-mkl/2021.3.0
module try-load OpenBLAS/0.3.5-gompi-system LAPACK/3.8.0-gompi-system


# Navigate to the build directory
cd $HOME/naive_build/gromacs-2025.0/build || exit 1

# build command 
cmake .. DGMX_SIMD=AVX2_256 -DGMX_BUILD_OWN_FFTW=ON -DGMX_GPU=CUDA -DGMX_MPI=ON -DGMX_OPENMP=ON -DCMAKE_INSTALL_PREFIX=$HOME/native_build/gromacs-2025.0

# Compile with parallel jobs using all available processors
make -j$(nproc)

# Run checks
make check

# Install (requires sudo privileges)
make install