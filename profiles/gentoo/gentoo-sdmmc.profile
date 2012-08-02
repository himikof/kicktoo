# Kicktoo profile for Beaglebone, Pandaboard or some other creditcard-size
# computer running from an SD/MMC and requiring a specific geometry.
#
# http://processors.wiki.ti.com/index.php/SD/MMC_format_for_OMAP3_boot

# setting some variables
DISK="mmcblk0"
SIZE=`fdisk -l /dev/$DISK | grep Disk | awk '{print $5}'`
HEADS=255
SECTORS=63
CYLINDERS=`echo $SIZE/$HEADS/$SECTORS/512 | bc`

# setting kicktoo config
geometry $HEADS $SECTORS $CYLINDERS

part $DISK 1 b 100M boot
part $DISK 2 83 +

format "/dev/${DISK}p1" fat32
format "/dev/${DISK}p2" ext3

mountfs /dev/${DISK}p2 ext3 /

# armv7a or armv7a_hardfp for Beagle and Pandaboard
# armv6j or armv6j_hardfp for Raspberry Pi 
stage_latest armv6j_hardfp
tree_type snapshot http://distfiles.gentoo.org/snapshots/portage-latest.tar.bz2

# you have to set the other settings manually because
# Kicktoo doesn't support cross architecture (yet)
