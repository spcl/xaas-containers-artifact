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

ARTIFACT_LOCATION=${ARTIFACT_LOCATION:-${SCRATCH}/xaas-containers-artifact}

# Load necessary modules inside the uenv
module load cray-mpich/8.1.30 cuda/12.6.2 cmake/3.30.5 gcc/13.3.0

# Work inside home directory
WORKDIR="$HOME/testcase1"
mkdir -p "$WORKDIR"
cd "$WORKDIR"

SOURCE_DIR="${ARTIFACT_LOCATION}/data/gromacs/gromacs-2025.0"
SIMD_ROOT="${ARTIFACT_LOCATION}/microbenchmarks/vectorization-levels/build-scripts/clariden"

# SIMD levels to build
SIMD_LEVELS=("None" "ARM_SVE" "ARM_NEON_ASIMD")

# Loop over SIMD levels
for SIMD in "${SIMD_LEVELS[@]}"; do
    echo "=== Building GROMACS with SIMD=$SIMD ==="

    SIMD_NAME=${SIMD#ARM_}
    # Set build and install directories
    BUILD_DIR="$SIMD_ROOT/${SIMD_NAME}/build"
    INSTALL_DIR="$SIMD_ROOT/${SIMD_NAME}/install"

    # Clean up previous build if exists
    rm -rf "$BUILD_DIR"
    mkdir -p "$BUILD_DIR"
    cd "$BUILD_DIR" || exit 1

    # Configure
    cmake "$SOURCE_DIR" \
        -DGMX_SIMD="$SIMD" \
        -DGMX_BUILD_OWN_FFTW=ON \
        -DCMAKE_INSTALL_PREFIX="$INSTALL_DIR"

    # Build and install
    make -j16
    make install

    echo "=== Finished building $SIMD ==="
done
