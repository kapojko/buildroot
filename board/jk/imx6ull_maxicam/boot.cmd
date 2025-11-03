# Load kernel and custom DTB
echo "Booting JK MaxiCam..."
load mmc 0:1 ${loadaddr} zImage
load mmc 0:1 ${fdt_addr_r} imx6ull_maxicam.dtb
bootz ${loadaddr} - ${fdt_addr_r}

