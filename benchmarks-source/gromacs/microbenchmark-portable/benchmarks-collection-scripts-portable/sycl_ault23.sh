#!/bin/bash
#SBATCH --job-name=benchmark_gromacs   # Job name
#SBATCH --output=gromacs_%j.out        # Save output log
#SBATCH --error=gromacs_%j.err         # Save error log
#SBATCH --nodelist=ault23                # Assign the job to ault24
#SBATCH --ntasks=1                        # 4 MPI processes
#SBATCH --cpus-per-task=64                # 16 OpenMP threads per MPI process
#SBATCH --gpus=1                          # 1 GPU
#SBATCH --time=4:00:00                    # Max time limit
#SBATCH --exclusive                       # Ensures no other jobs run on this node

ARTIFACT_LOCATION=${ARTIFACT_LOCATION:-${SCRATCH}/xaas-containers-artifact}
DOCKER_REPOSITORY=${DOCKER_REPOSITORY:-"spcleth/xaas-artifact"}
DOCKER_IMAGE="gromacs-sycl-portable-cuda"

#STEPS=50000
STEPS=20000

module load sarus/1.6

export CUDA_VISIBLE_DEVICES="0"
export OMP_NUM_THREADS=64

TESTCASE_DIR="${ARTIFACT_LOCATION}/benchmarks-source/gromacs/ault23/gromacs-benchmarks/TestcaseA_benchmarks-portable/gromacs_testcase1_ault23_testcaseA/steps_${STEPS}"
TPR_FILE="${ARTIFACT_LOCATION}/data/gromacs/GROMACS_TestCaseA/ion_channel.tpr"

mkdir -p "$TESTCASE_DIR"

WARMUP_RUNS=2
BENCHMARK_RUNS=30
TOTAL_RUNS=$((WARMUP_RUNS + BENCHMARK_RUNS))

srun --mpi=pmi2 sarus run --mpi \
  --mount=type=bind,source="$(dirname $TPR_FILE)",destination="/input_dir" \
  --mount=type=bind,source="${TESTCASE_DIR}",destination="/result_dir" \
  --env OMP_NUM_THREADS=${OMP_NUM_THREADS} \
  --env CUDA_VISIBLE_DEVICES=${CUDA_VISIBLE_DEVICES} \
  ${DOCKER_REPOSITORY}:${DOCKER_IMAGE} bash -c '
  source /usr/local/gromacs/bin/GMXRC && \
  source /opt/intel/oneapi/mkl/latest/env/vars.sh && \
  ldd $(which gmx_mpi) > /result_dir/ldd_output.txt && \
  gmx_mpi mdrun --version > /result_dir/version_output.txt 2>&1 || echo true'

for i in $(seq 1 $TOTAL_RUNS); do
  echo "Starting run $i..."

  RUN_DIR="$TESTCASE_DIR/run${i}"
  LOG_FILE="$RUN_DIR/mdrun_output.log"

  mkdir -p "$RUN_DIR"

  srun --mpi=pmi2 sarus run --mpi \
    --mount=type=bind,source="$(dirname $TPR_FILE)",destination="/input_dir" \
    --mount=type=bind,source="${TESTCASE_DIR}",destination="/result_dir" \
    --env OMP_NUM_THREADS=${OMP_NUM_THREADS} \
    --env CUDA_VISIBLE_DEVICES=${CUDA_VISIBLE_DEVICES} \
    ${DOCKER_REPOSITORY}:${DOCKER_IMAGE} bash -c "
    source /usr/local/gromacs/bin/GMXRC && \
    source /opt/intel/oneapi/mkl/latest/env/vars.sh && \
    mkdir -p \"/result_dir/run${i}\" && \
    cd \"/result_dir/run${i}\" && \
    gmx_mpi mdrun -s \"/input_dir/ion_channel.tpr\" -ntomp 64 -nsteps ${STEPS} -resetstep 10000 > mdrun_output.log 2>&1"

  if [ "$i" -le "$WARMUP_RUNS" ]; then
    echo "Warm-up run $i completed. Deleting files..."
    rm -rf "$RUN_DIR"
  else
    echo "Benchmark run $i completed. Data saved in $RUN_DIR."
  fi
done

echo "All benchmarking runs are complete!"
