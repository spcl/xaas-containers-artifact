#!/bin/bash
#SBATCH --job-name=spack-gromacs
#SBATCH --output=spack-gromacs.out
#SBATCH --error=spack-gromacs.err
#SBATCH --time=4:00:00
#SBATCH --partition=normal
#SBATCH --account=a-g200
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=72
#SBATCH --uenv=prgenv-gnu/24.11:v1
#SBATCH --view=modules,spack

module load cray-mpich/8.1.30 cuda/12.6.2 cmake/3.30.5 gcc/13.3.0
echo "GCC version: " $(gcc --version)
echo "mpich version: " $(mpichversion)
MPICH_LOCATION="$(dirname $(dirname $(realpath $(which mpicxx))))"
echo "mpich location: " ${MPICH_LOCATION}

ARTIFACT_LOCATION=${ARTIFACT_LOCATION:-${SCRATCH}/xaas-containers-artifact}
source ${ARTIFACT_LOCATION}/dependencies/spack/share/spack/setup-env.sh

spack env create gromacs_advanced
spack env activate gromacs_advanced
spack compiler find
spack external find

# manually add external cray mpich
spack cd -e
mv spack.yaml spack.yaml.bak
yq w spack.yaml.bak 'spack.packages.cray-mpich.buildable' false | \
yq w - 'spack.packages.cray-mpich.variants' "+wrappers" | \
yq w - 'spack.packages.cray-mpich.externals[0].spec' "cray-mpich@8.1.30 %gcc" | \
yq w - 'spack.packages.cray-mpich.externals[0].prefix' ${MPICH_LOCATION} > spack.yaml
cd ${ARTIFACT_LOCATION}/benchmarks-source/gromacs/clariden

spack install --add gromacs@2024.4 +mpi +cuda +openmp cuda_arch=90 ^cray-mpich@8.1.30 ^cuda@12.6.2

# Run Spack commands
spack concretize --force
spack install -j$(nproc)
spack spec gromacs
spack env deactivate 
