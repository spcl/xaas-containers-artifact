#!/bin/bash

ARTIFACT_LOCATION=${ARTIFACT_LOCATION:-${HOME}/xaas-containers-artifact}

mkdir -p ${ARTIFACT_LOCATION}/data/llama.cpp
cd ${ARTIFACT_LOCATION}/data/llama.cpp

wget https://huggingface.co/TheBloke/Llama-2-13B-chat-GGUF/resolve/main/llama-2-13b-chat.Q4_K_M.gguf

