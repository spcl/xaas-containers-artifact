#!/bin/bash
#SBATCH --job-name=benchmark_gromacs_ompi
#SBATCH --output=gromacs_ompi_%j.out
#SBATCH --error=gromacs_ompi_%j.err
#SBATCH --nodes=1
#SBATCH --ntasks=4                    # Total MPI ranks
#SBATCH --cpus-per-task=64            # OpenMP threads per rank
#SBATCH --hint=nomultithread
#SBATCH --account=a-g200
#SBATCH --time=00:30:00

# Activate Spack environment and load OpenMPI + GROMACS

source $SCRATCH/spack/share/spack/setup-env.sh

spack env activate new_gromacs
spack load gromacs

# Manually define mpirun path from Spack
MPIRUN="/users/ealnuaim/spack/opt/spack/linux-neoverse_v2/openmpi-5.0.6-u36ehbjtccy5m7iy7abkeq4qjhhvyfjp/bin/mpirun"

# Disable GPU-aware MPI (OpenMPI isn't working correctly with it)
unset GMX_FORCE_GPU_AWARE_MPI
unset GMX_ENABLE_DIRECT_GPU_COMM

# Define paths
TPR_FILE="$SCRATCH/GROMACS_TestCaseB/lignocellulose.tpr"
BENCH_DIR="$SCRATCH/gromacs_benchmarks/TestcaseB_benchmarks/gromacs_spack_2025"
GROMACS_BIN="/iopsstor/scratch/cscs/ealnuaim/spack/opt/spack/linux-neoverse_v2/gromacs-2025.0-ipfxhzxv53y7pxoqwb6rqy32vdtare4i/bin/gmx_mpi"
MPS_WRAPPER="$HOME/mps-wrapper.sh"

mkdir -p "$BENCH_DIR"
chmod +x "$MPS_WRAPPER"

WARMUP_RUNS=10
BENCHMARK_RUNS=30
TOTAL_RUNS=$((WARMUP_RUNS + BENCHMARK_RUNS))

for i in $(seq 1 $TOTAL_RUNS); do
    echo "Starting run $i..."

    RUN_DIR="$BENCH_DIR/run_${i}"
    mkdir -p "$RUN_DIR"
    cd "$RUN_DIR"

   "$MPIRUN" -np 4 --bind-to socket \
    --mca btl self,vader \
    --mca pml ob1 \
    "$MPS_WRAPPER" "$GROMACS_BIN" mdrun \
        -s "$TPR_FILE" \
        -ntomp 64 \
        -bonded gpu -nb gpu -pme cpu -pin on -v \
        -noconfout -dlb yes -nstlist 300 -gpu_id 0 -nsteps 300 \
        > mdrun_output.log 2>&1

    mv md.log ener.edr confout.gro state.cpt "$RUN_DIR/" 2>/dev/null || true

    if [ "$i" -le "$WARMUP_RUNS" ]; then
        echo "Warm-up run $i completed. Deleting files..."
        rm -rf "$RUN_DIR"
    else
        echo "Benchmark run $i completed. Results saved."
    fi

    cd "$BENCH_DIR"
done

echo "All benchmarking runs completed."
