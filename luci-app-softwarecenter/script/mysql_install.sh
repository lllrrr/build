#!/bin/sh
##数据库安装脚本
##version 1.5
##本脚本实现参考于github开源项目ONMP
##本脚本提供以下函数接口：
#	init_mysql
#	del_mysql

#
# Copyright (C) 2019 Jianpeng Xiang (1505020109@mail.hnust.edu.cn)
#
# This is free software, licensed under the GNU General Public License v3.
#



# 加载常用函数库
. /usr/bin/softwarecenter/lib_functions.sh
dblist="mariadb-server mariadb-server-extra mariadb-client mariadb-client-extra"

############## 重置、初始化MySQL #############
init_mysql(){
	get_env
	install_soft "$dblist"
	# MySQL设置
	_make_dir "/opt/etc/mysql"
	cat > "/opt/etc/mysql/my.cnf" <<-EOF
[client-server]
port               = 3306
socket             = /opt/var/run/mysqld.sock

[mysqld]
user               = theOne
socket             = /opt/var/run/mysqld.sock
pid-file           = /opt/var/run/mysqld.pid
basedir            = /opt
lc_messages_dir    = /opt/share/mariadb
lc_messages        = en_US
datadir            = /opt/var/mariadb/
tmpdir             = /opt/tmp/

skip-external-locking

bind-address       = 127.0.0.1

key_buffer_size    = 24M
max_allowed_packet = 24M
thread_stack       = 192K
thread_cache_size  = 8

[mysqldump]
quick
quote-names
max_allowed_packet = 24M

[mysql]
#no-auto-rehash

[isamchk]
key_buffer_size    = 24M

[mysqlhotcopy]
interactive-timeout
EOF

	echo $user $pass
	# [ ${user} ] && username=$user
	if [[ $user ]]; then
		username=$user
	fi
	sed -e "s/theOne/$username/g" -i /opt/etc/mysql/my.cnf
	chmod 644 /opt/etc/mysql/my.cnf
	_make_dir "/opt/var/mysql"

	# 数据库安装，同步方式，无需延时等待
	echo -e "\n正在初始化数据库，请稍等1分钟"
	mysql_install_db --user=$username --basedir=/opt --datadir=/opt/var/mariadb/ > /dev/null 2>&1

	# 初次启动MySQL，异步方式，加延时等待
	/opt/etc/init.d/S70mysqld start
	echo "正在启动MySQL"
	sleep 10

	# 设置数据库密码
	if [ ${pass} ]; then
		mysqladmin -u $username password $pass
		echo -e "使用自定义数据库用户：$a, 初始密码：$Password"
	else
		mysqladmin -u root password 123456
		echo -e "使用默认数据库用户：root, 初始密码：123456"
	fi
}

del_mysql(){
	# 停止MySQL
	/opt/etc/init.d/S70mysqld stop
	echo "正在停止MySQL"
	sleep 10

	# 卸载相关的软件包
	mariadb_remove="`opkg list-installed | grep mariadb | cut -d' ' -f1 | xargs echo`"
	# remove_soft $mariadb_remove
	remove_soft "`opkg list-installed | grep mariadb | cut -d' ' -f1 | xargs echo`"

	# 清理相关的文件与目录
	rm -rf /opt/etc/mysql
	rm -rf /opt/var/mariadb/
	rm -rf /opt/var/mysql
	# rm -rf /opt/etc/init.d/S70mysqld
}

