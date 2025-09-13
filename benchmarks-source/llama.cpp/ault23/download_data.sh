#!/bin/bash

ARTIFACT_LOCATION=${ARTIFACT_LOCATION:-${SCRATCH}/xaas-containers-artifact}

mkdir -p ${ARTIFACT_LOCATION}/data/llama.cpp
cd ${ARTIFACT_LOCATION}/data/llama.cpp

git clone https://github.com/ggml-org/llama.cpp.git
cd llama.cpp && git checkout 307bfa253dea07c9270e78fa53b133504e9c3c9d && cd ..

wget https://huggingface.co/TheBloke/Llama-2-13B-chat-GGUF/resolve/main/llama-2-13b-chat.Q4_K_M.gguf

wget https://huggingface.co/TheBloke/Llama-2-13B-chat-GGUF/resolve/main/llama-2-13b-chat.Q4_0.gguf
