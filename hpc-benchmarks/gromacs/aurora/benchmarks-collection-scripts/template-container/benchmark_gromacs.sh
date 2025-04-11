#!/bin/bash
#SBATCH --job-name=benchmark_gromacs   # Job name
#SBATCH --output=gromacs%j.out        # Save output log
#SBATCH --error=gromacs%j.err         # Save error log
#SBATCH --nodelist=ault24                # Assign the job to ault24
#SBATCH --ntasks=1                        # 4 MPI processes
#SBATCH --cpus-per-task=64                # 16 OpenMP threads per MPI process
#SBATCH --gpus=1                          # 1 GPU
#SBATCH --time=4:00:00                    # Max time limit
#SBATCH --exclusive                       # Ensures no other jobs run on this node

# Load required modules
module load cuda/12.1.1 intel-oneapi-mpi/2021.3.0 intel-oneapi-mkl/2021.3.0 sarus/1.6

# FIXME: adapt for your configuration
export CUDA_VISIBLE_DEVICES=0
export OMP_NUM_THREADS=64

# FIXME: change the path for the output of the result
# these are host paths!
TESTCASE_DIR="$HOME/TestcaseB_benchmarks/testcaseNAME_REPLACEME"
TPR_FILE="$HOME/GROMACS_TestCaseB/lignocellulose.tpr"

mkdir -p "$TESTCASE_DIR"

WARMUP_RUNS=10
BENCHMARK_RUNS=30
TOTAL_RUNS=$((WARMUP_RUNS + BENCHMARK_RUNS))

for i in $(seq 1 $TOTAL_RUNS); do
  echo "Starting run $i..."

  RUN_DIR="$TESTCASE_DIR/run${i}"
  LOG_FILE="$RUN_DIR/mdrun_output.log"

  mkdir -p "$RUN_DIR"

  # FIXME: these are instructions for Sarus containers on CUDA - as inspiration
  # please replace with your container system
  # Might need to change your GPU config to use 1 GPU only
  #
  # Mounting might be necessary for the container to access test case data
  # and create results
  # --mount=type=bind,source="$HOME",destination="/host_home" \

  sarus run --mpi \
    --mount=type=bind,source=/usr/lib64/libcuda.so,destination=/usr/lib64/libcuda.so \
    --mount=type=bind,source=/usr/lib64/libcuda.so.1,destination=/usr/lib64/libcuda.so.1 \
    --mount=type=bind,source=/usr/lib64/libcuda.so.570.86.15,destination=/usr/lib64/libcuda.so.570.86.15 \
    --mount=type=bind,source=/usr/lib64/libnvidia-ml.so,destination=/usr/lib64/libnvidia-ml.so \
    --mount=type=bind,source=/usr/lib64/libnvidia-ml.so.1,destination=/usr/lib64/libnvidia-ml.so.1 \
    --mount=type=bind,source=/usr/lib64/libnvidia-ml.so.570.86.15,destination=/usr/lib64/libnvidia-ml.so.570.86.15 \
    --mount=type=bind,source=/usr/bin/nvidia-smi,destination=/usr/bin/nvidia-smi \
    --mount=type=bind,source=/dev/nvidia0,destination=/dev/nvidia0 \
    --mount=type=bind,source=/dev/nvidiactl,destination=/dev/nvidiactl \
    --mount=type=bind,source=/dev/nvidia-uvm,destination=/dev/nvidia-uvm \
    --mount=type=bind,source=/proc/driver/nvidia,destination=/proc/driver/nvidia \
    --mount=type=bind,source="$HOME",destination="/host_home" \
    CONTAINER_NAME_REPLACEME bash -c "
    source /usr/local/gromacs/bin/GMXRC && \
    export OMP_NUM_THREADS=64 && \
    export HYDRA_LAUNCHER=fork && \
    export CUDA_VISIBLE_DEVICES=0 &&  # Ensure GPU 0 is used
    mkdir -p \"/host_home/TestcaseB_benchmarks/testcaseNAME_REPLACEME/run${i}\" && \
    mpiexec -n 1 gmx_mpi mdrun -s \"/host_home/GROMACS_TestCaseB/lignocellulose.tpr\" -ntomp 64  -nsteps 100 > \"/host_home/TestcaseB_benchmarks/testcaseNAME_REPLACEME/run${i}/mdrun_output.log\" 2>&1 && \
    mv md.log traj* ener.edr confout.gro state.cpt \"/host_home/TestcaseB_benchmarks/testcaseNAME_REPLACEME/run${i}/\" 2>/dev/null
    "

  if [ "$i" -le "$WARMUP_RUNS" ]; then
    echo "Warm-up run $i completed. Deleting files..."
    rm -rf "$RUN_DIR"
  else
    echo "Benchmark run $i completed. Data saved in $RUN_DIR."
  fi
done

echo "All benchmarking runs are complete!"

