local SYS = require "luci.sys"
m = Map("softwarecenter",translate("Entware软件安装"), translate("Entware提供超过2000多个不同平台的软件包。"))

s = m:section(TypedSection, "ipk")
s.anonymous = true
p = s:option(Flag, "deluge_install",translate("启用deluge"), translate("Deluge是一款优秀的BT下载客户端，采用python和GTK+开发。"))
p.default = 0
p.rmempty = false
p = s:option(Button, "_add", translate("安装deluge"))
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
	p.description = translate("deluge默认WebUI端口：888  登录密码：deluge" .. "<br/>".. state_msg .. "&nbsp;&nbsp;&nbsp;".. o)
else
	state_msg = "<b><font color=\"red\">" .. translate("deluge 没有运行") .. "</font></b>"
	p.description = translate("deluge默认WebUI端口：888  登录密码：deluge" .. "<br/>".. state_msg)
end
p:depends("deluge_install", 1)

s.anonymous = true
p = s:option(Flag, "transmission_install",translate("启用transmission"), translate("Transmission 是一个简单的 bittorrent 客户端"))
p.default = 0
p.rmempty = false
p = s:option(Button, "_ada", translate("安装transmission"))
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
	p.description = translate("transmission默认WebUI端口：9091" .. "<br/>".. state_msg .. "&nbsp;&nbsp;&nbsp;".. o)
else
	state_msg = "<b><font color=\"red\">" .. translate("transmission 没有运行") .. "</font></b>"
	p.description = translate("transmission默认WebUI端口：9091" .. "<br/>".. state_msg)
end
p:depends("transmission_install", 1)

s.anonymous = true
p = s:option(Flag, "rtorrent_install",translate("启用rtorrent"), translate("rtorrent是一个Linux下控制台的BT 客户端程序。"))
p.default = 0
p.rmempty = false
p = s:option(Button, "_adc", translate("安装rtorrent"))
p.inputtitle = translate("开始安装")
p.inputstyle = "apply"
p.forcewrite = true
function p.write(self, section)
	SYS.call("/usr/bin/softwarecenter/lib_functions.sh rtorrent &")
	luci.http.redirect(luci.dispatcher.build_url("admin/services/softwarecenter/log"))
end
-- p:depends("rtorrent_install", 1)
-- p = s:option(Value, "web_port", translate("WebUI端口"),translate("自定义WebUI端口"))
-- p.default = "81"
-- p.rmempty = true
local state=(SYS.call("pidof rtorrent > /dev/null") == 0)
if state then
	o="<input class=\"cbi-button cbi-button-apply\" type=\"button\" value=\" " .. translate("打开WebUI管理") .." \" onclick=\"window.open('http://'+window.location.hostname+':" .. "81" .. "/rutorrent" .. "')\"/>"
	state_msg = "<b><font color=\"green\">" .. translate("rutorrent 已经运行") .. "</font></b>"
	p.description = translate("rutorrent默认WebUI端口：81" .. "<br/>".. state_msg .. "&nbsp;&nbsp;&nbsp;".. o)
else
	state_msg = "<b><font color=\"red\">" .. translate("rutorrent 没有运行") .. "</font></b>"
	p.description = translate("rutorrent默认WebUI端口：81" .. "<br/>".. state_msg)
end
p:depends("rtorrent_install", 1)

return m
