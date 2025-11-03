#!/usr/bin/env bash

set -e

#
# dtb_list extracts the list of DTB files from BR2_LINUX_KERNEL_INTREE_DTS_NAME and BR2_LINUX_KERNEL_CUSTOM_DTS_PATH
# in ${BR_CONFIG}, then prints the corresponding list of file names for the
# genimage configuration file
#
dtb_list()
{
    local DTB_LIST=""

    # Handle in-tree DTS (BR2_LINUX_KERNEL_INTREE_DTS_NAME)
    if grep -q '^BR2_LINUX_KERNEL_INTREE_DTS_NAME=' "${BR2_CONFIG}"; then
        DTB_LIST="$(sed -n 's/^BR2_LINUX_KERNEL_INTREE_DTS_NAME="\([\/a-z0-9 \-]*\)"$/\1/p' "${BR2_CONFIG}")"
    fi

    # Handle custom DTS (BR2_LINUX_KERNEL_CUSTOM_DTS_PATH)
    if grep -q '^BR2_LINUX_KERNEL_CUSTOM_DTS_PATH=' "${BR2_CONFIG}"; then
        CUSTOM_DTS="$(sed -n 's|^BR2_LINUX_KERNEL_CUSTOM_DTS_PATH="\(.*\)"$|\1|p' "${BR2_CONFIG}")"
        if [ -n "${CUSTOM_DTS}" ]; then
            # Extract basename without .dts
            CUSTOM_DTB="$(basename "${CUSTOM_DTS}" .dts).dtb"
            DTB_LIST="${DTB_LIST} ${CUSTOM_DTB}"
        fi
    fi

    # Output as quoted list
    for dtb in ${DTB_LIST}; do
        echo -n "\"${dtb}\", "
    done
}

#
# linux_image extracts the Linux image format from BR2_LINUX_KERNEL_UIMAGE in
# ${BR_CONFIG}, then prints the corresponding file name for the genimage
# configuration file
#
linux_image()
{
	if grep -Eq "^BR2_LINUX_KERNEL_UIMAGE=y$" "${BR2_CONFIG}"; then
		echo "\"uImage\""
	elif grep -Eq "^BR2_LINUX_KERNEL_IMAGE=y$" "${BR2_CONFIG}"; then
		echo "\"Image\""
	elif grep -Eq "^BR2_LINUX_KERNEL_IMAGEGZ=y$" "${BR2_CONFIG}"; then
		echo "\"Image.gz\""
	else
		echo "\"zImage\""
	fi
}

genimage_type()
{
	if grep -Eq "^BR2_PACKAGE_FREESCALE_IMX_PLATFORM_IMX8=y$" "${BR2_CONFIG}"; then
		echo "genimage.cfg.template_imx8"
	elif grep -Eq "^BR2_PACKAGE_FREESCALE_IMX_PLATFORM_IMX8M=y$" "${BR2_CONFIG}"; then
		echo "genimage.cfg.template_imx8"
	elif grep -Eq "^BR2_PACKAGE_FREESCALE_IMX_PLATFORM_IMX8MM=y$" "${BR2_CONFIG}"; then
		echo "genimage.cfg.template_imx8"
	elif grep -Eq "^BR2_PACKAGE_FREESCALE_IMX_PLATFORM_IMX8MN=y$" "${BR2_CONFIG}"; then
		echo "genimage.cfg.template_imx8"
	elif grep -Eq "^BR2_PACKAGE_FREESCALE_IMX_PLATFORM_IMX8MP=y$" "${BR2_CONFIG}"; then
		echo "genimage.cfg.template_imx8"
	elif grep -Eq "^BR2_PACKAGE_FREESCALE_IMX_PLATFORM_IMX8X=y$" "${BR2_CONFIG}"; then
		echo "genimage.cfg.template_imx8"
	elif grep -Eq "^BR2_PACKAGE_FREESCALE_IMX_PLATFORM_IMX8DXL=y$" "${BR2_CONFIG}"; then
		echo "genimage.cfg.template_imx8"
	elif grep -Eq "^BR2_PACKAGE_FREESCALE_IMX_PLATFORM_IMX91=y$" "${BR2_CONFIG}"; then
		echo "genimage.cfg.template_imx9"
	elif grep -Eq "^BR2_PACKAGE_FREESCALE_IMX_PLATFORM_IMX93=y$" "${BR2_CONFIG}"; then
		echo "genimage.cfg.template_imx9"
	elif grep -Eq "^BR2_LINUX_KERNEL_INSTALL_TARGET=y$" "${BR2_CONFIG}"; then
		if grep -Eq "^BR2_TARGET_UBOOT_SPL=y$" "${BR2_CONFIG}"; then
		    echo "genimage.cfg.template_no_boot_part_spl"
		else
		    echo "genimage.cfg.template_no_boot_part"
		fi
	elif grep -Eq "^BR2_TARGET_UBOOT_SPL=y$" "${BR2_CONFIG}"; then
		echo "genimage.cfg.template_spl"
	else
		echo "genimage.cfg.template"
	fi
}

imx_offset()
{
	if grep -Eq "^BR2_PACKAGE_FREESCALE_IMX_PLATFORM_IMX8M=y$" "${BR2_CONFIG}"; then
		echo "33K"
	elif grep -Eq "^BR2_PACKAGE_FREESCALE_IMX_PLATFORM_IMX8MM=y$" "${BR2_CONFIG}"; then
		echo "33K"
	else
		echo "32K"
	fi
}

uboot_image()
{
	if grep -Eq "^BR2_TARGET_UBOOT_FORMAT_DTB_IMX=y$" "${BR2_CONFIG}"; then
		echo "u-boot-dtb.imx"
	elif grep -Eq "^BR2_TARGET_UBOOT_FORMAT_IMX=y$" "${BR2_CONFIG}"; then
		echo "u-boot.imx"
	elif grep -Eq "^BR2_TARGET_UBOOT_FORMAT_DTB_IMG=y$" "${BR2_CONFIG}"; then
	    echo "u-boot-dtb.img"
	elif grep -Eq "^BR2_TARGET_UBOOT_FORMAT_IMG=y$" "${BR2_CONFIG}"; then
	    echo "u-boot.img"
	fi
}

main()
{
	local FILES IMXOFFSET UBOOTBIN GENIMAGE_CFG GENIMAGE_TMP
	# FILES="$(dtb_list) $(linux_image), \"boot.scr\""
	FILES="imx6ull-14x14-evk.dtb, $(linux_image)"
	IMXOFFSET="$(imx_offset)"
	UBOOTBIN="$(uboot_image)"
	GENIMAGE_CFG="$(mktemp --suffix genimage.cfg)"
	GENIMAGE_TMP="${BUILD_DIR}/genimage.tmp"
	
	echo "DEBUG: FILES = [$FILES]" >&2

	sed -e "s/%FILES%/${FILES}/" \
		-e "s/%IMXOFFSET%/${IMXOFFSET}/" \
		-e "s/%UBOOTBIN%/${UBOOTBIN}/" \
		"board/freescale/common/imx/$(genimage_type)" > "${GENIMAGE_CFG}"

	rm -rf "${GENIMAGE_TMP}"

	genimage \
		--rootpath "${TARGET_DIR}" \
		--tmppath "${GENIMAGE_TMP}" \
		--inputpath "${BINARIES_DIR}" \
		--outputpath "${BINARIES_DIR}" \
		--config "${GENIMAGE_CFG}"

	rm -f "${GENIMAGE_CFG}"

	exit $?
}

main "$@"
