#!/bin/bash
#PBS -A workflow_scaling
#PBS -N gromacs_app_tests
#PBS -l walltime=02:00:00
#PBS -l filesystems=flare
#PBS -q prod

ARTIFACT_LOCATION=${ARTIFACT_LOCATION:-${HOME}/xaas-containers-artifact}
STEPS=1000

# FIXME: adapt for your configuration
module load fftw

source /soft/applications/Gromacs/gromacs-2024.5/build/bin/GMXRC

export OMP_NUM_THREADS=104

TESTCASE_DIR="${ARTIFACT_LOCATION}/benchmarks-source/gromacs/aurora/gromacs-benchmarks/TestcaseB_benchmarks/gromacs_native_testcaseB/steps_${STEPS}"
TPR_FILE="${ARTIFACT_LOCATION}/data/gromacs/GROMACS_TestCaseB/lignocellulose.tpr"

mkdir -p "$TESTCASE_DIR"

WARMUP_RUNS=10
BENCHMARK_RUNS=30
TOTAL_RUNS=$((WARMUP_RUNS + BENCHMARK_RUNS))

echo "GROMACS configuration"
which gmx_mpi
ldd $(which gmx_mpi)
gmx_mpi --version

for i in $(seq 1 $TOTAL_RUNS); do
  echo "Starting run $i..."

  RUN_DIR="$TESTCASE_DIR/run${i}"
  mkdir -p "$RUN_DIR"

  # FIXME: here put the instructions to run your execution
  # gmx for non-MPI, gmx_mpi for MPI
  gmx_mpi mdrun -s "$TPR_FILE" -ntomp 104 -nsteps ${STEPS} >"$RUN_DIR/mdrun_output.log" 2>&1

  mv md.log traj* ener.edr confout.gro state.cpt "$RUN_DIR/" 2>/dev/null

  if [ "$i" -le "$WARMUP_RUNS" ]; then
    echo "Warm-up run $i completed. Deleting files..."
    rm -rf "$RUN_DIR"
  else
    echo "Benchmark run $i completed. Data saved in $RUN_DIR."
  fi
done

echo "All benchmarking runs are complete!"
