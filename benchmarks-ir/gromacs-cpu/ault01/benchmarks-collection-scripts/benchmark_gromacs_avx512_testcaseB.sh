#!/bin/bash
#SBATCH --job-name=benchmark_gromacs   # Job name
#SBATCH --output=gromacs%j.AVX_512.out        # Save output log
#SBATCH --error=gromacs%j.AVX_512.err         # Save error log
#SBATCH --ntasks=1                        # 4 MPI processes
#SBATCH --nodes=1                        # 4 MPI processes
#SBATCH --time=4:00:00                    # Max time limit
#SBATCH --exclusive                       # Ensures no other jobs run on this node

module load sarus/1.6

export OMP_NUM_THREADS=${SLURM_CPUS_PER_TASK}

# Define paths (on host)
ARCH_TYPE="AVX_512"
TESTCASE_DIR="/scratch/mcopik/2025/xaas/xaas-containers-artifact/hpc-benchmarks/gromacs-cpu/ault01/gromacs-benchmarks/TestcaseB_benchmarks/gromacs_${ARCH_TYPE}_testcaseB"
TPR_FILE="/scratch/mcopik/2025/xaas/xaas-containers-artifact/hpc-benchmarks/gromacs-cpu/ault01/GROMACS_TestCaseB/lignocellulose.tpr"
CONTAINER_IMAGE="spcleth/xaas:gromacs-deploy-_${ARCH_TYPE}"

mkdir -p "$TESTCASE_DIR"

#WARMUP_RUNS=10
#BENCHMARK_RUNS=30
WARMUP_RUNS=2
BENCHMARK_RUNS=30
TOTAL_RUNS=$((WARMUP_RUNS + BENCHMARK_RUNS))

echo ${OMP_NUM_THREADS}
echo "Hostname: $(hostname)"

for i in $(seq 1 $TOTAL_RUNS); do
    echo "Starting run $i..."

    RUN_DIR="$TESTCASE_DIR/run${i}"
    LOG_FILE="$RUN_DIR/mdrun_output.log"

    mkdir -p "$RUN_DIR"

    sarus run --mount=type=bind,source="/scratch/mcopik/2025/xaas/xaas-containers-artifact/hpc-benchmarks/gromacs-cpu/ault01/",destination="/scratch" \
    ${CONTAINER_IMAGE} bash -c "export OMP_NUM_THREADS=${SLURM_CPUS_PER_TASK} && export OMP_PLACES=cores && \
    mkdir -p \"/scratch/gromacs-benchmarks/TestcaseB_benchmarks/gromacs_${ARCH_TYPE}_testcaseB/run${i}\" && \
    /build/bin/gmx mdrun -s \"/scratch/GROMACS_TestCaseB/lignocellulose.tpr\" -ntomp ${SLURM_CPUS_PER_TASK} -ntmpi 1 -nsteps 100 > \"/scratch/gromacs-benchmarks/TestcaseB_benchmarks/gromacs_${ARCH_TYPE}_testcaseB/run${i}/mdrun_output.log\" 2>&1 && \
    mv md.log traj* ener.edr confout.gro state.cpt \"/scratch/gromacs-benchmarks/TestcaseB_benchmarks/gromacs_${ARCH_TYPE}_testcaseB/run${i}/\" 2>/dev/null"
 
    if [ "$i" -le "$WARMUP_RUNS" ]; then
        echo "Warm-up run $i completed. Deleting files..."
        #rm -rf "$RUN_DIR"
    else
        echo "Benchmark run $i completed. Data saved in $RUN_DIR."
    fi
done

echo "All benchmarking runs are complete!"
