local SYS = require "luci.sys"
font_green = [[<b><font color="green">]]
font_red = [[<b><font color="red">]]
font_off = [[</font></b>]]
font_op = " \" onclick=\"window.open('http://'+window.location.hostname+':"
font_apply = "<input class=\"cbi-button cbi-button-apply\" type=\"button\" value=\" "
m = Map("softwarecenter",translate("Entware软件安装"), translate("Entware提供超过2000多个不同平台的软件包<br>配置文件都软链接在 /opt/etc/config下，方便查看和修改"))

s = m:section(TypedSection, "ipk")
s.anonymous = true

p = s:option(Button, "_adf", translate("安装aMule"))
p.inputtitle = translate("开始安装")
p.inputstyle = "apply"
p.forcewrite = true
function p.write(self, section)
	SYS.call("/usr/bin/softwarecenter/lib_functions.sh amule &")
	luci.http.redirect(luci.dispatcher.build_url("admin/services/softwarecenter/log"))
end
local state=(SYS.call("pidof amuled > /dev/null") == 0)
if state then
	o=font_apply .. translate("打开WebUI管理") .. font_op .. "4711" .. "')\"/>"
	state_msg = font_green .. translate("aMule 运行中") .. font_off
	p.description = translate("aMule默认WebUI端口: 4711，密码: admin" .. "<br>" .. state_msg .. "<br>" .. o )
else
	state_msg = font_red .. translate("aMule 没有运行") .. font_off
	p.description = translate("aMule是一个开源免费的P2P文件共享软件，类似于eMule<br>基于xMule和lMule。可应用eDonkey网络协议，也支持KAD网络。" .. "<br>" .. state_msg )
end

p = s:option(Button, "_ada", translate("安装Aria2"))
p.inputtitle = translate("开始安装")
p.inputstyle = "apply"
p.forcewrite = true
p.write = function()
	SYS.call("/usr/bin/softwarecenter/lib_functions.sh aria2 &")
	luci.http.redirect(luci.dispatcher.build_url("admin/services/softwarecenter/log"))
end

local state=(SYS.call("pidof aria2c > /dev/null") == 0)
if state then
	o=font_apply .. translate("打开AriNG管理") .." \" onclick=\"window.open('http://ariang.ghostry.cn')\"/>&nbsp;&nbsp;&nbsp;<input class=\"cbi-button cbi-button-apply\" type=\"button\" value=\" " .. translate("打开webui-aria2管理") .." \" onclick=\"window.open('http://webui-aria2.ghostry.cn')\"/>"
	state_msg = font_green .. translate("Aria2 运行中") .. font_off
	p.description = translate(("Aria2 添加了") .. [[<a href="https://github.com/P3TERX/aria2.conf"target="_blank">]] .. translate(" P3TERX ") .. [[</a>]] .. translate("的增强和扩展功能。RPC的默认密钥为: Passw0rd") .. "<br>" .. state_msg .. "<br>" .. o )
else
	state_msg = font_red .. translate("Aria2 没有运行") .. font_off
	p.description = translate("Aria2 是一款开源、轻量级的多协议命令行下载工具<br>支持 HTTP/HTTPS、FTP、SFTP、BitTorrent 和 Metalink 协议" .. "<br>" .. state_msg )
end

p = s:option(Button, "_adb", translate("安装Deluge"))
p.inputtitle = translate("开始安装")
p.inputstyle = "apply"
p.forcewrite = true
p.write = function()
	SYS.call("/usr/bin/softwarecenter/lib_functions.sh deluge &")
	luci.http.redirect(luci.dispatcher.build_url("admin/services/softwarecenter/log"))
end
local state=(SYS.call("pidof deluge-web > /dev/null") == 0)
if state then
	o=font_apply .. translate("打开WebUI管理") .. font_op .. "888" .. "')\"/>"
	state_msg = font_green .. translate("Deluge 运行中") .. font_off
	p.description = translate("Deluge默认WebUI端口: 888，登录密码: deluge" .. "<br>" .. state_msg .. "<br>" .. o )
else
	state_msg = font_red .. translate("Deluge 没有运行") .. font_off
	p.description = translate("Deluge是一个免费好用的BT下载软件，使用libtorrent作为其后端<br>多种用户界面，占用系统资源少，有丰富的插件来实现核心以外的众多功能。" .. "<br>" .. state_msg )
end

p = s:option(Button, "_ade", translate("安装qBittorrent"))
p.inputtitle = translate("开始安装")
p.inputstyle = "apply"
p.forcewrite = true
function p.write(self, section)
	SYS.call("/usr/bin/softwarecenter/lib_functions.sh qbittorrent &")
	luci.http.redirect(luci.dispatcher.build_url("admin/services/softwarecenter/log"))
end
local state=(SYS.call("pidof qbittorrent-nox > /dev/null") == 0)
if state then
	o=font_apply .. translate("打开WebUI管理") .. font_op .. "9080" .. "')\"/>"
	state_msg = font_green .. translate("qBittorrent 运行中") .. font_off
	p.description = translate("qBittorrent默认WebUI端口: 9080，用启名: admin，密码: adminadmin" .. "<br>" .. state_msg .. "<br>" .. o )
else
	state_msg = font_red .. translate("qBittorrent 没有运行") .. font_off
	p.description = translate("qBittorrent是一个跨平台的自由BitTorrent客户端" .. "<br>" .. state_msg )
end

p = s:option(Button, "_add", translate("安装rTorrent"))
p.inputtitle = translate("开始安装")
p.inputstyle = "apply"
p.forcewrite = true
function p.write(self, section)
	SYS.call("/usr/bin/softwarecenter/lib_functions.sh rtorrent &")
	luci.http.redirect(luci.dispatcher.build_url("admin/services/softwarecenter/log"))
end
local state=(SYS.call("pidof rtorrent > /dev/null") == 0)
if state then
	o=font_apply .. translate("打开WebUI管理") .. font_op .. "1099" .. "/rutorrent" .. "')\"/>"
	state_msg = font_green .. translate("rTorrent 运行中") .. font_off
	p.description = translate("rTorrent默认WebUI端口: 1099" .. "<br>" .. state_msg .. "<br>" .. o )
else
	state_msg = font_red .. translate("rTorrent 没有运行") .. font_off
	p.description = translate("rTorrent是一个Linux下控制台的BT客户端程序，使用Novik的插件Rutorrent。" .. "<br>" .. state_msg )
end

p = s:option(Button, "_adc", translate("安装Transmission"))
p.inputtitle = translate("开始安装")
p.inputstyle = "apply"
p.forcewrite = true
function p.write(self, section)
	SYS.call("/usr/bin/softwarecenter/lib_functions.sh transmission &")
	luci.http.redirect(luci.dispatcher.build_url("admin/services/softwarecenter/log"))
end
local state=(SYS.call("pidof transmission-daemon > /dev/null") == 0)
if state then
	o=font_apply .. translate("打开WebUI管理") .. font_op .. "9091" .. "')\"/>"
	state_msg = font_green .. translate("Transmission 运行中") .. font_off
	p.description = translate("Transmission默认WebUI端口: 9091" .. "<br>" .. state_msg .. "<br>" .. o )
else
	state_msg = font_red .. translate("Transmission 没有运行") .. font_off
	p.description = translate("Transmission 是一个快速、精简的 bittorrent 客户端" .. "<br>" .. state_msg )
end
-- p:depends("transmission_install", 1)
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
