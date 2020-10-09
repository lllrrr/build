#!/bin/sh
#Write for Almquist Shell
#version: 1.8

#
# Copyright (C) 2019 Jianpeng Xiang (1505020109@mail.hnust.edu.cn)
#
# This is free software, licensed under the GNU General Public License v3.
#

pkglist_base="wget unzip e2fsprogs ca-certificates coreutils-whoami"

status(){
	local p=$?
	echo -en "\\033[40G[ "
	if [ "$p" = "0" ]; then
		echo -en "\\033[1;33m成功\\033[0;39m ]"
		return 0
	else
		echo -en "\\033[1;31m失败\\033[0;39m ]"
		return 1
	fi
}

_make_dir(){
for p in "$@"; do
	[ -d "$p" ] || { mkdir -p $p && echo "创建$p目录成功！";}
done
return 0
}

##### entware环境设定 #####
##参数：$1:设备底层架构 $2:安装位置
##说明：此函数用于写入新配置
entware_set(){
	entware_unset
	get_usb_path

	# 修补以适应外部传参
	if [ -n "$2" ]; then
		USB_PATH="$2"
	fi

	# 安装基本软件支持
	install_soft "$pkglist_base"
	filesystem_check $USB_PATH

	_make_dir "$USB_PATH/opt" "/opt"
	mount -o bind $USB_PATH/opt /opt
	if [ "$1" == "mipsel" ]; then
		wget -O - http://bin.entware.net/mipselsf-k3.4/installer/generic.sh | /bin/sh
	elif [ "$1" == "mips" ]; then
		wget -O - http://bin.entware.net/mipssf-k3.4/installer/generic.sh | /bin/sh
	elif [ "$1" == "armv7" ]; then
		wget -O - http://bin.entware.net/armv7sf-k3.2/installer/generic.sh | /bin/sh
	elif [ "$1" == "x86_64" ]; then
		wget -O - http://bin.entware.net/x64-k3.2/installer/generic.sh | /bin/sh
	elif [ "$1" == "x86" ]; then
		wget -O - http://bin.entware.net/x86-k2.6/installer/generic.sh | /bin/sh
	elif [ "$1" == "aarch64" ]; then
		wget -O - http://bin.entware.net/aarch64-k3.10/installer/generic.sh | /bin/sh
	else
		echo "未输入安装的架构！"
		exit 1
	fi
	rm /etc/init.d/entware
	cat > "/etc/init.d/entware" <<-\ENTWARE
#!/bin/sh /etc/rc.common
START=51

##### 获取外置挂载点 #####
##说明：该功能为新增功能，推荐使用此功能获取外置挂载点，get_usb_path的替代品
get_externel_mount_point(){
	mount_list=`lsblk -s | grep mnt | awk '{print $7}'`
	echo "$mount_list"
}

##### 获取entware安装路径 #####
##说明：解决entware开机脚本找不到路径的问题，该函数负责将找到的entware路径返回，有多个目录则返回最先找到的
get_entware_path()
{
	mount_list=`get_externel_mount_point`
	for mount_point in $mount_list ; do
		if [ -d "$mount_point/opt" ]; then
			echo "$mount_point/opt"
			break
		fi
	done
}

start(){
	mkdir -p /opt
	ENTWARE_PATH=`get_entware_path`
	mount -o bind $ENTWARE_PATH /opt
	# 该功能已被softwarecenter所接管
	#/opt/etc/init.d/rc.unslung start
}

stop(){
	/opt/etc/init.d/rc.unslung stop
	umount -lf /opt
	rm -r /opt
}

restart(){
	stop;start
}
ENTWARE
	##此设定目录方式因不支持动态获取已废弃##
	##使用分隔符:替代/（替换字串中含有/）
	#sed -i "s:USB_PATH:$USB_PATH:g" /etc/init.d/entware
	chmod a+x /etc/init.d/entware
	/etc/init.d/entware enable
	echo "export PATH=/opt/bin:/opt/sbin:\$PATH" >> /etc/profile
}

