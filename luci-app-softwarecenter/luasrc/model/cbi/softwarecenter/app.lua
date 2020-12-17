local SYS = require "luci.sys"
m = Map("softwarecenter",translate("Entware软件安装"), translate("Entware提供超过2000多个不同平台的软件包。"))

s = m:section(TypedSection, "ipk")
s.anonymous = true
-- aria2
p = s:option(Flag, "aria2_install",translate("启用aria2"), translate("aria2是一款开源、轻量级的多协议命令行下载工具<br/>支持 HTTP/HTTPS、FTP、SFTP、BitTorrent 和 Metalink 协议"))
p.default = 0
p.rmempty = false
p = s:option(Button, "_ada", translate("安装aria2"))
p.inputtitle = translate("开始安装")
p.inputstyle = "apply"
p.forcewrite = true
p.write = function()
	SYS.call("/usr/bin/softwarecenter/lib_functions.sh aria2 &")
	luci.http.redirect(luci.dispatcher.build_url("admin/services/softwarecenter/log"))
end
local state=(SYS.call("pidof aria2c > /dev/null") == 0)
if state then
	o="<input class=\"cbi-button cbi-button-apply\" type=\"button\" value=\" " .. translate("打开AriNG管理") .." \" onclick=\"window.open('http://ariang.ghostry.cn')\"/>&nbsp;&nbsp;&nbsp;<input class=\"cbi-button cbi-button-apply\" type=\"button\" value=\" " .. translate("打开webui-aria2管理") .." \" onclick=\"window.open('http://webui-aria2.ghostry.cn')\"/>"
	state_msg = "<b><font color=\"green\">" .. translate("aria2 已经运行") .. "</font></b>"
	p.description = translate("Aria2 RPC监听端口默认为：6800; RPC密码默认为：Passw0rd<br/>配置文件在   /opt/etc/aria2.conf " .. "<br/>".. o .. "&nbsp;&nbsp;&nbsp;".. state_msg)
else
	state_msg = "<b><font color=\"red\">" .. translate("aria2 没有运行") .. "</font></b>"
	p.description = translate("Aria2 RPC密码为空" .. "<br/>".. state_msg)
end
p:depends("aria2_install", 1)
-- deluge
p = s:option(Flag, "deluge_install",translate("启用deluge"), translate("Deluge是一个免费好用的BT下载软件，使用libtorrent作为其后端<br/>多种用户界面，占用系统资源少，有丰富的插件来实现核心以外的众多功能。"))
p.default = 0
p.rmempty = false
p = s:option(Button, "_adb", translate("安装deluge"))
p.inputtitle = translate("开始安装")
p.inputstyle = "apply"
p.forcewrite = true
p.write = function()
	SYS.call("/usr/bin/softwarecenter/lib_functions.sh deluge &")
	luci.http.redirect(luci.dispatcher.build_url("admin/services/softwarecenter/log"))
end
local state=(SYS.call("pidof deluge-web > /dev/null") == 0)
if state then
	o="<input class=\"cbi-button cbi-button-apply\" type=\"button\" value=\" " .. translate("打开WebUI管理") .." \" onclick=\"window.open('http://'+window.location.hostname+':" .. "888" .. "')\"/>"
	state_msg = "<b><font color=\"green\">" .. translate("deluge 已经运行") .. "</font></b>"
	p.description = translate("deluge默认WebUI端口：888  登录密码：deluge" .. "<br/>".. o .. "&nbsp;&nbsp;&nbsp;".. state_msg)
else
	state_msg = "<b><font color=\"red\">" .. translate("deluge 没有运行") .. "</font></b>"
	p.description = translate("deluge默认WebUI端口：888  登录密码：deluge" .. "<br/>".. state_msg)
end
p:depends("deluge_install", 1)
-- transmission
p = s:option(Flag, "transmission_install",translate("启用transmission"), translate("Transmission 是一个快速、精简的 bittorrent 客户端"))
p.default = 0
p.rmempty = false
p = s:option(Button, "_adc", translate("安装transmission"))
p.inputtitle = translate("开始安装")
p.inputstyle = "apply"
p.forcewrite = true
function p.write(self, section)
	SYS.call("/usr/bin/softwarecenter/lib_functions.sh transmission &")
	luci.http.redirect(luci.dispatcher.build_url("admin/services/softwarecenter/log"))
end
local state=(SYS.call("pidof transmission-daemon > /dev/null") == 0)
if state then
	o="<input class=\"cbi-button cbi-button-apply\" type=\"button\" value=\" " .. translate("打开WebUI管理") .." \" onclick=\"window.open('http://'+window.location.hostname+':" .. "9091" .. "')\"/>"
	state_msg = "<b><font color=\"green\">" .. translate("transmission 已经运行") .. "</font></b>"
	p.description = translate("transmission默认WebUI端口：9091" .. "<br/>".. o .. "&nbsp;&nbsp;&nbsp;".. state_msg)
else
	state_msg = "<b><font color=\"red\">" .. translate("transmission 没有运行") .. "</font></b>"
	p.description = translate("transmission默认WebUI端口：9091" .. "<br/>".. state_msg)
