local p = require("luci.model.uci").cursor()
m=Map("softwarecenter",translate("应用安装"),translate("安装Entware的应用软件"))

s = m:section(TypedSection, "softwarecenter")
s.anonymous = true
p = s:option(Button, "_update", translate("rutorrent"))
p.inputtitle = translate("开始安装")
p.inputstyle = "apply"
function p.write(e, e)
luci.sys.call("cbi.apply")
	luci.sys.call("/usr/bin/softwarecenter/lib_functions.sh install_soft rutorrent")
	luci.http.redirect(luci.dispatcher.build_url("admin/services/softwarecenter/log"))
end
return m 