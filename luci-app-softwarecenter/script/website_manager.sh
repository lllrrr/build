#!/bin/sh
#网站管理脚本 version 1.5

. /usr/bin/softwarecenter/lib_functions.sh

# Web程序
# (1) phpMyAdmin（数据库管理工具）
url_phpMyAdmin="https://files.phpmyadmin.net/phpMyAdmin/5.0.4/phpMyAdmin-5.0.4-all-languages.zip"
# (2) WordPress（使用最广泛的CMS）
url_WordPress="https://cn.wordpress.org/latest-zh_CN.zip"
# (3) Owncloud（经典的私有云）
url_Owncloud="https://download.owncloud.org/community/owncloud-complete-20200731.zip"
# (4) Nextcloud（Owncloud团队的新作，美观强大的个人云盘）
url_Nextcloud="https://download.nextcloud.com/server/releases/nextcloud-20.0.0.zip"
# (5) h5ai（优秀的文件目录）
url_h5ai="https://release.larsjung.de/h5ai/h5ai-0.29.0.zip"
# (6) Lychee（一个很好看，易于使用的Web相册）
url_Lychee="https://github.com/electerious/Lychee/archive/master.zip"
# (7) Kodexplorer（可道云aka芒果云在线文档管理器）
url_Kodexplorer="http://static.kodcloud.com/update/download/kodbox.1.14.zip"
# (8) Typecho (流畅的轻量级开源博客程序)
url_Typecho="http://typecho.org/downloads/1.1-17.10.30-release.tar.gz"
# (9) Z-Blog (体积小，速度快的PHP博客程序)
url_Zblog="https://update.zblogcn.com/zip/Z-BlogPHP_1_6_5_2140_Valyria.zip"
# (10) DzzOffice (开源办公平台)
url_DzzOffice="https://codeload.github.com/zyx0814/dzzoffice/zip/master"

# 网站程序安装 参数： $1:安装目标 $2:端口号
#实践的时候发现Nginx可热部署网站
install_website(){
	# 通用环境变量获取
	get_env
	nport="$2"

	# 初始化全局变量
	unset filelink
	unset name
	unset dirname
	unset port
	unset hookdir
	unset istar

	case $1 in
		0) install_tz;;
		1) install_phpmyadmin;;
		2) install_wordpress;;
		3) install_owncloud;;
		4) install_nextcloud;;
		5) install_h5ai;;
		6) install_lychee;;
		7) install_kodexplorer;;
		8) install_typecho;;
		9) install_zblog;;
		10) install_dzzoffice;;
		*)break;;
	esac

}

# 网站名称映射 参数；$1:网站选项
website_name_mapping(){
	case $1 in
		0) echo "tz";;
		1) echo "phpMyAdmin";;
		2) echo "WordPress";;
		3) echo "Owncloud";;
		4) echo "Nextcloud";;
		5) echo "h5ai";;
		6) echo "Lychee";;
		7) echo "Kodexplorer";;
		8) echo "Typecho";;
		9) echo "Zblog";;
		10) echo "DzzOffice";;
		*)break;;
	esac
}

# WEB程序安装器 已修正适配(简易处理)
web_installer(){
	echo -e "\n============================="
	echo -e "***********  WEB程序安装器  ***********"
	echo -e "=============================\n"

	# 获取用户自定义设置
	webdir=$name
	suffix="zip"
	[ $nport ] && port_settings $nport
	[ $istar ] && suffix="tar"

	# 检查是否原有文件存在
	[ -d "/opt/wwwroot/$webdir" ] && rm -rf /opt/wwwroot/$webdir && \
	rm -rf /opt/etc/nginx/vhost/$webdir.conf && echo "已删除以前的$webdir文件"
	[ -e /opt/tmp/$name.$suffix ] && rm -rf /opt/tmp/$name.$suffix

	# 下载程序并解压
	echo "开始安装$webdir"
	echo "正在下载安装包$name.$suffix，请耐心等待..."
	if wget --no-check-certificate -O /opt/tmp/$name.$suffix $filelink; then
		make_dir /opt/wwwroot /opt/wwwroot/$hookdir
		mv /opt/tmp/$name.* /opt/wwwroot/
		echo "正在解压$name.$suffix..."
		if [ $istar ]; then
			tar zxf /opt/wwwroot/$name.$suffix -C /opt/wwwroot/$hookdir > /dev/null 2>&1
		else
			unzip /opt/wwwroot/$name.$suffix -d /opt/wwwroot/$hookdir > /dev/null 2>&1
		fi
		mv /opt/wwwroot/$dirname /opt/wwwroot/$webdir && echo "解压完成..." && rm /opt/wwwroot/$name.$suffix
		# 检测是否解压成功
		[ "`ls /opt/wwwroot/$webdir 2> /dev/null | wc -l`" -eq 0 ] && {
			echo "$webdir安装失败，回滚操作"
			delete_website /opt/etc/nginx/vhost/$webdir.conf
			exit 1
		}
	else
		echo "$name下载失败，检查网络。"
		rm /opt/tmp/$name.$suffix
		exit 1
	fi

}

