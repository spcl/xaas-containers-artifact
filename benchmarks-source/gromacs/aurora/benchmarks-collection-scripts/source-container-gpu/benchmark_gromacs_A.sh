#!/bin/bash
#PBS -A workflow_scaling
#PBS -N gromacs_app_tests
#PBS -l walltime=02:00:00
#PBS -l filesystems=home
#PBS -q prod

# FIXME: adapt for your configuration
module load apptainer
module load fuse-overlayfs

ARTIFACT_LOCATION=${ARTIFACT_LOCATION:-${HOME}/xaas-containers-artifact}
STEPS=20000

# FIXME: adapt for your configuration
export OMP_NUM_THREADS=104 # Use 16 OpenMP threads

TESTCASE_DIR="${ARTIFACT_LOCATION}/benchmarks-source/gromacs/aurora/gromacs-benchmarks/TestcaseA_benchmarks/gromacs_source-container-gpu_testcaseA/steps_${STEPS}"
TPR_FILE="${ARTIFACT_LOCATION}/data/gromacs/GROMACS_TestCaseA/ion_channel.tpr"

CONTAINER_PATH="${ARTIFACT_LOCATION}/data/gromacs/images/gromacs-xaas-source-gpu.sing"

mkdir -p "$TESTCASE_DIR"

WARMUP_RUNS=2
BENCHMARK_RUNS=30
TOTAL_RUNS=$((WARMUP_RUNS + BENCHMARK_RUNS))

echo "GROMACS configuration"
apptainer exec ${CONTAINER_PATH} /bin/bash -c "source /usr/local/gromacs/bin/GMXRC && which gmx"
apptainer exec ${CONTAINER_PATH} /bin/bash -c "source /usr/local/gromacs/bin/GMXRC && ldd $(which gmx)"
apptainer exec ${CONTAINER_PATH} /bin/bash -c "source /usr/local/gromacs/bin/GMXRC && gmx --version"

for i in $(seq 1 $TOTAL_RUNS); do
  echo "Starting run $i..."

  RUN_DIR="$TESTCASE_DIR/run${i}"
  LOG_FILE="$RUN_DIR/mdrun_output.log"

  mkdir -p "$RUN_DIR"

  apptainer exec ${CONTAINER_PATH} /bin/bash -c "source /usr/local/gromacs/bin/GMXRC && gmx mdrun -s $TPR_FILE -ntomp 104 -ntmpi 1 -nsteps ${STEPS} -resethway" >"$RUN_DIR/mdrun_output.log" 2>&1
  mv md.log traj* ener.edr confout.gro state.cpt "$RUN_DIR/" 2>/dev/null

  if [ "$i" -le "$WARMUP_RUNS" ]; then
    echo "Warm-up run $i completed. Deleting files..."
    rm -rf "$RUN_DIR"
  else
    echo "Benchmark run $i completed. Data saved in $RUN_DIR."
  fi
done

echo "All benchmarking runs are complete!"
