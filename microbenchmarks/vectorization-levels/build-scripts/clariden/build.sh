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
WORKDIR="$HOME/testcase1"
mkdir -p "$WORKDIR"
cd "$WORKDIR"

# Download and extract GROMACS if not already present
if [ ! -f gromacs-2025.0.tar.gz ]; then
    wget https://ftp.gromacs.org/gromacs/gromacs-2025.0.tar.gz
fi
if [ ! -d gromacs-2025.0 ]; then
    tar xfz gromacs-2025.0.tar.gz
fi

# SIMD levels to build
SIMD_LEVELS=("ARM_SVE" "ARM_NEON_ASIMD")

# Loop over SIMD levels
for SIMD in "${SIMD_LEVELS[@]}"; do
    echo "=== Building GROMACS with SIMD=$SIMD ==="

    # Set build and install directories
    BUILD_DIR="$WORKDIR/build_${SIMD}"
    INSTALL_DIR="$WORKDIR/gromacs-2025.0-install-${SIMD}"

    # Clean up previous build if exists
    rm -rf "$BUILD_DIR"
    mkdir -p "$BUILD_DIR"
    cd "$BUILD_DIR" || exit 1

    # Configure
    cmake ../gromacs-2025.0 \
        -DGMX_SIMD="$SIMD" \
        -DGMX_BUILD_OWN_FFTW=ON \
        -DGMX_GPU=CUDA \
        -DGMX_MPI=ON \
        -DGMX_OPENMP=ON \
        -DCMAKE_INSTALL_PREFIX="$INSTALL_DIR"

    # Build and install
    make -j16
    make install

    echo "=== Finished building $SIMD ==="
done