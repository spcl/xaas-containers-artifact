#!/usr/bin/env python3

import yaml
import subprocess
import sys
import os

PARALLEL_WORKERS = 16

repository = "spcleth/xaas-artifact"
if "DOCKER_REPOSITORY" in os.environ:
    repository = os.environ["DOCKER_REPOSITORY"]


def run_cmd(command: str):
    try:
        result = subprocess.run(command, capture_output=True, text=True, shell=True)

        if result.returncode != 0:
            print(f"Command failed with return code {result.returncode}")
            print("\n--- STDOUT ---")
            print(result.stdout)
            print("\n--- STDERR ---")
            print(result.stderr)
            return False

        return True

    except FileNotFoundError:
        print(f"Command not found: {command}")
        return False
    except Exception as e:
        print(f"Error executing command: {e}")
        return False


with open("gromacs_cuda.yml") as config_f:
    config = yaml.safe_load(config_f)

print(
    f"We will build GROMACS present in {sys.argv[1]}, building for Docker repository {repository}"
)
config["source_directory"] = sys.argv[1]

with open("gromacs_cuda_config.yml", "w") as config_output:
    yaml.dump(config, config_output, default_flow_style=False)

print("Generate build configurations")
run_cmd("xaas ir buildgen gromacs_cuda_config.yml")

print("Analyze build configurations")
run_cmd("xaas ir analyze gromacs_cuda_config.yml")

print("Preprocess build configurations")
run_cmd(
    f"xaas ir preprocess run --parallel-workers {PARALLEL_WORKERS} gromacs_cuda_config.yml"
)

print("Handle CPU tuning and opts")
run_cmd("xaas ir cpu-tuning run gromacs_cuda_config.yml")

print("Compile to IRs")
run_cmd(
    f"xaas ir irs run --parallel-workers {PARALLEL_WORKERS} gromacs_cuda_config.yml"
)

print("Create IR container")
run_cmd(f"xaas ir container --docker-repository {repository} gromacs_cuda_config.yml")

for deploy in ["ault23", "ault25"]:
    with open(f"gromacs_deploy_{deploy}.yml") as config_f:
        config = yaml.safe_load(config_f)

    config["docker_repository"] = repository
    config["ir_image"] = f"{repository}:{config['ir_image']}"

    output_fname = f"gromacs_cuda_deploy_{deploy}.yml"
    with open(output_fname, "w") as config_output:
        yaml.dump(config, config_output, default_flow_style=False)

    print(f"Create deployment container for {deploy}")
    run_cmd(f"xaas deploy --parallel-workers {PARALLEL_WORKERS} {output_fname}")
