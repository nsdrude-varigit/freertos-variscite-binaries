#!/bin/sh

set -e

readonly DIR_SCRIPT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
readonly DIR_FIRMWARE=${DIR_SCRIPT}/firmware
readonly REMOTEPROC_DIR="/sys/class/remoteproc/remoteproc0"
readonly REMOTEPROC_STATE="${REMOTEPROC_DIR}/state"
readonly REMOTEPROC_FW="${REMOTEPROC_DIR}/firmware"

source ${DIR_SCRIPT}/cm-common.sh

cm_stop() {
  if [ "running" == "$(cat ${REMOTEPROC_STATE})" ]; then
        echo "Cortex-M: Stopping"
        echo "stop" > ${REMOTEPROC_STATE}
  fi
}

cm_load() {
  CM_NEW_FW=$1
  echo "Cortex-M: Loading ${CM_NEW_FW}"
  echo "${CM_NEW_FW}" > ${REMOTEPROC_FW}
}

cm_start() {
  echo "Cortex-M: Starting"
  echo "start" > ${REMOTEPROC_STATE}
}

# Verify m4 device tree, use_m4 u-boot variable, etc.
verify_configuration

# Select firmware from menu if not already initialized
if [ -z ${FW} ]; then
  select_fw_using_menu "elf" "${DIR_ELF}"
fi

# Verify firmware file exists
verify_file_exists ${DIR_ELF}/${FW}

# Run the firmware
cm_stop
cm_load "${FW}"
cm_start

echo "done"
