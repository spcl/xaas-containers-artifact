#!/bin/bash

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
LOCAL_DEST_BASE=${SCRIPT_DIR}/..

perform_scp_no_otp() {
  local remote_system="$1"
  local remote_src="$2"
  local local_dest="$3"

  echo "Attempting to copy from ${remote_system}, from ${remote_src}"
  echo "To local destination: ${local_dest}"

  if scp -r "${remote_system}:${remote_src}" "${local_dest}"; then
    echo "SUCCESS: Transfer complete."
  else
    echo "FAILED: Transfer broken or no files found at ${remote_system}:${remote_src}"
    echo "Full output: $(cat /tmp/transfer.out)"
  fi
  echo "-----------------------------------------------------"
}

perform_scp_otp() {
  local remote_system="$1"
  local remote_src="$2"
  local local_dest="$3"

  read -p "Please provide OTP: " otp

  mkdir -p "$(dirname ${local_dest})"
  echo "Attempting to copy from ${remote_system}, from ${remote_src}"
  echo "To local destination: ${local_dest}"

  if /usr/bin/expect ${SCRIPT_DIR}/send_otp.sh ${otp} scp -r "${remote_system}:${remote_src}" "${local_dest}"; then
    echo "SUCCESS: Transfer complete."
  else
    echo "FAILED: Transfer broken or no files found at ${remote_system}:${remote_src}"
    echo "Full output: $(cat /tmp/transfer.out)"
  fi
  echo "-----------------------------------------------------"
}

perform_scp() {
  local remote_system="$1"
  local remote_src="$2"
  local local_dest="$3"

  if [[ "$SYSTEM" == "aurora" ]]; then
    perform_scp_otp "$remote_system" "$remote_src" "$local_dest"
  else
    perform_scp_no_otp "$remote_system" "$remote_src" "$local_dest"
  fi
}

if [ -z "$1" ]; then
  echo "Usage: $0 {ault|clariden|aurora}"
  exit 1
fi

SYSTEM=$1
USERNAME=$2

case "$SYSTEM" in
ault)
  SYSTEM_ADDRESS="${USERNAME}@ault.cscs.ch"
  ARTIFACT_PATH=$(ssh ${SYSTEM_ADDRESS} 'echo $SCRATCH')
  SYSTEM_NAME="ault23"
  ;;
clariden)
  SYSTEM_ADDRESS="${USERNAME}@clariden.cscs.ch"
  ARTIFACT_PATH=$(ssh ${SYSTEM_ADDRESS} 'echo $SCRATCH')
  SYSTEM_NAME="clariden"
  ;;
aurora)
  read -p "Please provide OTP: " otp

  SYSTEM_ADDRESS="${USERNAME}@aurora.alcf.anl.gov"
  read ARTIFACT_PATH < <(/usr/bin/expect ${SCRIPT_DIR}/send_otp.sh ${otp} ssh ${SYSTEM_ADDRESS} 'echo $HOME' | tail -n 1 | tr -d '\r')
  SYSTEM_NAME="aurora"
  ;;
*)
  echo "Error: Unknown system '$SYSTEM'. Please use 'ault', 'clariden', or 'aurora'."
  exit 1
  ;;
esac
ARTIFACT_PATH="${ARTIFACT_PATH}/xaas-containers-artifact"

echo "Starting SCP operations for system: $SYSTEM"
echo "Remote artifact base path: $ARTIFACT_PATH"
echo "====================================================="

# Case 1: benchmarks-source
echo "Running Test Case: benchmarks-source"

# Subcase 1.1: gromacs
REMOTE_GROMACS_SRC="${ARTIFACT_PATH}/benchmarks-source/gromacs/${SYSTEM_NAME}/gromacs-benchmarks"
LOCAL_GROMACS_DEST="${LOCAL_DEST_BASE}/benchmarks-source/gromacs/${SYSTEM_NAME}/gromacs-benchmarks"
perform_scp "$SYSTEM_ADDRESS" "$REMOTE_GROMACS_SRC" "$LOCAL_GROMACS_DEST"

# Subcase 1.2: llama.cpp
REMOTE_LLAMA_SRC="${ARTIFACT_PATH}/benchmarks-source/llama.cpp/${SYSTEM_NAME}/llama-benchmarks"
LOCAL_LLAMA_DEST="${LOCAL_DEST_BASE}/benchmarks-source/llama.cpp/${SYSTEM_NAME}/llama-benchmarks"
perform_scp "$SYSTEM_ADDRESS" "$REMOTE_LLAMA_SRC" "$LOCAL_LLAMA_DEST"

# Case 2: benchmarks-ir (only for ault)
if [ "$SYSTEM" = "ault" ]; then
  echo "Running Test Case: benchmarks-ir (Ault specific)"

  # Subcase 2.1: gromacs-cpu
  REMOTE_IR_CPU_SRC="${ARTIFACT_PATH}/benchmarks-ir/gromacs-cpu/ault01/gromacs-benchmarks"
  LOCAL_IR_CPU_DEST="${LOCAL_DEST_BASE}/benchmarks-ir/gromacs-cpu/ault01/gromacs-benchmarks"
  perform_scp "$SYSTEM_ADDRESS" "$REMOTE_IR_CPU_SRC" "$LOCAL_IR_CPU_DEST"

  # Subcase 2.2: gromacs-gpu on ault23
  REMOTE_IR_GPU23_SRC="${ARTIFACT_PATH}/benchmarks-ir/gromacs-gpu/ault23/gromacs-benchmarks"
  LOCAL_IR_GPU23_DEST="${LOCAL_DEST_BASE}/benchmarks-ir/gromacs-gpu/ault23/gromacs-benchmarks"
  perform_scp "$SYSTEM_ADDRESS" "$REMOTE_IR_GPU23_SRC" "$LOCAL_IR_GPU23_DEST"

  # Subcase 2.3: gromacs-gpu on ault25
  REMOTE_IR_GPU25_SRC="${ARTIFACT_PATH}/benchmarks-ir/gromacs-gpu/ault25/gromacs-benchmarks"
  LOCAL_IR_GPU25_DEST="${LOCAL_DEST_BASE}/benchmarks-ir/gromacs-gpu/ault25/gromacs-benchmarks"
  perform_scp "$SYSTEM_ADDRESS" "$REMOTE_IR_GPU25_SRC" "$LOCAL_IR_GPU25_DEST"

fi

echo "All operations for $SYSTEM are complete."
