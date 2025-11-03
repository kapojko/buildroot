#!/bin/sh
BOARD_DIR="$(dirname "$0")"
mkdir -p "${BINARIES_DIR}"
mkimage -C none -A arm -T script -d "${BOARD_DIR}/boot.cmd" "${BINARIES_DIR}/boot.scr"

# Rename custom DTB to EVK name so U-Boot finds it
cp "${BINARIES_DIR}/imx6ull_maxicam.dtb" "${BINARIES_DIR}/imx6ull-14x14-evk.dtb"
