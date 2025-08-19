
This benchmark evaluates GROMACS baseline performance when compiled against specific vectorization options.

1. Run `install_dependencies.sh` to install CMake, Spack, and GCC 11.5 (Ault23). No need to execute it if it has already been done on Ault for `benchmarks-source/gromacs`.

2. Run `download_data.sh` to download GROMACS source code and inputs. No need to execute it if it has already been done on Ault for `benchmarks-source/gromacs`.

3. Build GROMACS, choosing the script for the system:

```
sbatch < build-scripts/ault/build.sh
sbatch < build-scripts/clariden/build.sh
```

4. Execute the benchmark, choosing the script for the system:

```
sbatch < benchmarking-scripts/ault/benchmark.sh
sbatch < benchmarking-scripts/clariden/benchmark.sh
```

5. Use the scripts `copy_output_data_ault.sh` and `copy_output_data_clariden.sh` to copy the generated data to a user-selected directory. 
The data should be placed inside `benchmarks/{intel,arm}`.
