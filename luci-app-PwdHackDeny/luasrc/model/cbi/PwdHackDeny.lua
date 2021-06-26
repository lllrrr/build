local fs  = require "nixio.fs"
local sys = require "luci.sys"
local uci = require "luci.model.uci".cursor()
local ipc = require "luci.ip"
local button = ""
local m,s,n
local button = ""
local state_msg = ""
local state_msg2 = ""
local state_msg3 = ""
local state_msg4 = "<font color=\"gray\">WEB最近登录日志</font>"
local state_msg5 = "<font color=\"gray\">SSH最近登录日志</font>"
local running=(luci.sys.call("pidof PwdHackDeny.sh > /dev/null") == 0)
local aa2=(luci.sys.call("[ `cat /etc/PwdHackDeny/badip.log.web 2>/dev/null|grep -c 'failed login on'` -gt 0 ]") == 0)
local bb2=(luci.sys.call("[ `cat /etc/PwdHackDeny/badip.log.ssh 2>/dev/null|grep -c 'Bad password attempt'` -gt 0 ]") == 0)

if running then
        state_msg = "<b><font color=\"green\">" .. translate("正在运行") .. "</font></b>"
else
        state_msg = "<b><font color=\"red\">" .. translate("没有运行") .. "</font></b>"
end
if aa2 then
        state_msg4 = "<b><font color=\"red\">" .. translate("有WEB异常登录！") .. "</font></b>"
end
if bb2 then
        state_msg5 = "<b><font color=\"red\">" .. translate("有SSH异常登录！") .. "</font></b>"
end

m = Map("PwdHackDeny", translate("PwdHackDeny"))
m.description = translate("<font style='color:gray'>监控SSH及WEB异常登录，密码错误累计达到 5 次的内外网客户端都禁止连接SSH以及WEB登录端口，直到手动删除相应的IP或MAC名单为止。也可以在名单中添加排除项目，被排除的客户端将不会被禁止。</font>" .. button .. "<br/><br/>" .. translate("运行状态").. " : "  .. state_msg .. state_msg2 .. state_msg3 .."<br />")

s = m:section(TypedSection, "PwdHackDeny")
s.anonymous=true
s.addremove=false
--s.template = "cbi/tblsection"

enabled = s:option(Flag, "enabled", translate("启用"), translate(""))
enabled.default = 0
enabled.rmempty = true

--[[
clearlog = s:option(Button, "clearlog", translate("清除日志"), translate(""))
function clearlog.write()
   sys.exec("sh /etc/init.d/PwdHackDeny clearlog")
   luci.http.redirect(luci.dispatcher.build_url("admin", "control", "PwdHackDeny"))
end

setport =s:option(Value,"time",translate("巡查时间（秒）"))
setport.description = translate("")
setport.placeholder=5
setport.default=5
setport.datatype="port"
setport.rmempty=false

setport =s:option(Value,"sum",translate("失败次数（次）"))
setport.description = translate("")
setport.placeholder=5
setport.default=5
setport.datatype="port"
setport.rmempty=false
]]--
s = m:section(TypedSection, "PwdHackDeny")
s.anonymous=true

s:tab("config1", translate(""  .. state_msg5 .. ""))
conf = s:taboption("config1", Value, "editconf1", nil, translate("<font style='color:red'>新的信息需要刷新页面才会显示。如原为启用状态，禁用后又再启用会清除日志显示，但不会清除累积计数。</font>"))
conf.template = "cbi/tvalue"
conf.rows = 20
conf.wrap = "off"
conf.readonly="readonly"
--conf:depends("enabled", 1)
function conf.cfgvalue()
	return fs.readfile("/etc/PwdHackDeny/badip.log.ssh", value) or ""
end

