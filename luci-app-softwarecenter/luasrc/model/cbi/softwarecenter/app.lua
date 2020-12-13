
m = Map("softwarecenter")

s = m:section(TypedSection, "app", "")
s.anonymous = true

p = s:option(Flag, "deluge_install",translate("启用deluge"))
p.default = 0
p.rmempty = false

p = s:option(Button, "_add", translate("安装deluge"))
p.inputtitle = translate("开始安装")
p.inputstyle = "apply"
p.forcewrite = true
function p.write(e, e)
	luci.sys.call("cbi.apply")
--	luci.sys.call("echo 98 >> /tmp/log/softwarecenter.log")
	luci.sys.call("/usr/bin/softwarecenter/lib_functions.sh install_soft deluge deluge-ui-web &")
	luci.sys.call("/opt/etc/init.d/S80deluged start &")
	luci.sys.call("/opt/etc/init.d/S81deluge-web start &")
	luci.http.redirect(luci.dispatcher.build_url("admin/services/softwarecenter/log"))
end
local running=(luci.sys.call("ps | grep 'deluge' | grep -v grep > /dev/null") == 0)
local state_msg = ""
if running then
  state_msg = "<b><font color=\"green\">" .. translate("正在运行") .. "</font></b>"
else
  state_msg = "<b><font color=\"red\">" .. translate("没有运行") .. "</font></b>"
end
p.description = translate("deluge默认WebUI端口：888" .. "<br/>".. translate("运行状态").. " : "  .. state_msg .. "<br />")
p:depends("deluge_install", 1)

return m 