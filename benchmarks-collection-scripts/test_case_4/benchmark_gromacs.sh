#!/bin/bash
#SBATCH --job-name=benchmark_gromacs   # Job name
#SBATCH --output=gromacs%j.out        # Save output log
#SBATCH --error=gromacs_%j.err         # Save error log
#SBATCH --nodelist=ault23                # Assign the job to ault23
#SBATCH --ntasks=4                        # 4 MPI processes
#SBATCH --cpus-per-task=16                # 16 OpenMP threads per MPI process
#SBATCH --gpus=1                          # 1 GPU
#SBATCH --time=4:00:00                    # Max time limit (adjust as needed)
#SBATCH --exclusive                       # Ensures no other jobs run on this node

# Load required modules
module load cuda/12.1.1 intel-oneapi-mpi/2021.3.0 intel-oneapi-mkl/2021.3.0


# Load Spack environment
source $HOME/spack/share/spack/setup-env.sh

spack env activate gromacs_basic

spack load gromacs@2024.4


# Source the GROMACS binary
source $HOME/spack/opt/spack/linux-centos8-skylake_avx512/gcc-11.5.0/gromacs-2024.4-cjlslyn3minh2wgla4rqgsdbbjdcnf4j/bin/GMXRC


export OMP_NUM_THREADS=16        

# Define paths
TESTCASE_DIR="$HOME/gromacs_testcase4_testcaseA"
TPR_FILE="$HOME/GROMACS_TestCaseA/ion_channel.tpr"


mkdir -p "$TESTCASE_DIR"

WARMUP_RUNS=10
BENCHMARK_RUNS=30
TOTAL_RUNS=$((WARMUP_RUNS + BENCHMARK_RUNS))


for i in $(seq 1 $TOTAL_RUNS); do
    echo "Starting run $i..."

   
    RUN_DIR="$TESTCASE_DIR/run${i}"
    mkdir -p "$RUN_DIR"

    mpirun -np 4 gmx_mpi mdrun -s "$TPR_FILE" -ntomp 16 -gpu_id 0 -nsteps 100 > "$RUN_DIR/mdrun_output.log" 2>&1

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