# 安装脚本的基本结构
# install_webapp(){
	# 默认配置
	# filelink=""			# 下载链接
	# name=""				# 程序名
	# dirname=""			# 解压后的目录名
	# port=				# 端口
	# hookdir=$dirname	# 某些程序解压后不是单个目录，用这个hook解决
	# istar=true			# 是否为tar压缩包, 不是则删除此行

	# 运行安装程序
	# web_installer
	# echo "正在配置$name..."
	# chmod -R 777 /opt/wwwroot/$webdir		# 目录权限看情况使用

	# 添加到虚拟主机
	# add_vhost $port $webdir
	# sed -e "s/.*\#php-fpm.*/    include \/opt\/etc\/nginx\/conf\/php-fpm.conf\;/g" -i /opt/etc/nginx/vhost/$webdir.conf		# 添加公共php-fpm支持
	# onmp restart >/dev/null 2>&1
	# echo "$name安装完成"
	# echo "浏览器地址栏输入：$localhost:$port 即可访问"
# }

onmp_restart(){
	# 安装后重启onmp
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
        echo "onmp 启动失败"
    else
        echo "onmp 已启动"
    fi
}

port_settings(){
if [ -n "`netstat -lntp | grep $1`" ];then
	echo "$1端口已经在用，查寻可用的端口"
	for f in `seq 80 99`;do
		if [ -z "`netstat -lntp | grep $f`" ]; then
			port=$f
			break
		fi
	done
else
	port=$1
fi
}

# 网站程序卸载（by自动化接口安装）参数；$1:删除的目标
delete_website_byauto(){
	local name
	name=`website_name_mapping $1`
	delete_website /opt/etc/nginx/vhost/$name.conf /opt/wwwroot/$name
}

# 添加到虚拟主机 参数：$1：端口 $2：虚拟主机配置名
add_vhost(){
# 写入文件
cat > "/opt/etc/nginx/vhost/$2.conf" <<-\EOF
server {
	listen 81;
	server_name localhost;
	root /opt/wwwroot/www/;
	index index.html index.htm index.php;
	#php-fpm
	#otherconf
}
EOF

sed -e "s/.*listen.*/    listen $1\;/g" -i /opt/etc/nginx/vhost/$2.conf
sed -e "s/.*\/opt\/wwwroot\/www\/.*/    root \/opt\/wwwroot\/$2\/\;/g" -i /opt/etc/nginx/vhost/$2.conf
}

# 开启 Redis 参数: $1: 安装目录
redis(){
sed -e "/);/d" -i $1/config/config.php
cat >> "$1/config/config.php" <<-\EOF
'memcache.locking' => '\OC\Memcache\Redis',
'memcache.local' => '\OC\Memcache\Redis',
'redis' => array(
    'host' => '/opt/var/run/redis.sock',
    'port' => 0,
    ),
);
EOF
echo "$webdir已开启Redis"
}

# 网站删除 参数：$1:conf文件位置 $2:website_dir
#说明：本函数仅删除配置文件和目录，并不负责重载Nginx服务器配置，请调用层负责处理
delete_website(){
	rm -rf $1
	rm -rf $2
	prefix="`echo $2 | sed 's/.$//'`"
	rm -rf $prefix.*
	echo "网站$2已删除"
}

