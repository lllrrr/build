m = Map("softwarecenter")
s = m:section(TypedSection, "app", "")
s.anonymous = true

p = s:option(Flag, "deluge_install",translate("启用deluge"), translate("Deluge是一款优秀的BT下载客户端，采用python和GTK+开发。"))
p.default = 0
p.rmempty = false
local state=(luci.sys.call("ps | grep 'deluge' | grep -v grep > /dev/null") == 0)
if state then
	o="<input class=\"cbi-button cbi-button-apply\" type=\"button\" value=\" " ..translate("打开WebUI管理").." \" onclick=\"window.open('http://'+window.location.hostname+':" .. "888" .."')\"/>"
	state_msg = "<b><font color=\"green\">" .. translate("deluge运行中") .. "</font></b>"
else
	p = s:option(Button, "_add", translate("安装deluge"))
	p.inputtitle = translate("开始安装")
	p.inputstyle = "apply"
	p.forcewrite = true
	function p.write(self, section)
		luci.sys.call("cbi.apply")
		luci.sys.call("/usr/bin/softwarecenter/lib_functions.sh ipk_install deluge deluge-ui-web &")
		luci.sys.call("/opt/etc/init.d/S80deluged start &")
		luci.sys.call("/opt/etc/init.d/S81deluge-web start &")
		luci.http.redirect(luci.dispatcher.build_url("admin/services/softwarecenter/log"))
	end
	state_msg = "<b><font color=\"red\">" .. translate("deluge没有运行") .. "</font></b>"
end
if state then
	p.description = translate("deluge默认WebUI端口：888  登录密码：deluge" .. "<br/><br/>".. state_msg .. "&nbsp;&nbsp;&nbsp;".. o )
end
p:depends("deluge_install", 1)

return m
