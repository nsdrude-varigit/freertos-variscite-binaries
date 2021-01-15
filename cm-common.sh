#!/bin/bash

# Set nullglob for select_fw_using_menu searching for elf/bin files
# when no files are found
shopt -s nullglob

# Increase loglevel
sysctl kernel.printk=7 > /dev/null

readonly DIR_BIN="/boot"
readonly DIR_ELF="/lib/firmware"
readonly MACHINE="$(cat /sys/bus/soc/devices/soc0/machine)"
readonly MACHINE_LC=$(echo "$MACHINE" | tr '[:upper:]' '[:lower:]')

# Verify SOC is supported
case $MACHINE in
  *" DART-MX8M "*)
    echo "Detected DART-MX8M"
    source ${DIR_SCRIPT}/configs/imx8mq-var-dart.config
    ;;
  *" DART-MX8M-MINI "*)
    echo "Detected DART-MX8M-MINI"
    source ${DIR_SCRIPT}/configs/imx8mm-var-dart.config
    ;;
  *" VAR-SOM-MX8M-MINI "*)
    echo "Detected VAR-SOM-MX8M-MINI"
    source ${DIR_SCRIPT}/configs/imx8mm-var-som.config
    ;;
  *" VAR-SOM-MX8M-NANO "*)
    echo "Detected VAR-SOM-MX8M-NANO"
    source ${DIR_SCRIPT}/configs/imx8mn-var-som.config
    ;;
  *" VAR-SOM-MX8X "*)
    echo "Detected VAR-SOM-MX8X"
    source ${DIR_SCRIPT}/configs/imx8qxp-var-som.config
    ;;
  *)
    echo "Unsupported MACHINE ${MACHINE}"
    exit
    ;;
esac

readonly UBOOT_USE_M4_VALUE="$(fw_printenv ${UBOOT_USE_M4} -n)"

# Verify system is configured correctly to use m4/m7
verify_configuration() {
    verify_uboot_env
    verify_machine_model
}

# Make sure device tree with m4 or m7 support is used
verify_machine_model() {
    if [[ "${MACHINE_LC}" != *"${CM_TYPE}"* ]]; then
        echo ""
        echo "Error: /sys/bus/soc/devices/soc0/machine does not contain ${CM_TYPE}"
        echo "Please reboot with correct device tree file"
        echo ""
        echo "Example: fw_setenv fdt_file ${DEFAULT_DTB}"
        echo ""
        exit
    fi
}

# Make sure use_m4 or use_m7 u-boot environment variable is set
verify_uboot_env() {
    if [ "${UBOOT_USE_M4_VALUE}" != "yes" ]; then
        echo ""
        echo "Error: u-boot environment variable ${UBOOT_USE_M4} != yes"
        echo "Please run: 'fw_setenv ${UBOOT_USE_M4} yes' and reboot"
        echo ""
        exit
    fi
}

# Create menu to select cortex firmware
createmenu_fw () {
  select option; do # in "$@" is the default
    if [ "$REPLY" -eq "$#" ]; then
      echo "Exiting..."
      exit 1
    elif [ 1 -le "$REPLY" ] && [ "$REPLY" -le $(($#-1)) ]; then
      echo "Selected $option"
      FW="$option"
      break;
    else
      echo "Incorrect Input: Select a number 1-$#"
    fi
  done
}

# Create menu to select memory type
createmenu_memory () {
  select option; do # in "$@" is the default
    if [ "$REPLY" -eq "$#" ]; then
      echo "Exiting..."
      exit 1
    elif [ 1 -le "$REPLY" ] && [ "$REPLY" -le $(($#-1)) ]; then
      echo "Selected $option"
      CM_MEMORY="$option"
      break;
    else
      echo "Incorrect Input: Select a number 1-$#"
    fi
  done
}

# Create menu for user to filter and select M4/M7 firmware
select_fw_using_menu() {
  FW_EXTENSION=$1
  DIR_FW=$2

  # Use menu to select firmware files found in /lib/firmware
  echo "Please select running from TCM or DDR memory:"
  createmenu_memory "${MEMORY_OPTIONS[@]}"

  FW_OPTIONS=(${DIR_FW}/*.${FW_EXTENSION}.${CM_MEMORY})
  for ((i=0; i<${#FW_OPTIONS[@]}; i++)); do
          FW_OPTIONS[$i]="$(basename ${FW_OPTIONS[$i]})"
  done
  FW_OPTIONS[${#FW_OPTIONS[@]}]="Exit"

  if [ ${#FW_OPTIONS[@]} = "1" ]; then
    echo ""
    echo "Error: No .${FW_EXTENSION}.${CM_MEMORY} files found in ${DIR_FW}"
    echo "Please run cm-install.sh"
    echo ""
    exit
  fi

  echo "Please set FW environment variable, or choose a firmware file to run:"
  createmenu_fw "${FW_OPTIONS[@]}"
}

verify_file_exists() {
  FILEPATH=$1

  # Final verification file is in /lib/firmware
  if [ ! -f ${FILEPATH} ]; then
    echo ""
    echo "Error: '${FILEPATH}' not found"
    echo ""
    exit
  fi
}
