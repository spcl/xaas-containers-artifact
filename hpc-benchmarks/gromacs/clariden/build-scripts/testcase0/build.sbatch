#!/bin/bash -l
#SBATCH --job-name=gromacs_build
#SBATCH --time=04:00:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=16
#SBATCH --account=a-g200
#SBATCH --output=gromacs_%j.out
#SBATCH --error=gromacs_%j.err

#SBATCH --uenv=prgenv-gnu/24.11:v1
#SBATCH --view=modules

# Load necessary modules inside the uenv
module load cray-mpich/8.1.30 cuda/12.6.2 cmake/3.30.5 gcc/13.3.0

# Work inside home directory
cd $HOME/testcase0/

# Download and extract GROMACS (if needed)
# wget https://ftp.gromacs.org/gromacs/gromacs-2025.0.tar.gz
# tar xfz gromacs-2025.0.tar.gz
cd gromacs-2025.0

rm -r build
# Create build directory
mkdir -p build && cd build

# Configure and compile GROMACS
cmake .. \
  -DGMX_BUILD_OWN_FFTW=ON \
  -DREGRESSIONTEST_DOWNLOAD=ON \
  -DCMAKE_INSTALL_PREFIX=$HOME/testcase0/gromacs-2025.0

make -j16
make install