end
p:depends("transmission_install", 1)
-- rtorrent
p = s:option(Flag, "rtorrent_install",translate("启用rtorrent"), translate("rtorrent是一个Linux下控制台的BT 客户端程序。"))
p.default = 0
p.rmempty = false
p = s:option(Button, "_add", translate("安装rtorrent"))
p.inputtitle = translate("开始安装")
p.inputstyle = "apply"
p.forcewrite = true
function p.write(self, section)
	SYS.call("/usr/bin/softwarecenter/lib_functions.sh rtorrent &")
	luci.http.redirect(luci.dispatcher.build_url("admin/services/softwarecenter/log"))
end
local state=(SYS.call("pidof rtorrent > /dev/null") == 0)
if state then
	o="<input class=\"cbi-button cbi-button-apply\" type=\"button\" value=\" " .. translate("打开WebUI管理") .." \" onclick=\"window.open('http://'+window.location.hostname+':" .. "1099" .. "/rutorrent" .. "')\"/>"
	state_msg = "<b><font color=\"green\">" .. translate("rutorrent 已经运行") .. "</font></b>"
	p.description = translate("rutorrent默认WebUI端口：1099" .. "<br/>".. o .. "&nbsp;&nbsp;&nbsp;".. state_msg)
else
	state_msg = "<b><font color=\"red\">" .. translate("rutorrent 没有运行") .. "</font></b>"
	p.description = translate("rutorrent默认WebUI端口：1099" .. "<br/>".. state_msg)
end
p:depends("rtorrent_install", 1)
-- qbittorrent
p = s:option(Flag, "qbittorrent_install",translate("启用qbittorrent"), translate("qBittorrent是一个跨平台的自由BitTorrent客户端"))
p.default = 0
p.rmempty = false
p = s:option(Button, "_ade", translate("安装qbittorrent"))
p.inputtitle = translate("开始安装")
p.inputstyle = "apply"
p.forcewrite = true
function p.write(self, section)
	SYS.call("/usr/bin/softwarecenter/lib_functions.sh qbittorrent &")
	luci.http.redirect(luci.dispatcher.build_url("admin/services/softwarecenter/log"))
end
local state=(SYS.call("pidof qbittorrent-nox > /dev/null") == 0)
if state then
	o="<input class=\"cbi-button cbi-button-apply\" type=\"button\" value=\" " .. translate("打开WebUI管理") .." \" onclick=\"window.open('http://'+window.location.hostname+':" .. "9080" .. "')\"/>"
	state_msg = "<b><font color=\"green\">" .. translate("qbittorrent 已经运行") .. "</font></b>"
	p.description = translate("qbittorrent默认WebUI端口：9080 用启名：admin 密码：adminadmin<br/>配置文件在 /opt/etc/qBittorrent_entware/config/qBittorrent.conf " .. "<br/>".. o .. "&nbsp;&nbsp;&nbsp;".. state_msg)
else
	state_msg = "<b><font color=\"red\">" .. translate("qbittorrent 没有运行") .. "</font></b>"
	p.description = translate("qbittorrent默认WebUI端口：9080" .. "<br/>".. state_msg)
end
p:depends("qbittorrent_install", 1)
-- amule
p = s:option(Flag, "amule_install",translate("启用amule"), translate("aMule是一个开源免费的P2P文件共享软件，类似于eMule<br/>基于xMule和lMule。可应用eDonkey网络协议，也支持KAD网络。"))
p.default = 0
p.rmempty = false
p = s:option(Button, "_adf", translate("安装amule"))
p.inputtitle = translate("开始安装")
p.inputstyle = "apply"
p.forcewrite = true
function p.write(self, section)
	SYS.call("/usr/bin/softwarecenter/lib_functions.sh amule &")
	luci.http.redirect(luci.dispatcher.build_url("admin/services/softwarecenter/log"))
end
local state=(SYS.call("pidof amuled > /dev/null") == 0)
if state then
	o="<input class=\"cbi-button cbi-button-apply\" type=\"button\" value=\" " .. translate("打开WebUI管理") .." \" onclick=\"window.open('http://'+window.location.hostname+':" .. "4711" .. "')\"/>"
	state_msg = "<b><font color=\"green\">" .. translate("amule 已经运行") .. "</font></b>"
	p.description = translate("amule默认WebUI端口：4711" .. "<br/>".. state_msg .. "&nbsp;&nbsp;&nbsp;".. o)
else
	state_msg = "<b><font color=\"red\">" .. translate("amule 没有运行") .. "</font></b>"
	p.description = translate("amule默认WebUI端口：4711" .. "<br/>".. state_msg)
end
p:depends("amule_install", 1)
-- p = s:option(Value, "web_port", translate("WebUI端口"),translate("自定义WebUI端口"))
-- p.default = "81"
-- p.rmempty = true
-- p:depends("rtorrent_install", 1)
-- p = s:option(Button, "_adp", translate("重启rtorrent"))
-- p.inputtitle = translate("重启rtorrent")
-- p.inputstyle = "apply"
-- p.forcewrite = true
-- function p.write(self, section)
	-- SYS.call("/opt/etc/init.d/S80lighttpd restart && /opt/etc/init.d/S85rtorrent restart &")
	-- luci.http.redirect(luci.dispatcher.build_url("admin/services/softwarecenter/app"))
-- end
-- p:depends("rtorrent_install", 1)

return m
