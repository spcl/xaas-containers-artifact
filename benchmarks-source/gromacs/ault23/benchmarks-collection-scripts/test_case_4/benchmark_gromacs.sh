#!/bin/bash
#SBATCH --job-name=benchmark_gromacs   # Job name
#SBATCH --output=gromacs_%j.out         # Save output log
#SBATCH --error=gromacs_%j.err         # Save error log
#SBATCH --nodelist=ault23              # Assign the job to ault23
#SBATCH --ntasks=1                     # 1 MPI process
#SBATCH --cpus-per-task=64             # 64 OpenMP threads per MPI process
#SBATCH --gpus=1                       # 1 GPU
#SBATCH --time=4:00:00                 # Max time limit (adjust as needed)
#SBATCH --exclusive                    # Ensures no other jobs run on this node

ARTIFACT_LOCATION=${ARTIFACT_LOCATION:-${SCRATCH}/xaas-containers-artifact}

# Load Spack environment
source ${ARTIFACT_LOCATION}/dependencies/spack/share/spack/setup-env.sh
spack env activate gromacs_basic
spack load gromacs@2024.4

echo "Source the GROMACS binary"
source $(which GMXRC)

# Set environment variables
export OMP_NUM_THREADS=64          # 16 OpenMP threads per MPI process
export CUDA_VISIBLE_DEVICES=0  # Ensure GPU visibility

# Define paths
TESTCASE_DIR="${ARTIFACT_LOCATION}/benchmarks-source/gromacs/ault23/gromacs-benchmarks/TestcaseB_benchmarks/gromacs_testcase4_testcaseB"
TPR_FILE="${ARTIFACT_LOCATION}/data/gromacs/GROMACS_TestCaseB/lignocellulose.tpr"

mkdir -p "$TESTCASE_DIR"

WARMUP_RUNS=10
BENCHMARK_RUNS=30
TOTAL_RUNS=$((WARMUP_RUNS + BENCHMARK_RUNS))

echo "GROMACS configuration"
which gmx_mpi
ldd $(which gmx_mpi)
mpirun -np 1 gmx_mpi --version

echo "GROMACS Spack configuration"
spack spec gromacs@2024.4

for i in $(seq 1 $TOTAL_RUNS); do
    echo "Starting run $i..."

    RUN_DIR="$TESTCASE_DIR/run${i}"
    mkdir -p "$RUN_DIR"

    # Pin to cores 0-63 like Testcase 5
    taskset -c 0-63 mpirun -np 1 gmx_mpi mdrun -s "$TPR_FILE" -ntomp 64 -gpu_id 0 -nsteps 100 \
        > "$RUN_DIR/mdrun_output.log" 2>&1

    mv md.log traj* ener.edr confout.gro state.cpt "$RUN_DIR/" 2>/dev/null

    if [ "$i" -le "$WARMUP_RUNS" ]; then
        echo "Warm-up run $i completed. Deleting files..."
        rm -rf "$RUN_DIR"
    else
        echo "Benchmark run $i completed. Data saved in $RUN_DIR."
    fi
done

echo "All benchmarking runs are complete!"

spack env deactivate
