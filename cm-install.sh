#!/bin/bash

set -e

readonly DIR_SCRIPT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
readonly DIR_FIRMWARE=${DIR_SCRIPT}/firmware

source ${DIR_SCRIPT}/cm-common.sh

# Install binary files to /boot
cp ${DIR_FIRMWARE}/*${SOC}*.bin.* ${DIR_BIN}

# Install elf files to /lib/firmware
cp ${DIR_FIRMWARE}/*${SOC}*.elf.* ${DIR_ELF}

echo "Done"
