FROM spcleth/xaas:deps-fftw3-3.3.10-SSE4.1 as deps-fftw3-layer
FROM spcleth/xaas:llvm-19

COPY --from=deps-fftw3-layer /opt/fftw3 /opt/fftw3

ADD gromacs-2025.0 /

ENV CC=/usr/bin/clang-19
ENV CXX=/usr/bin/clang++-19

RUN mkdir -p /build \
  && cd /build \
  && cmake .. -DCMAKE_C_COMPILER=clang-19 -DCMAKE_CXX_COMPILER=clang++-19 -DGMX_SIMD=SSE4.1 -DGMX_BUILD_OWN_FFTW=OFF -DFFTWF_INCLUDE_DIR=/opt/fftw3/include -DFFTWF_LIBRARY=/opt/fftw3/lib/libfftw3f.a \
  && make -j12

