#!/bin/bash
#SBATCH --job-name=benchmark_gromacs   # Job name
#SBATCH --output=gromacs_%j.out         # Save output log
#SBATCH --error=gromacs_%j.err         # Save error log
#SBATCH --nodelist=ault24              # Assign the job to ault23
#SBATCH --ntasks=1                     # 1 MPI process
#SBATCH --cpus-per-task=64             # 64 OpenMP threads per MPI process
#SBATCH --gpus=1                       # 1 GPU
#SBATCH --time=4:00:00                 # Max time limit (adjust as needed)
#SBATCH --exclusive                    # Ensures no other jobs run on this node

ARTIFACT_LOCATION=${ARTIFACT_LOCATION:-${SCRATCH}/xaas-containers-artifact}
STEPS=1000

source ${ARTIFACT_LOCATION}/dependencies/spack_2025/share/spack/setup-env.sh
spack env activate gromacs_2025_basic
spack load gromacs@2025

echo "Source the GROMACS binary"
source $(which GMXRC)

export OMP_NUM_THREADS=64

TESTCASE_DIR="${ARTIFACT_LOCATION}/benchmarks-source/gromacs/ault23/gromacs-benchmarks/TestcaseB_benchmarks/gromacs2025_testcase4_testcaseB/steps_${STEPS}"
TPR_FILE="${ARTIFACT_LOCATION}/data/gromacs/GROMACS_TestCaseB/lignocellulose.tpr"

mkdir -p "$TESTCASE_DIR"

WARMUP_RUNS=2
BENCHMARK_RUNS=30
TOTAL_RUNS=$((WARMUP_RUNS + BENCHMARK_RUNS))

echo "GROMACS configuration"
which gmx_mpi
ldd $(which gmx_mpi)
mpiexec -np 1 gmx_mpi --version

echo "GROMACS Spack configuration"
spack spec gromacs@2025

for i in $(seq 1 $TOTAL_RUNS); do
  echo "Starting run $i..."

  RUN_DIR="$TESTCASE_DIR/run${i}"
  mkdir -p "$RUN_DIR"

  pushd ${RUN_DIR}
  mpirun -np 1 gmx_mpi mdrun -s "$TPR_FILE" -ntomp 64 -gpu_id 0 -nsteps ${STEPS} >"mdrun_output.log" 2>&1
  popd

  if [ "$i" -le "$WARMUP_RUNS" ]; then
    echo "Warm-up run $i completed. Deleting files..."
    rm -rf "$RUN_DIR"
  else
    echo "Benchmark run $i completed. Data saved in $RUN_DIR."
  fi
done

echo "All benchmarking runs are complete!"

spack env deactivate
