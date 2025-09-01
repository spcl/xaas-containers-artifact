## Microbenchmark: Container MPI Performance on Alps

This simple microbenchmark uses OSU benchmarks to evaluate the performance impact of using different container hooks on the CSCS Alps system.

* All container files are provided in `containers`. Use `download_containers.sh` to convert them to the SquashFS format for Podman.
* For bare-metal, OSU benchmarks can be installed with `install_osu.sh`.
* We run the following combinations: bare-metal MPI, MPICH and OpenMPI with and w/o hooks, and MPICH and MPI with lnx provider.

