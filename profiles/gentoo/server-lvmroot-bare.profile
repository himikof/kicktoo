# Kicktoo barebone lvm profile for use with deployment systems like puppet

#part sda 2M 8e +      # linux lvm type

device=/dev/sda

do_part=yes
pre_partition() {
  sgdisk -g -o -n 1:1M:+4M -t 1:ef02 -n 2:0:0 -t 2:8e00 $device && partprobe $device
}
skip partition

lvm_volgroup vg ${device}2

#lvm_logvol vg 200M  boot
lvm_logvol vg 4G    swap
lvm_logvol vg 10G   root
#lvm_logvol vg 5G    var
#lvm_logvol vg 20G   srv

#format /dev/vg/boot ext4
format /dev/vg/swap swap
format /dev/vg/root ext4
#format /dev/vg/var  ext4
#format /dev/vg/srv  ext4

#mountfs /dev/vg/boot ext4 /boot
mountfs /dev/vg/swap swap
mountfs /dev/vg/root ext4 /     noatime
#mountfs /dev/vg/var  ext4 /var  noatime
#mountfs /dev/vg/srv  ext4 /srv  noatime

#mirror=http://distfiles.gentoo.org
mirror=http://mirror.yandex.ru/gentoo-distfiles

stage_latest            amd64
tree_type   snapshot    ${mirror}/snapshots/portage-latest.tar.bz2

makeconf_line RUBY_TARGETS ruby18
extra_packages puppet

post_install() {
  spawn_chroot "eix-update"
}
