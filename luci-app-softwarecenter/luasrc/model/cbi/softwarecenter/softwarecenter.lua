--[[
Copyright (C) 2019 Jianpeng Xiang (1505020109@mail.hnust.edu.cn)

This is free software, licensed under the GNU General Public License v3.
]]--

local fs = require "nixio.fs"
local sys  = require "luci.sys"
local http = require "luci.http"
local disp = require "luci.dispatcher"
local util = require "luci.util"
local uci = require("luci.model.uci").cursor()
local m

--得到Map对象，并初始化。参一：指定cbi文件，参二：设置标题，参三：设置标题下的注释
m=Map("softwarecenter",translate("Entware软件中心"),translate("软件中心负责软件和应用的自动化统一配置部署，提供一个简单友好的交互页面，旨在使应用的配置流程更轻松、更简单！<br>用于NAS，路由器和其他嵌入式设备的软件仓库。提供超过2000多个不同平台的软件包。<br>原项目地址：https://github.com/jsp1256/openwrt-package<br>"))
--各个软件的状态
m:section(SimpleSection).template="softwarecenter/software_status"

s=m:section(TypedSection,"softwarecenter",translate("软件中心设置"))
s.addremove=false
s.anonymous=true

s:tab("entware",translate("Entware设置"))
nginx_tab=s:tab("nginx",translate("Nginx服务器设置"))
mysql_tab=s:tab("mysql",translate("MySQL服务器设置"))

deploy_entware=s:taboption("entware",Flag,"deploy_entware",translate("启用"),translate("开始部署Entware环境"))

local model = luci.sys.exec("uname -m 2>/dev/null")
cpu_model = s:taboption("entware",Value,"cpu_model",translate("CPU架构"))
cpu_model.description = translate("当前检测到CPU架构：")..[[<font color="green">]]..[[<strong>]]..model..[[</strong>]]..[[</font>]]..' '
cpu_model:value(luci.sys.exec("uname -m 2>/dev/null"))
cpu_model:depends("deploy_entware",1)

local disk_size=luci.sys.exec("/usr/bin/softwarecenter/check_available_size.sh 2")
disk_mount=s:taboption("entware",ListValue,"disk_mount",translate("安装路径"),"%s %s"%{translatef("当前可用磁盘：<br><b style=\"color:green\">%s",disk_size).."</b><br>",translate("选中的磁盘可能被重新格式化为EXT4文件系统<br><b style=\"color:red\">警告：请确保选中的磁盘上没有重要数据</b><br>")})
for _, list_disk_mount in luci.util.vspairs(luci.util.split(luci.sys.exec("lsblk -s | grep mnt | awk '{print $7}'"))) do
	if(string.len(list_disk_mount) > 0)
	then
		disk_mount:value(list_disk_mount)
	end
end
disk_mount:depends("deploy_entware",1)
entware_enable=s:taboption("entware",Flag,"entware_enable",translate("安装ONMP"),translate("ONMP是使用opkg包快速搭建Nginx/MySQL/PHP环境，<br>此安装过程可能需要大量时间，可以在日志中查看到安装的过程"))
entware_enable:depends("deploy_entware",1)
deploy_nginx=s:taboption("entware",Flag,"deploy_nginx",translate("部署Nginx"),translate("自动部署Nginx服务器和其所需的PHP7运行环境"))
deploy_nginx:depends("entware_enable",1)
deploy_mysql=s:taboption("entware",Flag,"deploy_mysql",translate("部署MySQL"),translate("自动部署MySQL数据库服务器(依赖Entware软件仓库)"))
deploy_mysql:depends("entware_enable",1)

nginx_enable=s:taboption("nginx",Flag,"nginx_enabled",translate("Enabled"))
nginx_enable:depends("deploy_nginx",1)

mysql_enable=s:taboption("mysql",Flag,"mysql_enabled",translate("Enabled"),translate("第一次运行时，默认的登录用户是'root'，密码是'123456'"))
mysql_enable:depends("deploy_mysql",1)

website_section=m:section(TypedSection,"website",translate("网站管理"),translate("这里先添加名称确认后再选择要安装的应用软件"))
website_section.addremove=true
website_enabled=website_section:option(Flag,"website_enabled",translate("Enabled"),translate("请确保Nginx服务器正常安装并且已运行！<br>某些还网站需要MySQL数据库服务器的支持"))
autodeploy_enable=website_section:option(Flag,"autodeploy_enable",translate("启用自动部署"))
autodeploy_enable:depends("customdeploy_enabled",0)
website_select=website_section:option(ListValue,"website_select",translate("website"),translate("请选择你需要部署的网站"))
website_select:value("0","tz（雅黑PHP探针）")
website_select:value("1","phpMyAdmin（数据库管理工具）")
website_select:value("2","WordPress（使用最广泛的CMS）")
website_select:value("3","Owncloud（经典的私有云）")
website_select:value("4","Nextcloud（Owncloud团队的新作，美观强大的个人云盘）")
website_select:value("5","h5ai（优秀的文件目录）")
website_select:value("6","Lychee（一个很好看，易于使用的Web相册）")
website_select:value("7","Kodexplorer（可道云aka芒果云在线文档管理器）")
website_select:value("8","Typecho (流畅的轻量级开源博客程序)")
website_select:value("9","Z-Blog (体积小，速度快的PHP博客程序)")
website_select:value("10","DzzOffice (开源办公平台)")
website_select:depends("autodeploy_enable",1)
redis_enabled=website_section:option(Flag,"redis_enabled",translate("启用Redis"),translate("只有Owncloud和Nextcloud才可以使用。<br>需要先在web界面配置完成后，才能使用开启Redis"))
redis_enabled:depends("website_select","3")
redis_enabled:depends("website_select","4")
customdeploy_enabled=website_section:option(Flag,"customdeploy_enabled",translate("启用自定义部署"))
customdeploy_enabled:depends("autodeploy_enable",0)
website_dir=website_section:option(Value,"website_dir",translate("网站目录"),translate("该目录自动创建在/opt/wwwroot/下，只需输入目录名"))
website_dir:depends("customdeploy_enabled",1)
port=website_section:option(Value,"port",translate("设定访问端口"),translate("自定义端口不能重复前面已使用过的端口<br>(自动获取)只能在自动部署脚本已定义的端口"))
port:value("",translate("自动获取"))

return m
