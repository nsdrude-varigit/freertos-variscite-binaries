#!/bin/sh

set -e

readonly DIR_SCRIPT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
readonly DIR_FIRMWARE=${DIR_SCRIPT}/firmware

source ${DIR_SCRIPT}/cm-common.sh

# Initialize default DTB if not already initialized
if [ -z ${DTB} ]; then
  DTB=${DEFAULT_DTB}
fi

# Select firmware from menu if not already initialized
if [ -z ${FW} ]; then
  select_fw_using_menu "bin" "${DIR_BIN}"
fi

# Detect Memory DDR or TCM based on firmware filename
if [ -z ${LOAD_ADDR} ]; then
  if [[ "${FW}" == *".ddr"* ]]; then
    LOAD_ADDR=${LOAD_ADDR_DDR}
  else
    LOAD_ADDR=${LOAD_ADDR_TCM}
  fi
fi

# Verify files exists
verify_file_exists ${DIR_BIN}/${FW}
verify_file_exists ${DIR_BIN}/${DTB}

# Configure u-boot environment variables
set -o xtrace
fw_setenv fdt_file "${DTB}"
fw_setenv use_${CM_TYPE} "yes"
fw_setenv ${CM_TYPE}_bin "${FW}"
fw_setenv ${CM_TYPE}_addr "${LOAD_ADDR}"
set +o xtrace

echo "Done. Reboot to run ${CM_TYPE} firmare"
