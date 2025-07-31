# Use intel/hpckit:latest as the base image
FROM intel/hpckit:latest

# Update package lists
RUN apt-get update && \
    # Install dependencies for GROMACS
    apt-get install -y build-essential python3 pip libfftw3-dev libxml2-dev wget tar && \
    # Clean up to reduce the size of the container
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install CMake
RUN pip install cmake

# Set environment variables
SHELL ["/bin/bash", "-c"] 

# Get the GROMACS code
RUN wget https://ftp.gromacs.org/gromacs/gromacs-2025.0.tar.gz && tar -xzf gromacs-2025.0.tar.gz && mv gromacs-2025.0 /opt/gromacs

# Build the code
# https://www.intel.com/content/www/us/en/developer/articles/training/build-gromacs-with-intel-oneapi-dpc-c-compiler.html
# BLAS and FFT are automatically recognized as MKL
RUN mkdir -p /opt/gromacs/build && cd /opt/gromacs/build && cmake .. -DCMAKE_C_COMPILER=icx -DCMAKE_CXX_COMPILER=icpx -DGMX_GPU=SYCL -DGMX_GPU_NB_NUM_CLUSTER_PER_CELL_X=1 -DGMX_GPU_NB_CLUSTER_SIZE=8 && make -j$(nproc) && make install

# Clean up to reduce the size of the container
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /opt/gromacs/build

#install MPICH
#RUN wget -O mpich-4.2.3.tar.gz http://www.mpich.org/static/downloads/4.2.3/mpich-4.2.3.tar.gz && tar xzf mpich-4.2.3.tar.gz && \
#    cd mpich-4.2.3 && ./configure --prefix=/opt/mpich && make -j$(nproc) install
#
#ENV PATH=/opt/mpich/bin:$PATH
#ENV LD_LIBRARY_PATH=/opt/mpich/lib:$LD_LIBRARY_PATH

# Build gmx-mpi
RUN mkdir -p /opt/gromacs/build_mpi && cd /opt/gromacs/build_mpi && cmake .. -DCMAKE_C_COMPILER=icx -DCMAKE_CXX_COMPILER=icpx -DGMX_GPU=SYCL -DGMX_GPU_NB_NUM_CLUSTER_PER_CELL_X=1 -DGMX_GPU_NB_CLUSTER_SIZE=8 -DGMX_MPI=on && make -j$(nproc) && make install

# Clean up to reduce the size of the container
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /opt/gromacs/build_mpi

# Set environment variables
ENV PATH="/usr/local/gromacs/bin:${PATH}"
ENV GMX_GPU="force"

# Set the entrypoint to run GROMACS
CMD ["gmx_mpi"]
