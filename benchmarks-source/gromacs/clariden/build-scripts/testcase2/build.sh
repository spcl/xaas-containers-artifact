#!/bin/bash
#SBATCH --job-name=gromacs_build
#SBATCH --time=00:30:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=72
#SBATCH --account=a-g200
#SBATCH --output=build_gromacs_container.out
#SBATCH --error=build_gromacs_container.err
#SBATCH --uenv=prgenv-gnu/24.11:v1
#SBATCH --view=modules

ARTIFACT_LOCATION=${ARTIFACT_LOCATION:-${SCRATCH}/xaas-containers-artifact}
DOCKER_REPOSITORY=${DOCKER_REPOSITORY:-"spcleth/xaas-artifact"}

cd ${ARTIFACT_LOCATION}/benchmarks-source/gromacs/clariden/build-scripts/testcase2

# first, create general system configuration for containers if it does not exist

CONF_FILE="$HOME/.config/containers/storage.conf"
if [ ! -f ${CONF_FILE} ]; then
	echo "Create ${CONF_FILE} because not found!"
	cat > ${CONF_FILE} << EOF
[storage]
driver = "overlay"
runroot = "/dev/shm/$USER/runroot"
graphroot = "/dev/shm/$USER/root"
EOF
fi

CONTAINER_IMAGE=gromacs_clariden.sqsh

# then, create the environment
ENVIRONMENT_FILE=${ARTIFACT_LOCATION}/benchmarks-source/gromacs/clariden/build-scripts/testcase2/environment.toml
echo "Create new ${ENVIRONMENT_FILE}"
cat > ${ENVIRONMENT_FILE} << EOF
image = "${ARTIFACT_LOCATION}/benchmarks-source/gromacs/clariden/build-scripts/testcase2/${CONTAINER_IMAGE}"
workdir = "${SCRATCH}"
writable = true

mounts = [
  "${SCRATCH}:${SCRATCH}"
]

[annotations]
com.hooks.cxi.enabled = "true"
EOF

IMAGE_NAME=gromacs-source-deploy-clariden

# schedule the build
podman build --platform linux/arm64 --build-arg nproc=72 -t docker.io/spcleth/xaas-artifact:${IMAGE_NAME} -f Dockerfile.deployment-clariden . 
enroot import -x mount -o ${CONTAINER_IMAGE} podman://${DOCKER_REPOSITORY}:${IMAGE_NAME}

# push to remote repository - optional
podman login docker.io -u spcleth -p Qk2EkvFrDdzLLtB
podman push docker.io/${DOCKER_REPOSITORY}:${IMAGE_NAME}
