--[[
Copyright (C) 2019 Jianpeng Xiang (1505020109@mail.hnust.edu.cn)

This is free software, licensed under the GNU General Public License v3.
]]--

-- local util = require "luci.util"
local p = require("luci.model.uci").cursor()

--得到Map对象，并初始化。参一：指定cbi文件，参二：设置标题，参三：设置标题下的注释
m = Map("softwarecenter",translate("软件中心"),translate("软件中心负责Entware，ONMP的部署和软件的自动化统一配置！<br>原项目地址：") .. " ".. [[<a href="https://github.com/jsp1256/openwrt-package" target="_blank">]] ..translate("https://github.com/jsp1256/openwrt-package") .. [[</a>]])
--各个软件的状态
m:section(SimpleSection).template = "softwarecenter/software_status"

s = m:section(TypedSection,"softwarecenter",translate("软件中心设置"))
s.addremove = false
s.anonymous = true

s:tab("entware",translate("Entware设置"))
p = s:taboption("entware",Flag,"deploy_entware",translate("启用"),translate("开始部署Entware环境"))
local model = luci.sys.exec("uname -m 2>/dev/null")
local cpu_model = s:taboption("entware",Value,"cpu_model",translate("CPU架构"),translate("检测到CPU架构是：")..[[<font color="green">]]..[[<strong>]]..model..[[</strong>]]..[[</font>]]..' ')
cpu_model:value(model)
cpu_model:depends("deploy_entware",1)

local disk_size = luci.sys.exec("/usr/bin/softwarecenter/check_available_size.sh 2")
p = s:taboption("entware",ListValue,"disk_mount",translate("安装路径"),translatef("当前可用磁盘：<br><b style=\"color:green\">")..disk_size..("</b><br>选中的磁盘可能被重新格式化为EXT4文件系统<br><b style=\"color:red\">警告：请确保选中的磁盘上没有重要数据</b>"))
for list_disk_mount in luci.util.execi("lsblk -s | grep mnt | awk '{print $7}'") do
	p:value(list_disk_mount)
end
p:depends("deploy_entware",1)

p = s:taboption("entware",Flag,"entware_enable",translate("安装ONMP"),translate("ONMP是使用opkg包快速搭建Nginx/MySQL/PHP环境，<br>此安装过程可能需要大量时间，可以在日志中查看到安装的过程"))
p:depends("deploy_entware",1)

s:tab("swap",translate("swap交换分区设置"))
swap_enable = s:taboption("swap",Flag,"swap_enabled",translate("Enabled"),translate("当内存不足的时候，把一部分磁盘空间虚拟成内存使用"))
p = s:taboption("swap",Value,"swap_path",translate("安装路径"),translate("交换分区挂载点，默认可选是opt安装的所在盘"))
p:value(luci.sys.exec("uci get softwarecenter.main.disk_mount"))
p:depends("swap_enabled",1)
p = s:taboption("swap",Value,"swap_size",translate("空间大小"),translate("交换空间大小(M)，默认512M"))
p.default='512'
p:depends("swap_enabled",1)
swap_enable:depends("entware_enable",1)

s:tab("nginx",translate("Nginx服务器设置"))
deploy_nginx = s:taboption("entware",Flag,"deploy_nginx",translate("部署Nginx"),translate("自动部署Nginx服务器和其所需的PHP7运行环境"))
p = s:taboption("nginx",Flag,"nginx_enabled",translate("Enabled"),translate("部署完成后启动Nginx"))
p:depends("deploy_nginx",1)
deploy_nginx:depends("entware_enable",1)

s:tab("mysql",translate("MySQL服务器设置"))
deploy_mysql = s:taboption("entware",Flag,"deploy_mysql",translate("部署MySQL"),translate("自动部署MySQL数据库服务器(依赖Entware软件仓库)"))
p = s:taboption("mysql",Flag,"mysql_enabled",translate("Enabled"),translate("留空是默认登录用户  root  密码  123456"))
p:depends("deploy_mysql",1)
p = s:taboption("mysql",Value,"user",translate("用户"),translate("MySQL数据库服务器登录用户"))
p.placeholder="root"
p:depends("mysql_enabled",1)
p = s:taboption("mysql",Value,"pass",translate("密码"),translate("MySQL数据库服务器登录密码"))
p.password=true
p:depends("mysql_enabled",1)
deploy_mysql:depends("entware_enable",1)

website_section = m:section(TypedSection,"website",translate("网站管理"),translate("这里先添加名称确认后再选择要安装的应用软件"))
website_section.addremove = true

s:tab("website",translate("网站管理"))
website_enabled = website_section:option(Flag,"website_enabled",translate("Enabled"),translate("请确保Nginx服务器正常安装并且已运行！<br>某些还网站需要MySQL数据库服务器的支持"))
p = website_section:option(Flag,"autodeploy_enable",translate("启用自动部署"))
p:depends("customdeploy_enabled",0)
website_select = website_section:option(ListValue,"website_select",translate("website"),translate("请选择你需要部署的网站"))
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
redis_enabled = website_section:option(Flag,"redis_enabled",translate("启用Redis"),translate("只有Owncloud和Nextcloud才可以使用。<br>需要先在web界面配置完成后，才能使用开启Redis"))
redis_enabled:depends("website_select","3")
redis_enabled:depends("website_select","4")
customdeploy_enabled = website_section:option(Flag,"customdeploy_enabled",translate("启用自定义部署"))
customdeploy_enabled:depends("autodeploy_enable",0)
website_dir = website_section:option(Value,"website_dir",translate("网站目录"),translate("该目录自动创建在/opt/wwwroot/下，只需输入目录名"))
website_dir:depends("customdeploy_enabled",1)
port = website_section:option(Value,"port",translate("设定访问端口"),translate("自定义端口不能重复前面已使用过的端口<br>(自动获取)只能在自动部署脚本已定义的端口"))
port:value("",translate("自动获取"))

return m
