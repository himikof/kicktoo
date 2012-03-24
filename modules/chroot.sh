chroot_dir="/mnt/chroot"

chroot_into() {
    mkdir -p $chroot_dir &>/dev/null
    echo "Checking type of setup: clear, luks or lvm"
    root=$(grep ^mountfs ${profile} | grep " / " | cut -d" " -f2)
    if $(echo $root | grep /dev/mapper 1>/dev/null 2>&1); then
        if is_luks; then
            echo "Found: $root luks"
            chroot_luks $root
        elif is_lvm; then
            echo "Found: $root lvm"
            chroot_lvm $root
        else
            echo "Found: $root"
            chroot_clear $root
        fi
    fi
}

is_luks() {
    cryptsetup isLuks $1 ; return $?
}
is_lvm() {
    local lvm=$(grep ^lvm_volgroup ${profile})
    [ -n $lvm ] && true
    return $?
}
chroot_clear() {
    mount $1 $chroot_dir

    mount -t proc proc  ${chroot_dir}/proc &>/dev/null
    mount -o rbind /dev ${chroot_dir}/dev  &>/dev/null
    mount -o bind /sys  ${chroot_dir}/sys  &>/dev/null

    echo "When done:"
    echo " # exit"
    echo " # kicktoo --close <profile>"
    echo "Chrooting..."

    chroot ${chroot_dir} /bin/bash
}

chroot_luks() {
    cryptsetup luksOpen ${1} root
    mount /dev/mapper/root ${chroot_dir}

    mount -t proc proc  ${chroot_dir}/proc &>/dev/null
    mount -o rbind /dev ${chroot_dir}/dev  &>/dev/null
    mount -o bind /sys  ${chroot_dir}/sys  &>/dev/null

    echo "When done:"
    echo " # exit"
    echo " # kicktoo --close <profile>"
    echo "Chrooting into LUKS device..."

    chroot ${chroot_dir} /bin/bash
}

chroot_lvm() {
    echo "lvm"
}

chroot_close() {
    if umount -l -f ${chroot_dir}/dev &>/dev/null; then
        echo "${chroot_dir}/dev umounted"
    fi
    if umount -l -f ${chroot_dir}/sys &>/dev/null; then
        echo "${chroot_dir}/sys umounted"
    fi
    if umount -l -f ${chroot_dir}/proc &>/dev/null; then
        echo "${chroot_dir}/proc umounted"
    fi
    if umount -l -f ${chroot_dir}/boot &>/dev/null; then
        echo "${chroot_dir}/boot umounted"
    fi
    if umount -l -f ${chroot_dir} &>/dev/null; then
        echo "${chroot_dir} umounted"
    fi
    cryptsetup luksClose root &>/dev/null
    if test -b /dev/mapper/root ; then
        echo "Your box is still opened!"
        echo "Rerun 'kicktoo --close <profile>' or reboot"
        exit 1
    fi
}
