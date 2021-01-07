## Summary
This directory contains compiled Cortex M4/M7 firmware for Variscite modules. It also contains scripts to install and load the firmware from U-Boot and Linux environments.

## Supported Devices
The `firmware` directory contains precompiled binaries for:

* imx8mq-var-dart
* imx8mm-var-dart
* imx8mm-var-som
* imx8mn-var-som

## Firmware
The firmware comes in two formats, `.elf` and `.bin`. The `elf` files should be installed to `/lib/firmware` and are used when loading firmware in Linux using remoteproc framework. The `bin` files should be installed to `/boot/` and are used when loading firmware via U-Boot.

## Firmware Installation
`.elf` and `.bin` files are installed by running `cm-install.sh` on the target device. 

```
root@imx8mq-var-dart:~/freertos-variscite-binaries# ./cm-install.sh 
Detected DART-MX8M
Done
```

## Running firmware from U-Boot
`cm-load-uboot.sh` is a helper script to configure the U-Boot environment variables to load the firmware on boot:

```
root@imx8mq-var-dart:~/freertos-variscite-binaries# FW=dart_mx8mq.hello_world.bin.debug ./cm-load-uboot.sh                                                  
Detected DART-MX8M
+ fw_setenv fdt_file imx8mq-var-dart-dt8mcustomboard-m4-sd-lvds.dtb
+ fw_setenv use_m4 yes
+ fw_setenv m4_bin dart_mx8mq.hello_world.bin.debug
+ fw_setenv m4_addr 0x7E0000
+ set +o xtrace
Done. Reboot to run m4 firmare
```

If the `FW` variable is not set, the script will show a menu allowing the user to select firmware in `/boot/`

## Running firmware from Linux
`cm-load-linux.sh` is a helper script to load firmware using the Linux remoteproc framework:

```
root@imx8mq-var-dart:~/freertos-variscite-binaries# FW=dart_mx8mq.hello_world.elf.debug ./cm-load-linux.sh
Detected DART-MX8M
Cortex-M: Stopping
[ 2220.844723] remoteproc remoteproc0: stopped remote processor imx-rproc
Cortex-M: Loading dart_mx8mq.hello_world.elf.debug
[ 2220.854449] remoteproc remoteproc0: powering up imx-rproc
Cortex-M: Starting
[ 2220.862685] remoteproc remoteproc0: Booting fw image dart_mx8mq.hello_world.elf.debug, size 302080
[ 2220.873800] imx-rproc imx8mq-cm4: m4 ddr @ 0x7e000000
[ 2220.878870] remoteproc remoteproc0: no dtb rsrc-table
[ 2220.884112] imx-rproc imx8mq-cm4: Setting up stack pointer and reset vector from firmware in TCML
[ 2220.892998] imx-rproc imx8mq-cm4: Stack: 0x20020000
[ 2220.897913] imx-rproc imx8mq-cm4: Reset Vector: 0x1ffe030d
[ 2220.953437] remoteproc remoteproc0: remote processor imx-rproc is now up
done
```

If the `FW` variable is not set, the script will show a menu allowing the user to select firmware in `/lib/firmware/`