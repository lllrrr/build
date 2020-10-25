#!/bin/sh
#check usb disk size
#version: 1.0

#
# Copyright (C) 2019 Jianpeng Xiang (1505020109@mail.hnust.edu.cn)
#
# This is free software, licensed under the GNU General Public License v3.
#

# 加载通用函数库
. /usr/bin/softwarecenter/lib_functions.sh
	case $1 in
	1)
		check_available_size "$2"
	;;
	2)
		PART_TYPES="ext2|ext3|ext4|.*fat|.*ntfs|fuseblk|btrfs|ufsd"; i=1
		for mounted in $(/bin/mount | grep -E "$PART_TYPES" | grep -v -E "/opt|/boot|/root" | grep -v -E -w "/" | cut -d' ' -f3) ; do
			for m in `seq 5`; do
				n=$((m + 1))
				eval value$m=`df -h | grep $mounted | awk '{print $(eval echo '$n')}'`
				eval pp$m=`/bin/mount | grep $mounted | awk '{print $5}'`
			done
			echo "[$i] $value5 [ 文件系统:$pp5 容量:$value1 已用比例:$value4(已用:$value2 可用:$value3) ]"
			i=$((i + 1))
		done
	;;
	3)
	if [[ -n `which lsscsi` ]]; then
		lsscsi | grep disk | awk '{print $NF}'
	elif [ -n `which mount` ]; then
		mount | grep mnt | awk '{print $3}'
	else
		blkid -s PARTLABEL | cut -d: -f1
	fi
	;;
	esac
