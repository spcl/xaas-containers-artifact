FROM spcleth/xaas:oneapi-2021.3.0

SHELL ["/bin/bash", "-c"]

COPY llama.cpp /llama.cpp
WORKDIR /llama.cpp

RUN apt-get update && \
    apt-get install -y --no-install-recommends wget ca-certificates && \
    wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/cuda-keyring_1.0-1_all.deb && \
    dpkg -i cuda-keyring_1.0-1_all.deb && \
    apt-get update && \
    apt-get install -y --no-install-recommends cmake cuda-toolkit-12.1
RUN apt-get install -y --no-install-recommends pkg-config git

ENV PATH="/usr/local/cuda-12.1/bin:$PATH"
ENV LD_LIBRARY_PATH="/usr/local/cuda-12.1/lib64:/usr/local/cuda-12.1/lib64/stubs:$LD_LIBRARY_PATH"

ENV NVIDIA_VISIBLE_DEVICES=all
ENV NVIDIA_DRIVER_CAPABILITIES=compute,utility
ENV NVIDIA_REQUIRE_CUDA="cuda>=12.1"

RUN ln -s /usr/local/cuda/lib64/stubs/libcuda.so /usr/local/cuda/lib64/stubs/libcuda.so.1

RUN . /opt/intel/oneapi/setvars.sh && cmake -B build \
    -DCMAKE_C_COMPILER=icx \
    -DCMAKE_CXX_COMPILER=icpx \
    -DGGML_BLAS=ON \
    -DGGML_BLAS_VENDOR="Intel10_64lp" \
    -DGGML_CUDA=ON \
    -DCMAKE_CUDA_ARCHITECTURES="70" \
    -DGGML_NATIVE=OFF \
    -DGGML_AVX512=ON \
    -DLLAMA_CURL=OFF \
    -DBLAS_INCLUDE_DIRS="$MKLROOT/include" && \
    cmake --build build --config Release -j12

RUN rm /usr/local/cuda/lib64/stubs/libcuda.so.1

CMD ["/bin/bash"]