# 网站配置文件基本属性列表 参数：$1:配置文件位置
#说明：本函是将负责解析nginx的配置文件，输出网站文件目录和访问地址,仅接受一个参数
vhost_config_list(){
	if [ "$#" -eq "1" ]; then
		path=$(cat $1 | awk 'NR==4' | awk '{print $2}' | sed 's/;//')
		port=$(cat $1 | awk 'NR==2' | awk '{print $2}' | sed 's/;//')
		echo "$path $localhost:$port"
	fi
}

# 网站一览 说明：显示已经配置注册的网站
vhost_list(){
	get_env
	echo "网站列表："
	for conf in /opt/etc/nginx/vhost/*; do
		vhost_config_list $conf
	done
}

# 自定义部署通用函数 参数：$1:文件目录 $2:端口号
install_custom(){
	webdir=$1
	port=$2
	# 运行安装程序
	echo "正在配置$webdir..."

	# 目录检查
	if [ ! -d /opt/wwwroot/$webdir ]; then
		echo "目录不存在，部署中断"
		exit 1
	fi
	chmod -R 777 /opt/wwwroot/$webdir

	# 添加到虚拟主机
	add_vhost $port $webdir
	sed -e "s/.*\#php-fpm.*/    include \/opt\/etc\/nginx\/conf\/php-fpm.conf\;/g" -i /opt/etc/nginx/vhost/$webdir.conf
	echo "$webdir安装完成"
}

install_tz(){
	port_settings 81
	[ $nport ] && port_settings $nport

	make_dir "/opt/wwwroot/tz"
	echo "开始下载雅黑PHP探针"
	wget --no-check-certificate -O /opt/wwwroot/tz/index.php https://raw.githubusercontent.com/WuSiYu/PHP-Probe/master/tz.php > /dev/null 2>&1
	if [ $? != 0 ]; then
		echo "下载异常"
		rm -r /opt/wwwroot/tz
		exit 1
	fi
	echo "正在配置雅黑PHP探针"
	add_vhost $port tz
	sed -e "s/.*\#php-fpm.*/    include \/opt\/etc\/nginx\/conf\/php-fpm.conf\;/g" -i /opt/etc/nginx/vhost/tz.conf
	chmod -R 777 /opt/wwwroot/tz
}

# 安装phpMyAdmin
install_phpmyadmin(){
	# 默认配置
	filelink=$url_phpMyAdmin
	name="phpMyAdmin"
	dirname="phpMyAdmin-*-languages"
	port_settings 82

	# 运行安装程序
	web_installer
	echo "正在配置$name..."
	cp /opt/wwwroot/$webdir/config.sample.inc.php /opt/wwwroot/$webdir/config.inc.php
	chmod 644 /opt/wwwroot/$webdir/config.inc.php
	# 取消-p参数，必须要求webdir创建才可创建文件夹，为部署检测做准备
	make_dir /opt/wwwroot/$webdir/tmp
	chmod 777 /opt/wwwroot/$webdir/tmp
	sed -e "s/.*blowfish_secret.*/\$cfg['blowfish_secret'] = 'softwarecentersoftwarecentersoftwarecenter';/g" -i /opt/wwwroot/$webdir/config.inc.php

	# 添加到虚拟主机
	add_vhost $port $webdir
	sed -e "s/.*\#php-fpm.*/    include \/opt\/etc\/nginx\/conf\/php-fpm.conf\;/g" -i /opt/etc/nginx/vhost/$webdir.conf

	echo "$name安装完成"
	echo "浏览器地址栏输入：$localhost:$port 即可访问"
	echo "phpMyaAdmin的用户、密码就是数据库用户、密码"
}

