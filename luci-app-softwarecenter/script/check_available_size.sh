#!/bin/sh

PART_TYPES="ext2|ext3|ext4|.*fat|.*ntfs|fuseblk|btrfs|ufsd"; i=1
[ -f "/tmp/disk_size" ] && rm -rf /tmp/disk_size
for mounted in $(/bin/mount | grep -E "$PART_TYPES" | grep -v -E "/opt|/boot|/root" | grep -v -E -w "/" | cut -d' ' -f3) ; do
	for m in `seq 5`; do
		n=$((m + 1))
		eval value$m=`df -h | grep $mounted | awk '{print $(eval echo '$n')}'`
		eval pp$m=`/bin/mount | grep $mounted | awk '{print $5}'`
	done
	echo -e "[$i] $value5 [ 文件系统:$pp5 容量:$value1 已用比例:$value4(已用:$value2 可用:$value3) ]" | tee -a /tmp/disk_size
	i=$((i + 1))
done
