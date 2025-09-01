#!/bin/bash

# module load cray-mpich/8.1.30 gcc/13.3.0

wget -q http://mvapich.cse.ohio-state.edu/download/mvapich/osu-micro-benchmarks-7.5.tar.gz
tar -xf osu-micro-benchmarks-7.5.tar.gz

cd osu-micro-benchmarks-7.5
CC=$(which mpicc) CFLAGS="-O3" ./configure --prefix=$(pwd)/../osu-install
make -j12
make install
