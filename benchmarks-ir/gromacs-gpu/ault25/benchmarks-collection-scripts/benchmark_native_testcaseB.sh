#!/bin/bash
#SBATCH --job-name=benchmark_gromacs   # Job name
#SBATCH --output=gromacs_%j.out        # Save output log
#SBATCH --error=gromacs_%j.err         # Save error log
#SBATCH --nodelist=ault23                # Assign the job to ault23
#SBATCH --ntasks=1                        # 4 MPI processes
#SBATCH --cpus-per-task=128               # 16 OpenMP threads per MPI process
#SBATCH --hint=nomultithread               # 16 OpenMP threads per MPI process
#SBATCH --gpus=1                          # 1 GPU
#SBATCH --time=4:00:00                    # Max time limit (adjust as needed)
#SBATCH --exclusive                       # Ensures no other jobs run on this node

ARTIFACT_LOCATION=${ARTIFACT_LOCATION:-${SCRATCH}/xaas-containers-artifact}
STEPS=1000

module load cuda/12.1.1 intel-oneapi-mpi/2021.3.0 intel-oneapi-mkl/2021.3.0 intel-oneapi-compilers/2021.3.0

#source ${ARTIFACT_LOCATION}/benchmarks-source/gromacs/ault23/build-scripts/test_case_1/build2/bin/GMXRCA

export I_MPI_PMI_VALUE_LENGTH_MAX=512

export OMP_NUM_THREADS=128     # 16 OpenMP threads per MPI process
export CUDA_VISIBLE_DEVICES=0 # Ensure GPU visibility

TESTCASE_DIR="${ARTIFACT_LOCATION}/benchmarks-ir/gromacs-gpu/ault23/gromacs-benchmarks/TestcaseB_benchmarks/gromacs_native_testcaseB/steps_${STEPS}"
TPR_FILE="${ARTIFACT_LOCATION}/data/gromacs/GROMACS_TestCaseB/lignocellulose.tpr"

mkdir -p "$TESTCASE_DIR"

WARMUP_RUNS=2
BENCHMARK_RUNS=30
TOTAL_RUNS=$((WARMUP_RUNS + BENCHMARK_RUNS))

echo "GROMACS configuration"
#which gmx_mpi
#ldd $(which gmx_mpi)
#mpirun -np 1 gmx_mpi --version

for i in $(seq 1 $TOTAL_RUNS); do
  echo "Starting run $i..."

  RUN_DIR="$TESTCASE_DIR/run${i}"
  mkdir -p "$RUN_DIR"

  pushd ${RUN_DIR}
  srun ${ARTIFACT_LOCATION}/benchmarks-source/gromacs/ault23/build-scripts/test_case_1/build2/bin/gmx_mpi mdrun -s "$TPR_FILE" -ntomp 128 -gpu_id 0 -nsteps ${STEPS} >"$RUN_DIR/mdrun_output.log" 2>&1
  popd

  #mv md.log traj* ener.edr confout.gro state.cpt "$RUN_DIR/" 2>/dev/null

  if [ "$i" -le "$WARMUP_RUNS" ]; then
    echo "Warm-up run $i completed. Deleting files..."
    rm -rf "$RUN_DIR"
  else
    echo "Benchmark run $i completed. Data saved in $RUN_DIR."
  fi
done

echo "All benchmarking runs are complete!"
