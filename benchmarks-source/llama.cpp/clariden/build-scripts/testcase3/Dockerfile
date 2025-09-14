FROM docker.io/spcleth/xaas:cuda-12.6-arm as cuda-12.6-arm-layer
FROM docker.io/spcleth/xaas-artifact:llama.cpp-source-arm64 AS SOURCE
SHELL ["/bin/bash", "-c"]

ARG nproc

COPY --from=cuda-12.6-arm-layer /usr/local/cuda-12.6 /usr/local/cuda-12.6

ENV PATH="/usr/local/cuda-12.6/bin:$PATH"
ENV LD_LIBRARY_PATH="/usr/local/cuda-12.6/lib64:$LD_LIBRARY_PATH"
RUN cmake -B build -DGGML_CUDA=ON -DGGML_OPENMP=ON -DCMAKE_C_COMPILER=gcc -DCMAKE_CXX_COMPILER=g++ -DCMAKE_CUDA_ARCHITECTURES="90" -DLLAMA_CURL=OFF \
                && cmake --build build --config Release -j $(nproc)

CMD ["/bin/bash"]

ENV NVIDIA_VISIBLE_DEVICES all
ENV NVIDIA_DRIVER_CAPABILITIES compute,utility