# 安装WordPress
install_wordpress(){
	# 默认配置
	filelink=$url_WordPress
	name="WordPress"
	dirname="wordpress"
	port_settings 83

	# 运行安装程序
	web_installer
	echo "正在配置$name..."
	chmod -R 777 /opt/wwwroot/$webdir

	# 添加到虚拟主机
	add_vhost $port $webdir
	# WordPress的配置文件中有php-fpm了, 不需要外部引入
	sed -e "s/.*\#otherconf.*/    include \/opt\/etc\/nginx\/conf\/wordpress.conf\;/g" -i /opt/etc/nginx/vhost/$webdir.conf

	echo "$name安装完成"
	echo "浏览器地址栏输入：$localhost:$port 即可访问"
	echo "可以用phpMyaAdmin建立数据库，然后在这个站点上一步步配置网站信息"
}

# 安装h5ai
install_h5ai(){
	# 默认配置
	filelink=$url_h5ai
	name="h5ai"
	dirname="_h5ai"
	port_settings 84
	hookdir=$dirname

	# 运行安装程序
	web_installer
	echo "正在配置$name..."
	cp /opt/wwwroot/$webdir/_h5ai/README.md /opt/wwwroot/$webdir/
	chmod -R 777 /opt/wwwroot/$webdir/

	# 添加到虚拟主机
	add_vhost $port $webdir
	sed -e "s/.*\#php-fpm.*/    include \/opt\/etc\/nginx\/conf\/php-fpm.conf\;/g" -i /opt/etc/nginx/vhost/$webdir.conf
	sed -e "s/.*\index index.html.*/    index  index.html  index.php  \/_h5ai\/public\/index.php;/g" -i /opt/etc/nginx/vhost/$webdir.conf

	echo "$name安装完成"
	echo "浏览器地址栏输入：$localhost:$port 即可访问"
	echo "配置文件在/opt/wwwroot/$webdir/_h5ai/private/conf/options.json"
	echo "你可以通过修改它来获取更多功能"
	}

# 安装Lychee
install_lychee(){
	# 默认配置
	filelink=$url_Lychee
	name="Lychee"
	dirname="Lychee-master"
	port_settings 85

	# 运行安装程序
	web_installer
	echo "正在配置$name..."
	chmod -R 777 /opt/wwwroot/$webdir/uploads/ /opt/wwwroot/$webdir/data/

	# 添加到虚拟主机
	add_vhost $port $webdir
	sed -e "s/.*\#php-fpm.*/    include \/opt\/etc\/nginx\/conf\/php-fpm.conf\;/g" -i /opt/etc/nginx/vhost/$webdir.conf

	echo "$name安装完成"
	echo "浏览器地址栏输入：$localhost:$port 即可访问"
	echo "首次打开会要配置数据库信息"
	echo "地址：127.0.0.1 用户、密码你自己设置的或者默认是root 123456"
	echo "下面的可以不配置，然后下一步创建个用户就可以用了"
}

# 安装kodexplorer芒果云
install_kodexplorer(){
	# 默认配置
	filelink=$url_Kodexplorer
	name="Kodexplorer"
	dirname="kodexplorer"
	port_settings 86
	hookdir=$dirname

	# 运行安装程序
	web_installer
	echo "正在配置$name..."
	chmod -R 777 /opt/wwwroot/$webdir

	# 添加到虚拟主机
	add_vhost $port $webdir
	sed -e "s/.*\#php-fpm.*/    include \/opt\/etc\/nginx\/conf\/php-fpm.conf\;/g" -i /opt/etc/nginx/vhost/$webdir.conf
	sed -i 's/config.php/configg.php/g' /opt/wwwroot/Kodexplorer/index.php
	cp /opt/wwwroot/Kodexplorer/config/config.php /opt/wwwroot/Kodexplorer/config/configg.php

	echo "$name安装完成"
	echo "浏览器地址栏输入：$localhost:$port 即可访问"
}

# 安装Typecho
install_typecho(){
	# 默认配置
	filelink=$url_Typecho
	name="Typecho"
	dirname="build"
	port_settings 87
	istar=true

	# 运行安装程序
	web_installer
	echo "正在配置$name..."
	chmod -R 777 /opt/wwwroot/$webdir

	# 添加到虚拟主机
	add_vhost $port $webdir
	sed -e "s/.*\#php-fpm.*/    include \/opt\/etc\/nginx\/conf\/php-fpm.conf\;/g" -i /opt/etc/nginx/vhost/$webdir.conf
	sed -e "s/.*\#otherconf.*/    include \/opt\/etc\/nginx\/conf\/typecho.conf\;/g" -i /opt/etc/nginx/vhost/$webdir.conf

	echo "$name安装完成"
	echo "浏览器地址栏输入：$localhost:$port 即可访问"
	echo "可以用phpMyaAdmin建立数据库，然后在这个站点上一步步配置网站信息"
}

