local o = require "luci.sys"
local a, t, e
local button = ""
local state_msg = ""
local running=(luci.sys.call("iptables -L FORWARD|grep WEBURL >/dev/null") == 0)
local button = ""
local state_msg = ""

if running then
        state_msg = "<b><font color=\"green\">" .. translate("正在运行") .. "</font></b>"
else
        state_msg = "<b><font color=\"red\">" .. translate("没有运行") .. "</font></b>"
end


a = Map("weburl", translate("网址/关键字过滤"), translate(
            "<b><font color=\"green\">利用iptables的关键字过滤功能来过滤访问的网址或包含关键字的数据包，关键词可以是URL里包含的任意字符或者数据包中会出现的任意词条内容。</font></b>" .. button
        .. "<br/><br/>" .. translate("运行状态").. " : "  .. state_msg .. "<br />"))
t = a:section(TypedSection, "basic", translate(""), translate(""))
t.anonymous = true
e = t:option(Flag, "enable", translate("开启"))
e.rmempty = false
e = t:option(ListValue, "algos", translate("过滤力度"), translate("强效过滤会使用更复杂的算法导致更高的CPU占用。"))
e:value("0", "一般过滤")
e:value("1", "强效过滤")
e.default = "1"
t = a:section(TypedSection, "macbind", translate(""))
t.template = "cbi/tblsection"
t.anonymous = true
t.addremove = true
e = t:option(Flag, "enable", translate("开启控制"))
e.rmempty = false
e = t:option(Value, "macaddr", translate("黑名单MAC（可留空）"))
e.rmempty = true
o.net.mac_hints(function(t, a) e:value(t, "%s (%s)" % {t, a}) end)
e = t:option(Value, "timeon", translate("开始时间（可留空）"))
e.placeholder = "00:00"
e.rmempty = true
e = t:option(Value, "timeoff", translate("停止时间（可留空）"))
e.placeholder = "23:59"
e.rmempty = true
e = t:option(Value, "keyword", translate("关键词/URL"))
e.rmempty = false
return a


