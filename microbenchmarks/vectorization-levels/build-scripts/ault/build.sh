#!/bin/bash

#SBATCH --job-name=build_job2
#SBATCH --output=build_job2.out
#SBATCH --error=build_job2.err
#SBATCH --time=04:00:00
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=16G
#SBATCH --nodelist=ault23
#SBATCH --gres=gpu:1

# Load required modules
module load cuda/12.1.1 intel-oneapi-mpi/2021.3.0 git/2.10.1 intel-oneapi-mkl/2021.3.0
module try-load OpenBLAS/0.3.5-gompi-system LAPACK/3.8.0-gompi-system

# Source code directory
SOURCE_DIR="$HOME/naive_build/gromacs-2025.0"

# Root directory for all builds
SIMD_ROOT="$SCRATCH/gromacs-simd-retry"

# List of SIMD vectorization levels
SIMD_LEVELS=("None" "SSE2" "SSE4.1" "AVX2_128" "AVX_256" "AVX_512")

# Loop over each SIMD level
for simd in "${SIMD_LEVELS[@]}"; do
    echo "=== Building GROMACS with SIMD=$simd ==="

    # Define build and install directories
    BUILD_DIR="$SIMD_ROOT/${simd}/build"
    INSTALL_DIR="$SIMD_ROOT/${simd}/gromacs-install"

    # Prepare directories
    mkdir -p "$BUILD_DIR"
    mkdir -p "$INSTALL_DIR"

    # Go to build directory
    cd "$BUILD_DIR" || exit 1

    # Configure with CMake
    cmake "$SOURCE_DIR" \
        -DGMX_SIMD="$simd" \
        -DGMX_BUILD_OWN_FFTW=ON \
        -DREGRESSIONTEST_DOWNLOAD=ON \
        -DCMAKE_INSTALL_PREFIX="$INSTALL_DIR"

    # Compile
    make -j$(nproc)

    # Run checks
    make check

    # Install
    make install

    echo "=== Finished building $simd ==="
    echo "Binary located at: $INSTALL_DIR/bin/gmx"
done