s:tab("config2", translate(""  .. state_msg4 .. ""))
conf = s:taboption("config2", Value, "editconf2", nil, translate("<font style='color:red'>新的信息需要刷新页面才会显示。如原为启用状态，禁用后又再启用会清除日志显示，但不会清除累积计数。</font>"))
conf.template = "cbi/tvalue"
conf.rows = 20
conf.wrap = "off"
conf.readonly="readonly"
--conf:depends("enabled", 1)
function conf.cfgvalue()
	return fs.readfile("/etc/PwdHackDeny/badip.log.web", value) or ""
end

if (luci.sys.call("[ -s /etc/PwdHackDeny/badhosts.web ] ") == 0) then
s:tab("config3", translate("<font style='color:brown'>WEB累积记录</font>"))
conf = s:taboption("config3", Value, "editconf3", nil, translate("<font style='color:red'>新的信息需要刷新页面才会显示。如记录中有自己的MAC，可复制到相应的黑名单中，在前面加#可避免被屏蔽。</font>"))
conf.template = "cbi/tvalue"
conf.rows = 20
conf.wrap = "off"
conf.readonly="readonly"
--conf:depends("enabled", 1)
function conf.cfgvalue()
	return fs.readfile("/etc/PwdHackDeny/badhosts.web", value) or ""
end
end

if (luci.sys.call("[ -s /etc/PwdHackDeny/badhosts.ssh ] ") == 0) then
s:tab("config4", translate("<font style='color:brown'>SSH累积记录</font>"))
conf = s:taboption("config4", Value, "editconf4", nil, translate("<font style='color:red'>新的信息需要刷新页面才会显示。如记录中有自己的MAC，可复制到相应的黑名单中，在前面加#可避免被屏蔽。</font>"))
conf.template = "cbi/tvalue"
conf.rows = 20
conf.wrap = "off"
conf.readonly="readonly"
--conf:depends("enabled", 1)
function conf.cfgvalue()
	return fs.readfile("/etc/PwdHackDeny/badhosts.ssh", value) or ""
end
end

s:tab("config5", translate("<font style='color:black'>SSH禁止名单</font>"))
conf = s:taboption("config5", Value, "editconf5", nil, translate("<font style='color:red'>预设名单内外网都可以添加IP或MAC地址，IP4段格式为192.168.18.10-20，不能为192.168.1.1/24或192.168.18.10-192.168.18.20。自动拦截的内网名单仅自动添加MAC地址。</font>"))
conf.template = "cbi/tvalue"
conf.rows = 20
conf.wrap = "off"
function conf.cfgvalue(self, section)
    return fs.readfile("/etc/SSHbadip.log") or ""
end
function conf.write(self, section, value)
    if value then
        value = value:gsub("\r\n?", "\n")
        fs.writefile("/tmp/SSHbadip.log", value)
        if (luci.sys.call("cmp -s /tmp/SSHbadip.log /etc/SSHbadip.log") == 1) then
            fs.writefile("/etc/SSHbadip.log", value)
        end
        fs.remove("/tmp/SSHbadip.log")
    end
end

s:tab("config6", translate("<font style='color:black'>WEB禁止名单</font>"))
conf = s:taboption("config6", Value, "editconf6", nil, translate("<font style='color:red'>预设名单内外网都可以添加IP或MAC地址，IP4段格式为192.168.18.10-20，不能为192.168.1.1/24或192.168.18.10-192.168.18.20。自动拦截的内网名单仅自动添加MAC地址。</font>"))
conf.template = "cbi/tvalue"
conf.rows = 20
conf.wrap = "off"
function conf.cfgvalue(self, section)
    return fs.readfile("/etc/WEBbadip.log") or ""
end
function conf.write(self, section, value)
    if value then
        value = value:gsub("\r\n?", "\n")
        fs.writefile("/tmp/WEBbadip.log", value)
        if (luci.sys.call("cmp -s /tmp/WEBbadip.log /etc/WEBbadip.log") == 1) then
            fs.writefile("/etc/WEBbadip.log", value)
        end
        fs.remove("/tmp/WEBbadip.log")
    end
end

e = luci.http.formvalue("cbi.apply")
if e then
  io.popen("/etc/init.d/PwdHackDeny start")
end

return m
