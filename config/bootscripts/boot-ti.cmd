# DO NOT EDIT THIS FILE
#
# Please edit /boot/armbianEnv.txt to set supported parameters
#

# default values

setenv load_addr "0x12000000"
setenv ramdisk_addr "0x14800000"
setenv rootdev "/dev/mmcblk0p1"
setenv verbosity "1"
setenv console "both"
setenv disp_mode "1920x1080M60"
setenv rootfstype "ext4"

# Print boot source
echo "Booting from SD"

if ext4load mmc 0 ${load_addr} /boot/armbianEnv.txt || fatload mmc 0 ${load_addr} armbianEnv.txt; then
	env import -t ${load_addr} ${filesize}
fi

if test "${console}" = "display" || test "${console}" = "both"; then setenv consoleargs "console=tty1"; fi
if test "${console}" = "serial" || test "${console}" = "both"; then setenv consoleargs "${consoleargs} console=ttymxc1,115200"; fi


setenv bootargs "root=${rootdev} rootfstype=${rootfstype} rootwait ${consoleargs} video=mxcfb0:dev=hdmi,${disp_mode},if=RGB24,bpp=32 rd.dm=0 rd.luks=0 rd.lvm=0 raid=noautodetect pci=nomsi ahci_imx.hotplug=1 vt.global_cursor_default=0 loglevel=${verbosity} usb-storage.quirks=${usbstoragequirks} ${extraargs}"

ext4load mmc 0 ${ramdisk_addr} /boot/uInitrd || fatload mmc 0 ${ramdisk_addr} uInitrd || ext4load mmc 0 ${ramdisk_addr} uInitrd
ext4load mmc 0 ${loadaddr} /boot/zImage || fatload mmc 0 ${loadaddr} zImage

if load mmc 0 0x00000000 /boot/.next || load mmc 0 0x00000000 .next; then
	setenv fdt_file "imx6q-udoo.dtb"
	ext4load mmc 0 ${fdt_addr} /boot/dtb/${fdt_file} || fatload mmc 0 ${fdt_addr} dtb/${fdt_file}
else
	setenv fdt_file "imx6q-udoo-hdmi.dtb"
	ext4load mmc 0 ${fdt_addr} /boot/dtb/${fdt_file} || fatload mmc 0 ${fdt_addr} dtb/${fdt_file}
fi

bootz ${loadaddr} ${ramdisk_addr} ${fdt_addr}

# Recompile with:
# mkimage -C none -A arm -T script -d /boot/boot.cmd /boot/boot.scr 

