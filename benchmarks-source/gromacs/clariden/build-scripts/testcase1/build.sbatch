#!/bin/bash -l
#SBATCH --job-name=gromacs_build
#SBATCH --time=04:00:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=64
#SBATCH --account=a-g200
#SBATCH --output=gromacs_build_exprt.%j.out
#SBATCH --error=gromacs_build_exprt.%j.err

#SBATCH --uenv=prgenv-gnu/24.11:v1
#SBATCH --view=modules

ARTIFACT_LOCATION=${ARTIFACT_LOCATION:-${SCRATCH}/xaas-containers-artifact}

# Load necessary modules inside the uenv
module load cray-mpich/8.1.30 cuda/12.6.2 cmake/3.30.5 gcc/13.3.0

cd ${ARTIFACT_LOCATION}/benchmarks-source/gromacs/clariden/build-scripts/testcase1

# Create build directory
rm -rf build && mkdir -p build
mkdir -p install

# Configure and compile GROMACS
cd build && cmake ${ARTIFACT_LOCATION}/data/gromacs/gromacs-2025.0 -DGMX_SIMD=ARM_SVE -DGMX_BUILD_OWN_FFTW=ON -DGMX_GPU=CUDA -DGMX_MPI=ON -DGMX_OPENMP=ON -DCMAKE_INSTALL_PREFIX=$(pwd)/../install


make -j16
make install
