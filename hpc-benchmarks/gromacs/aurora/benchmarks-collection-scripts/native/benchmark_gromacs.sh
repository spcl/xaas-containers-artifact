#!/bin/bash
#PBS -A workflow_scaling
#PBS -N gromacs_app_tests
#PBS -l walltime=00:60:00
#PBS -l filesystems=flare
#PBS -q debug

# FIXME: adapt for your configuration
module load fftw

# FIXME: adapt for your configuration - if inside the container
source /soft/applications/Gromacs/gromacs-2024.5/build/bin/GMXRC

# FIXME: adapt for your configuration
export OMP_NUM_THREADS=104     # Use 16 OpenMP threads

# FIXME: change the path for the output of the result
TESTCASE_DIR="$HOME/xaas-containers-artifact/hpc-benchmarks/gromacs/aurora/gromacs-benchmarks/TestcaseB_benchmarks/gromacs_native_testcaseB"
# FIXME: change the input directory for test case B
TPR_FILE="$HOME/xaas-containers/data/GROMACS_TestCaseB/lignocellulose.tpr"

mkdir -p "$TESTCASE_DIR"

WARMUP_RUNS=10
BENCHMARK_RUNS=30
TOTAL_RUNS=$((WARMUP_RUNS + BENCHMARK_RUNS))

for i in $(seq 1 $TOTAL_RUNS); do
  echo "Starting run $i..."

  RUN_DIR="$TESTCASE_DIR/run${i}"
  mkdir -p "$RUN_DIR"

  # FIXME: here put the instructions to run your execution
  # gmx for non-MPI, gmx_mpi for MPI
  gmx_mpi mdrun -s "$TPR_FILE" -ntomp 104 -nsteps 100 >"$RUN_DIR/mdrun_output.log" 2>&1

  mv md.log traj* ener.edr confout.gro state.cpt "$RUN_DIR/" 2>/dev/null

  if [ "$i" -le "$WARMUP_RUNS" ]; then
    echo "Warm-up run $i completed. Deleting files..."
    rm -rf "$RUN_DIR"
  else
    echo "Benchmark run $i completed. Data saved in $RUN_DIR."
  fi
done

echo "All benchmarking runs are complete!"
