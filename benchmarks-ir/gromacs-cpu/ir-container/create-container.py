#!/usr/bin/env python3

import yaml
import subprocess
import sys

PARALLEL_WORKERS = 16


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


with open("gromacs_vectorization.yml") as config_f:
    config = yaml.safe_load(config_f)

print(f"We will build GROMACS present in {sys.argv[1]}")
config["source_directory"] = sys.argv[1]

repository = sys.argv[2]

with open("gromacs_vectorization_config.yml", "w") as config_output:
    yaml.dump(config, config_output, default_flow_style=False)

print("Generate build configurations")
run_cmd("xaas buildgen gromacs_vectorization_config.yml")

print("Analyze build configurations")
run_cmd("xaas analyze gromacs_vectorization_config.yml")

print("Preprocess build configurations")
run_cmd(
    f"xaas preprocess run --parallel-workers {PARALLEL_WORKERS} gromacs_vectorization_config.yml"
)

print("Handle CPU tuning and opts")
run_cmd("xaas cpu-tuning run gromacs_vectorization_config.yml")

print("Compile to IRs")
run_cmd(
    f"xaas ir run --parallel-workers {PARALLEL_WORKERS} gromacs_vectorization_config.yml"
)

print("Create IR container")
run_cmd(
    f"xaas container --docker-repository {repository} gromacs_vectorization_config.yml"
)

for vectorization in ["SSE4.1", "AVX_256", "AVX2_128", "AVX2_256", "AVX_512"]:
    with open("gromacs_vectorization_deploy.yml") as config_f:
        config = yaml.safe_load(config_f)

    config["features_select"]["VECTORIZATION"] = vectorization
    config["docker_repository"] = repository
    config["ir_image"] = f"{repository}:{config['ir_image']}"

    output_fname = f"gromacs_vectorization_deploy_{vectorization}.yml"
    with open(output_fname, "w") as config_output:
        yaml.dump(config, config_output, default_flow_style=False)

    print(f"Create deployment container for {vectorization}")
    run_cmd(f"xaas deploy --parallel-workers {PARALLEL_WORKERS} {output_fname}")