# 安装Z-Blog
install_zblog(){
	# 默认配置
	filelink=$url_Zblog
	name="Zblog"
	dirname="Z-BlogPHP_1_5_1_1740_Zero"
	hookdir=$dirname
	port_settings 88

	# 运行安装程序
	web_installer
	echo "正在配置$name..."
	chmod -R 777 /opt/wwwroot/$webdir

	# 添加到虚拟主机
	add_vhost $port $webdir
	sed -e "s/.*\#php-fpm.*/    include \/opt\/etc\/nginx\/conf\/php-fpm.conf\;/g" -i /opt/etc/nginx/vhost/$webdir.conf

	echo "$name安装完成"
	echo "浏览器地址栏输入：$localhost:$port 即可访问"
}

# 安装DzzOffice
install_dzzoffice(){
	# 默认配置
	filelink=$url_DzzOffice
	name="DzzOffice"
	dirname="dzzoffice-master"
	port_settings 89

	# 运行安装程序
	web_installer
	echo "正在配置$name..."
	chmod -R 777 /opt/wwwroot/$webdir

	# 添加到虚拟主机
	add_vhost $port $webdir
	sed -e "s/.*\#php-fpm.*/    include \/opt\/etc\/nginx\/conf\/php-fpm.conf\;/g" -i /opt/etc/nginx/vhost/$webdir.conf		# 添加php-fpm支持

	echo "$name安装完成"
	echo "浏览器地址栏输入：$localhost:$port 即可访问"
	echo "DzzOffice应用市场中，某些应用无法自动安装的，请自行参看官网给的手动安装教程"
}

# 安装Owncloud
install_owncloud(){
	# 默认配置
	filelink=$url_Owncloud
	name="Owncloud"
	dirname="owncloud"
	port_settings 90

	# 运行安装程序
	web_installer
	echo "正在配置$name..."
	chmod -R 777 /opt/wwwroot/$webdir

	# 添加到虚拟主机
	add_vhost $port $webdir
	# Owncloud的配置文件中有php-fpm了, 不需要外部引入
	sed -e "s/.*\#otherconf.*/    include \/opt\/etc\/nginx\/conf\/owncloud.conf\;/g" -i /opt/etc/nginx/vhost/$webdir.conf

	echo "$name安装完成"
	echo "浏览器地址栏输入：$localhost:$port 即可访问"
	echo "首次打开会要配置用户和数据库信息"
	echo "地址默认 localhost 用户、密码你自己设置的或者默认是root 123456"
	echo "安装好之后可以点击左上角三条杠进入market安装丰富的插件，比如在线预览图片、视频等"
	echo "需要先在web界面配置完成后，才能使用开启Redis"
}

# 安装Nextcloud
install_nextcloud(){
	# 默认配置
	filelink=$url_Nextcloud
	name="Nextcloud"
	dirname="nextcloud"
	port_settings 91

	# 运行安装程序
	web_installer
	echo "正在配置$name..."
	chmod -R 777 /opt/wwwroot/$webdir

	# 添加到虚拟主机
	add_vhost $port $webdir
	# nextcloud的配置文件中有php-fpm了, 不需要外部引入
	sed -e "s/.*\#otherconf.*/    include \/opt\/etc\/nginx\/conf\/nextcloud.conf\;/g" -i /opt/etc/nginx/vhost/$webdir.conf

	echo "$name安装完成"
	echo "浏览器地址栏输入：$localhost:$port 即可访问"
	echo "首次打开会要配置用户和数据库信息"
	echo "地址默认 localhost 用户、密码你自己设置的或者默认是root 123456"
	echo "需要先在 web 界面配置完成后，才能使用开启Redis"
}
