local e=require"nixio.fs"
local e=luci.http
local a,t,e
a=Map("ddnsto",translate("DDNSTO内网穿透"),
translate("DDNSTO是koolshare小宝开发的，支持http2的快速远程穿透工具。") ..
translate("<br><br><input class=\"cbi-button cbi-button-apply\" type=\"button\" value=\"" .. 
translate("注册配置管理") ..
" \" onclick=\"window.open('https://www.ddnsto.com/')\"/>"))

a.template="ddnsto/index"
t=a:section(TypedSection,"global",translate("Running Status"))
t.anonymous=true

e=t:option(DummyValue,"_status",translate("Running Status"))
e.template="ddnsto/dvalue"
e.value=translate("Collecting data...")

t=a:section(TypedSection,"global",translate("全局设置"),translate("设置教程:</font><a style=\"color: #ff0000;\" onclick=\"window.open('http://koolshare.cn/thread-116500-1-1.html')\">点击跳转到论坛教程</a>"))
t.anonymous=true
t.addremove=false

e=t:option(Flag,"enable",translate("启用"))
e.default=0
e.rmempty=false

e=t:option(Value,"start_delay",translate("延迟启动"),translate("单位：秒"))
e.datatype="uinteger"
e.default="0"
e.rmempty=true

e=t:option(Value,"token",translate('ddnsto 令牌'))
e.password=true
e.rmempty=false

return a
