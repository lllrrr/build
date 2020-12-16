#!/bin/sh

pkglist_base="wget unzip e2fsprogs ca-certificates"

status(){
	local p=$?
	# echo -en "\\033[40G[ "
	if [ "$p" = "0" ]; then
		# echo -e "\\033[1;33m成功\\033[0;39m ]"
		echo "   成功"
		return 0
	else
		# echo -e "\\033[1;31m失败\\033[0;39m ]"
		echo "   失败"
		return 1
	fi
}

_make_dir(){
	for p in "$@"; do
		[ -d "$p" ] || { mkdir -p $p && echo "成功创建$p";}
	done
	return 0
}

# entware环境设定 参数：$1:设备底层架构 $2:安装位置
#说明：此函数用于写入新配置
entware_set(){
	entware_unset
	[ "$1" ] && USB_PATH="$1"
	[ "$2" ] || { echo "未选择CPU架构！" && exit 1; }
	system_check $USB_PATH
	echo -e "\n开始安装entware环境\n"
	echo "安装基本软件" && install_soft "$pkglist_base"
	Kernel_V=$(expr substr `uname -r` 1 3)

	_make_dir "$USB_PATH/opt" "/opt"
	mount -o bind $USB_PATH/opt /opt

	if [ "$2" == "mipsel" ]; then
		wget -O - http://bin.entware.net/mipselsf-k3.4/installer/generic.sh | /bin/sh
	elif [ "$2" == "mips" ]; then
	if [ $Kernel_V == "2.6" ]; then
		wget -O - http://pkg.entware.net/binaries/mipsel/installer/installer.sh | /bin/sh
	else
		wget -O - http://bin.entware.net/mipssf-k3.4/installer/generic.sh | /bin/sh
	fi
	elif [ "$2" == "armv7" ]; then
		wget -O - http://bin.entware.net/armv7sf-k3.2/installer/generic.sh | /bin/sh
	elif [ "$2" == "x86_64" ]; then
		wget -O - http://bin.entware.net/x64-k3.2/installer/generic.sh | /bin/sh
	elif [ "$2" == "x86" ]; then
		wget -O - http://bin.entware.net/x86-k2.6/installer/generic.sh | /bin/sh
	elif [ "$2" == "aarch64" ]; then
		wget -O - http://bin.entware.net/aarch64-k3.10/installer/generic.sh | /bin/sh
	elif [ "$2" == "armv7l" ]; then
		wget -O - http://bin.entware.net/armv7sf-k${Kernel_V}/installer/generic.sh | /bin/sh
	else
		echo "没有找到你选择的CPU架构！"
		exit 1
	fi

	cat > "/etc/init.d/entware" <<-\ENTWARE
#!/bin/sh /etc/rc.common
START=51

# 获取entware安装路径 该函数负责将找到的entware路径返回，有多个目录则返回最先找到的
get_entware_path(){
	for mount_point in `lsblk -s | grep mnt | awk '{print $7}'`; do
		if [ -d "$mount_point/opt/etc/nginx" ]; then
			echo "$mount_point/opt"
			break
		fi
	done
}

start(){
	mkdir -p /opt
	ENTWARE_PATH=`get_entware_path`
	mount -o bind $ENTWARE_PATH /opt
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

	chmod a+x /etc/init.d/entware
	/etc/init.d/entware enable
	echo "export PATH=/opt/bin:/opt/sbin:/sbin:/bin:/usr/sbin:/usr/bin:$PATH" >> /etc/profile

	i18n_URL=http://pkg.entware.net/sources/i18n_glib223.tar.gz
	if check_url $i18n_URL; then
		wget -qcNO- -t 5 $i18n_URL | tar xvz -C /opt/usr/share/ > /dev/null
		echo "Adding zh_CN.UTF-8"
		/opt/bin/localedef.new -c -f UTF-8 -i zh_CN zh_CN.UTF-8
		sed -i 's/en_US.UTF-8/zh_CN.UTF-8/g' /opt/etc/profile
	fi
}

# entware环境解除 说明：此函数用于删除OPKG配置设定
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

# 软件包安装 参数: $@:安装列表
#说明：本函数将负责安装指定列表的软件到外置存储区，请保证区域指向正常且空间充足
install_soft(){
	echo "正在更新软件源" && opkg update > /dev/null 2>&1
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

# 软件包卸载 参数: $1:卸载列表
#说明：本函数将负责强制卸载指定的软件包
remove_soft(){
	for ipk in $@ ; do
		echo -e "正在卸载 $ipk\c"
		opkg remove --force-depends $ipk > /dev/null 2>&1
		status
	done

}

# 磁盘分区挂载
function system_check(){
	[ $1 ] && Partition_disk=${1} || { Partition_disk=`uci get softwarecenter.main.Partition_disk` && Partition_disk=${Partition_disk}1; }

	if [ -n "`lsblk -p | grep ${Partition_disk}`" ]; then
		filesystem="`blkid -s TYPE | grep ${Partition_disk/mnt/dev} | cut -d'"' -f2`"
		if [ "ext4" != $filesystem ]; then
			echo "`date "+%Y-%m-%d %H:%M:%S"` 磁盘$Partition_disk原是$filesystem重新格式化ext4。"
			umount -l ${Partition_disk}
			echo y | mkfs.ext4 ${Partition_disk/mnt/dev}
			mount ${Partition_disk/mnt/dev} ${Partition_disk}
		fi
	else
		[ $1 ] || Partition_disk=`uci get softwarecenter.main.Partition_disk`
		echo "`date "+%Y-%m-%d %H:%M:%S"` 磁盘$Partition_disk没有分区，进行分区并格式化。"
		parted -s ${Partition_disk} mklabel msdos
		parted -s ${Partition_disk} mklabel gpt \
		mkpart primary ext4 512s 100%
		sync; sleep 2
		echo y | mkfs.ext4 ${Partition_disk}1
		_make_dir ${Partition_disk/dev/mnt}1
		mount ${Partition_disk}1 ${Partition_disk/dev/mnt}1
	fi

}

# 配置交换分区文件 参数: $1:交换空间大小(M) $2:交换分区挂载点
config_swap_init(){
status=$(cat /proc/swaps | awk 'NR==2')
    if [[ -n "$status" ]]; then
        echo "Swap 已经启用"
    else
        if [ ! -e "$1/opt/.swap" ]; then
            echo "正在生成swap文件，请耐心等待..."
            dd if=/dev/zero of=$2/opt/.swap bs=1M count=$1
            # 设置交换文件
            mkswap $2/opt/.swap
            chmod 0600 $2/opt/.swap
        fi
        # 启用交换分区
        swapon $2/opt/.swap
        echo "现在你可以使用 free 命令查看swap是否启用"
    fi
}

# 删除交换分区文件 参数: $disk_mount:交换分区挂载点
config_swap_del(){
	[ -e /opt/.swap ] && {
	swapoff /opt/.swap
	rm -f /opt/.swap
	echo -e "\n$1/opt/.swap文件已删除！\n"
	}
}

# 获取通用环境变量
get_env(){
    # 获取用户名
    if [ $USER ]; then
        username=$USER
    else
        username=$(cat /etc/passwd | sed "s/:/ /g" | awk 'NR==1'  | awk '{printf $1}')
    fi

    # 获取路由器IP
    localhost=$(ifconfig  | grep "inet addr" | awk '{ print $2}' | awk -F: '{print $2}' | awk 'NR==1')
    if [[ ! -n "$localhost" ]]; then
        localhost="你的路由器IP"
    fi
}

# 容量验证 参数：$1：目标位置
#说明：本函数判断对于GB级别，并不会很精确
check_available_size(){
	available_size=`lsblk -s | grep $1 | awk '{print $4}'`
	[ $available_size ] && echo "$available_size"
}

ipk_install(){
	source /etc/profile
	opkg update
for i in $@; do
	if [ "`opkg list | awk '{print $1}' | grep -w $i`" ]; then
		echo "请耐心等待$i安装中。"
		opkg install $i
	else
		echo -e $i 不在 Entware 软件源，跳过安装！
	fi
done
}

rtorrent(){
ipk_install rtorrent-easy-install
web_port=1099
www_cfg=/opt/etc/lighttpd/conf.d/99-rtorrent-fastcgi-scgi-auth.conf
if [ -z "`grep 'server.port' $www_cfg`" ]; then
echo "server.port = $web_port" >> $www_cfg
else
sed -i "s/server.port = .*/server.port = $web_port/g" $www_cfg
fi
/opt/etc/init.d/S80lighttpd start > /dev/null 2>&1 && [ $? = 0 ] && echo lighttpd已经运行 || echo lighttpd没有运行
/opt/etc/init.d/S85rtorrent start > /dev/null 2>&1 && [ $? = 0 ] && echo rtorrent已经运行 || echo rtorrent没有运行
}

deluge(){
ipk_install deluge deluge-ui-web
/opt/etc/init.d/S80deluged start > /dev/null 2>&1 && [ $? = 0 ] && echo deluged已经运行 || echo deluged没有运行
/opt/etc/init.d/S81deluge-web start > /dev/null 2>&1 && [ $? = 0 ] && echo deluge-web已经运行 || echo deluge-web没有运行
}

transmission(){
ipk_install transmission-daemon transmission-web-control
/opt/etc/init.d/S88transmission start > /dev/null 2>&1 && [ $? = 0 ] && echo transmission已经运行 || echo transmission没有运行
}

qbittorrent(){
if ipk_install qbittorrent; then
QBT_INI_FILE="/opt/etc/qBittorrent_entware/config/qBittorrent.conf"
cat > "$QBT_INI_FILE" << EOF
[AutoRun]
enabled=false
program=
[Preferences]
WebUI\Address=*
WebUI\AlternativeUIEnabled=false
WebUI\AuthSubnetWhitelist=@Invalid()
WebUI\AuthSubnetWhitelistEnabled=false
WebUI\CSRFProtection=false
WebUI\CustomHTTPHeadersEnabled=false
WebUI\LocalHostAuth=true
WebUI\MaxAuthenticationFailCount=5
WebUI\Port=9080
WebUI\SecureCookie=true
WebUI\ServerDomains=*
WebUI\SessionTimeout=3600
WebUI\UseUPnP=true
WebUI\Username=admin
General\Locale=zh
Downloads\UseIncompleteExtension=true
EOF
/opt/etc/init.d/S89qbittorrent start > /dev/null 2>&1 && [ $? = 0 ] && echo qbittorrent已经运行 || echo qbittorrent没有运行
fi
}

Paria2(){
if ipk_install aria2; then
sed -i '/secret/d' /opt/etc/aria2.conf
/opt/etc/init.d/S81aria2 start > /dev/null 2>&1 && [ $? = 0 ] && echo aria2 已经运行 || echo aria2 没有运行
	if [ ! -d /opt/share/www/ariang ]; then
	wget -cN -t 5 --no-check-certificate https://github.com/mayswind/AriaNg-DailyBuild/archive/1.1.7.tar.gz -P /opt/share/www
		if [ -f /opt/share/www/1.1.7.tar.gz ]; then
			tar -xzf /opt/share/www/1.1.7.tar.gz -C /opt/share/www
			mv /opt/share/www/AriaNg-DailyBuild-1.1.7 /opt/share/www/ariang
			rm /opt/share/www/1.1.7.tar.gz
		fi
	fi
fi
}

amule(){
if ipk_install amule; then
	# /opt/etc/init.d/S57amuled start > /dev/null 2>&1
	# /opt/etc/init.d/S57amuled stop > /dev/null 2>&1
	# cd /opt/share/amule/webserver
	# wget https://codeload.github.com/MatteoRagni/AmuleWebUI-Reloaded/zip/master
	# unzip master && mv AmuleWebUI-Reloaded-master AmuleWebUI-Reloaded && rm -rf master
	# cd /opt/share/amule/webserver/AmuleWebUI-Reloaded
	# sed -i 's/Template=.*/Template=AmuleWebUI-Reloaded/g' /opt/var/amule/amule.conf
	# sed -i 's/UPnPEnabled=.*/UPnPEnabled=1/g' /opt/var/amule/amule.conf
	/opt/etc/init.d/S57amuled start > /dev/null 2>&1 && [ $? = 0 ] && echo amule 已经运行 || echo amule 没有运行
fi
}

onmp_restart(){
	/opt/etc/init.d/S70mysqld stop > /dev/null 2>&1
	/opt/etc/init.d/S79php7-fpm stop > /dev/null 2>&1
	/opt/etc/init.d/S80nginx stop > /dev/null 2>&1
	killall -9 nginx mysqld php-fpm > /dev/null 2>&1
	sleep 3
	/opt/etc/init.d/S70mysqld start > /dev/null 2>&1
	/opt/etc/init.d/S79php7-fpm start > /dev/null 2>&1
	/opt/etc/init.d/S80nginx start > /dev/null 2>&1
	sleep 3
	num=0
	for PROC in 'nginx' 'php-fpm' 'mysqld'; do
		if [ -n "`pidof $PROC`" ]; then
			echo $PROC "启动成功";
		else
			echo $PROC "启动失败";
			num=`expr $num + 1`
		fi
	done
	if [[ $num -gt 0 ]]; then
		echo "onmp启动失败"
		logger -t "【ONMP】" "启动失败"
	else
		echo "onmp已启动"
		logger -t "【ONMP】" "已启动"
		vhost_list
	fi
}

if [ $1 ]; then
	[ $1 = "amule" ] && amule | tee -a /tmp/log/softwarecenter.log
	[ $1 = "aria2" ] && Paria2 | tee -a /tmp/log/softwarecenter.log
	[ $1 = "deluge" ] && deluge | tee -a /tmp/log/softwarecenter.log
	[ $1 = "rtorrent" ] && rtorrent | tee -a /tmp/log/softwarecenter.log
	[ $1 = "qbittorrent" ] && qbittorrent | tee -a /tmp/log/softwarecenter.log
	[ $1 = "transmission" ] && transmission | tee -a /tmp/log/softwarecenter.log
	[ $1 = "system_check" ] && system_check | tee -a /tmp/log/softwarecenter.log
	[ $1 = "onmp_restart" ] && onmp_restart | tee -a /tmp/log/softwarecenter.log
	[ $1 = "install_soft" ] && install_soft $2 $3 | tee -a /tmp/log/softwarecenter.log
	[ $1 = "ipk_install" ] && ipk_install $2 $3 $4 $5 | tee -a /tmp/log/softwarecenter.log
fi