##### entware环境解除 #####
##说明：此函数用于删除OPKG配置设定
entware_unset(){
	/etc/init.d/entware stop
	/etc/init.d/entware disable
	rm /etc/init.d/entware
	sed -i "export PATH=\/opt\/bin:\/opt\/sbin:\$PATH/d" /etc/profile
	source /etc/profile
	rm -rf /opt/*
	umount -lf /opt
	rm -r /opt
}

##### 软件包安装 #####
##参数: $1:安装列表
##说明：本函数将负责安装指定列表的软件到外置存储区，请保证区域指向正常且空间充足
install_soft(){
	[ `history | grep "opkg update"` = 0 ] || { echo "正在更新软件源" && opkg update > /dev/null 2>&1; }
	for ipk in $@ ; do
		echo -e "正在安装 $ipk\c"
		opkg install $ipk > /dev/null 2>&1
		status
		if [ $? != 0 ]; then
			echo -e "正在强制安装 $ipk\c" 
			opkg --force-depends --force-overwrite install $ipk > /dev/null 2>&1
			status
		fi
	done
}

##### 软件包卸载 #####
##参数: $1:卸载列表
##说明：本函数将负责强制卸载指定的软件包
remove_soft(){
	for ipk in $@ ; do
		echo -e "正在卸载 $ipk\c"
		opkg remove --force-depends $ipk > /dev/null 2>&1
		status
	done

}

##### 探针状态检测 #####
##参数: $1:探针存放目录
tz_check(){
	cd /tmp
	# 如果探针下载失败，采用备用地址下载修复
	if [ -f "/opt/wwwroot/tz/tz.php" ]; then
		echo "探针正常"
	else
		echo "检测到探针异常，采用备用地址下载"
		wget --no-check-certificate -O $1/tz.php https://raw.githubusercontent.com/WuSiYu/PHP-Probe/master/tz.php
	fi
}

##### 文件系统检查 #####
##参数: $1:设备挂载点
##说明：检查文件系统是否为ext4格式，不通过则转换为ext4格式
filesystem_check(){
	local dev_path="`mount | grep "$1" | awk '{print $1}'`"
	local filesystem="`mount | grep "$1" | awk '{print $5}'`"
	if [ "ext4" != $filesystem ]; then
		disk_format_ext $dev_path $1 4
	fi
}

##### 磁盘格式化及重挂载(ext) #####
##参数: $1:设备dev路径 $2:设备挂载点 $3:磁盘ext格式版本（eg:2、3、4）
##该功能依赖e2fsprogs软件包
disk_format_ext(){
	echo "开始调整分区为ext$3格式"、
	umount -l $1
	echo y | mkfs.ext$3 $1
	mount -t ext$3 $1 $2
}

##### 通用型二元浮点运算（适用于ash） #####
##参数: $1:被除数 $2:运算符号 $3:除数
float_calculate(){
	echo "$(awk 'BEGIN{print '$1$2$3'}')"
}

##### 浮点数转整形 #######
##参数：$1：待转换的浮点数
##说明：本转换只是单纯的去掉小数点后面的数字，不考虑四舍五入
float_to_int(){
	echo "$(echo $1 | cut -f 1 -d.)"
}

##### 进度条 #####
##参数: $1:当前任务完成率（浮点）
##说明：执行一次输出一次，外部需要套用循环来实现进度条的更新
##      对于浮点的处理非四舍五入，而是直接去掉小数点后的所有位数，因为在shell中所存的类型其实是字符型
progress_bar(){
	str=""
	cnt=0
	integer=`float_to_int $float`
	while [ $cnt -le $1 ]
		do
			str="$str#"
			let cnt=cnt+1
		done
	if  [ $1 -le 20 ]; then
		let color=41
		let bg=31
	elif [ $1 -le 45 ]; then
		let color=43
		let bg=33
	elif [ $1 -le 75 ]; then
		let color=44
		let bg=34
	else
	let color=42
	let bg=32
	fi
	printf "\033[${color};${bg}m%-s\033[0m %.2f%c\r" "$str" "$integer" "%"
}

##### 配置交换分区文件 #####
##参数: $1:交换分区挂载点 $2:交换空间大小(M)
config_swap_init(){
	let swapsize=$2*1024*1024
	filesize=0
	echo "配置交换分区（$2M），写入文件中..."
	dd if=/dev/zero of=$1 bs=1M count=$2 > /dev/null 2>&1 &
	sleep 1
	while [ $filesize -lt $swapsize ]
	do
		filesize=`ls -l $1 | awk '{print $5}'`
		float_cal=$(float_calculate `expr $filesize \* 100` / $swapsize)
		progress_bar $float_cal
	done
	echo -e "\n文件写入完成！"
	exit 0
	mkswap $1 > /dev/null 2>&1
	swapon $1
}

##### 删除交换分区文件 #####
##参数: $1:交换分区挂载点
config_swap_del(){
	swapoff $2
	rm -f $2
}

##### 获取外置挂载点 #####
##说明：该功能为新增功能，推荐使用此功能获取外置挂载点，get_usb_path的替代品
get_externel_mount_point(){
	mount_list=`lsblk -s | grep mnt | awk '{print $7}'`
	echo "$mount_list"
}

##### 获取USB存储点 #####
##说明：获取USB存储点，推荐使用 get_externel_mount_point 替代
get_usb_path(){
	# 获取USB外置存储挂载根目录，多次重复匹配，防止重复
	USB_PATH=`lsblk -s | grep mnt | awk '{print $7}'`
	if [ -z "$USB_PATH" ]; then
		echo "未探测到已挂载的USB分区"
		return 255
	fi
	# Shell只能返回整数值，表示成功或失败，不能返回字符串
}

##### 获取通用环境变量 #####
get_env(){
	# 获取用户名
	if [[ $USER ]]; then
		username=$USER
	elif [[ -n $(whoami 2>/dev/null) ]]; then
		username=$(whoami 2>/dev/null)
	else
		username=$(cat /etc/passwd | sed "s/:/ /g" | awk 'NR==1'  | awk '{print $1}')
	fi

	# 获取路由器IP
	localhost=$(ifconfig  | grep "inet addr" | awk '{ print $2}' | awk -F: '{print $2}' | awk 'NR==1')
	if [[ ! -n "$localhost" ]]; then
		localhost="你的路由器IP"
	fi
}

##### 获取entware安装路径 #####
##说明：解决entware开机脚本找不到路径的问题，该函数负责将找到的entware路径返回，有多个目录则返回最先找到的
get_entware_path(){
	mount_list=`get_externel_mount_point`
	for mount_point in $mount_list ; do
		if [ -d "$mount_point/opt" ]; then
			echo "$mount_point/opt"
			break
		fi
	done
}

###### 容量验证 ########
##参数：$1：目标位置
##说明：本函数判断对于GB级别，并不会很精确
check_available_size(){
	available_size=`lsblk -s | grep $1 | awk '{print $4}'`
	[ $available_size ] && echo "$available_size"
}

