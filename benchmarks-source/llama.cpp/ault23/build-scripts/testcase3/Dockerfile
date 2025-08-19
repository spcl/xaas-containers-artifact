FROM docker.io/spcleth/xaas:cuda-12.1 as cuda-12.1-layer
FROM docker.io/spcleth/xaas:oneapi-2021.3.0 as oneapi-2021.3.0-layer
FROM docker.io/spcleth/xaas-artifact:llamacpp-source-x86_64 AS SOURCE
SHELL ["/bin/bash", "-c"]

ARG nproc

COPY --from=cuda-12.1-layer /usr/local/cuda-12.1 /usr/local/cuda-12.1
COPY --from=oneapi-2021.3.0-layer /opt/intel /opt/intel

ENV PATH="/usr/local/cuda-12.1/bin:$PATH"
ENV LD_LIBRARY_PATH="/usr/local/cuda-12.1/lib64:$LD_LIBRARY_PATH"
RUN . /opt/intel/oneapi/setvars.sh --force &&  export XAAS_BLAS_PATH="${MKLROOT}" && cmake -B build -DGGML_AVX512=ON -DGGML_CUDA=ON -DGGML_OPENMP=ON -DGGML_BLAS=ON -DGGML_BLAS_VENDOR=Intel10_64lp -DCMAKE_C_COMPILER=icx -DCMAKE_CXX_COMPILER=icpx -DCMAKE_CUDA_ARCHITECTURES="70" -DGGML_NATIVE=OFF -DBLAS_INCLUDE_DIRS=${XAAS_BLAS_PATH}/include  -DLLAMA_CURL=OFF \
                && cmake --build build --config Release -j $(nproc)

CMD ["/bin/bash"]

ENV NVIDIA_VISIBLE_DEVICES all
ENV NVIDIA_DRIVER_CAPABILITIES compute,utility