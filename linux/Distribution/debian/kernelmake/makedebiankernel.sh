#!/bin/bash


# for example with lxzm tarba
URLKERNEL="$1"

apt-get install fakeroot kernel-package

wget -c $URLKERNEL --output-document kernel-current.tar.xz

tar jxvf kernel-current.tar.xz --lxzm



cd kernel-current

cp /boot/config-`uname -r` ./.config

make menuconfig

make-kpkg clean

export CONCURRENCY_LEVEL=5

fakeroot make-kpkg --append-to-version "-customkernel" --revision "1" --initrd kernel_image kernel_headers
