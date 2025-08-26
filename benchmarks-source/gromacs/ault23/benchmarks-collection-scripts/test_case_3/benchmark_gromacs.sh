#!/bin/bash
#SBATCH --job-name=benchmark_gromacs   # Job name
#SBATCH --output=gromacs_%j.out        # Save output log
#SBATCH --error=gromacs_%j.err         # Save error log
#SBATCH --nodelist=ault24                # Assign the job to ault24
#SBATCH --ntasks=1                        # 4 MPI processes
#SBATCH --cpus-per-task=64                # 16 OpenMP threads per MPI process
#SBATCH --gpus=1                          # 1 GPU
#SBATCH --time=4:00:00                    # Max time limit
#SBATCH --exclusive                       # Ensures no other jobs run on this node

ARTIFACT_LOCATION=${ARTIFACT_LOCATION:-${SCRATCH}/xaas-containers-artifact}
DOCKER_REPOSITORY=${DOCKER_REPOSITORY:-"spcleth/xaas-artifact"}
DOCKER_IMAGE="gromacs-source-deploy-ault23"
STEPS=1000

module load sarus/1.6

export CUDA_VISIBLE_DEVICES="0"
export OMP_NUM_THREADS=64

TESTCASE_DIR="${ARTIFACT_LOCATION}/benchmarks-source/gromacs/ault23/gromacs-benchmarks/TestcaseB_benchmarks/gromacs_testcase3_testcaseB/steps_${STEPS}"
TPR_FILE="${ARTIFACT_LOCATION}/data/gromacs/GROMACS_TestCaseB/lignocellulose.tpr"

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
  source /opt/intel/oneapi/setvars.sh > /dev/null 2>&1 && \
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
    source /opt/intel/oneapi/setvars.sh > /dev/null 2>&1 && \
    mkdir -p \"/result_dir/run${i}\" && \
    cd \"/result_dir/run${i}\" && \
    gmx_mpi mdrun -s \"/input_dir/lignocellulose.tpr\" -ntomp 64 -nsteps ${STEPS} > mdrun_output.log 2>&1"
  #gmx_mpi mdrun -s \"/input_dir/lignocellulose.tpr\" -ntomp 64 -nsteps ${STEPS} > \"/result_dir/run${i}/mdrun_output.log\" 2>&1 && \
  #mv md.log ener.edr confout.gro state.cpt \"/result_dir/run${i}/\""

  # Use this one if Sarus GPU hook does not work (exact library paths will change with the driver version)
  # We cannot apply Sarus --mpi because our cluster has OpenMPI
  #sarus run --mpi \
  #  --mount=type=bind,source=/usr/lib64/libcuda.so,destination=/usr/lib64/libcuda.so \
  #  --mount=type=bind,source=/usr/lib64/libcuda.so.1,destination=/usr/lib64/libcuda.so.1 \
  #  --mount=type=bind,source=/usr/lib64/libcuda.so.570.86.15,destination=/usr/lib64/libcuda.so.570.86.15 \
  #  --mount=type=bind,source=/usr/lib64/libnvidia-ml.so,destination=/usr/lib64/libnvidia-ml.so \
  #  --mount=type=bind,source=/usr/lib64/libnvidia-ml.so.1,destination=/usr/lib64/libnvidia-ml.so.1 \
  #  --mount=type=bind,source=/usr/lib64/libnvidia-ml.so.570.86.15,destination=/usr/lib64/libnvidia-ml.so.570.86.15 \
  #  --mount=type=bind,source=/usr/bin/nvidia-smi,destination=/usr/bin/nvidia-smi \
  #  --mount=type=bind,source=/dev/nvidia0,destination=/dev/nvidia0 \
  #  --mount=type=bind,source=/dev/nvidiactl,destination=/dev/nvidiactl \
  #  --mount=type=bind,source=/dev/nvidia-uvm,destination=/dev/nvidia-uvm \
  #  --mount=type=bind,source=/proc/driver/nvidia,destination=/proc/driver/nvidia \
  #  --mount=type=bind,source="$(dirname $TPR_FILE)",destination="/input_dir" \
  #  --mount=type=bind,source="${TESTCASE_DIR}",destination="/result_dir" \
  #  --env OMP_NUM_THREADS=${OMP_NUM_THREADS} \
  #  --env CUDA_VISIBLE_DEVICES=${CUDA_VISIBLE_DEVICES} \
  #  --env HYDRA_LAUNCHER=fork \
  #  ealnuaimi/testcase_3:updated bash -c "
  #  source /usr/local/gromacs/bin/GMXRC && \
  #  source /opt/intel/oneapi/mkl/latest/env/vars.sh && \
  #  mkdir -p \"/result_dir/run${i}\" && \
  #  mpiexec -n 1 gmx_mpi mdrun -s \"/input_dir/lignocellulose.tpr\" -ntomp 64  -nsteps 100 -gpu_id 0 > \"/result_dir/run${i}/mdrun_output.log\" 2>&1 && \
  #  mv md.log traj* ener.edr confout.gro state.cpt \"/result_dir/run${i}/\" 2>/dev/null
  #  "

  if [ "$i" -le "$WARMUP_RUNS" ]; then
    echo "Warm-up run $i completed. Deleting files..."
    rm -rf "$RUN_DIR"
  else
    echo "Benchmark run $i completed. Data saved in $RUN_DIR."
  fi
done

echo "All benchmarking runs are complete!"
