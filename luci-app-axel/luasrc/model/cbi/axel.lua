require("luci.sys")
require("luci.util")
require("luci.model.ipkg")
local uci = require "luci.model.uci".cursor()
local state=(luci.sys.call("pgrep axel >/dev/null") == 0)

if state then
	state_msg = "<b><font color=\"green\">" .. translate("Axel ��������") .. "</font></b>"
else
	state_msg = "<b><font color=\"red\">" .. translate("Axel û������") .. "</font></b>"
end

local s=luci.sys.exec("HOME=/tmp axel --version | awk '/Axel/{print $2}'")
m = Map("axel", "Axel", translate("axel ��һ��֧��HTTP��HTTPS��FTP��FTPSЭ�鲻��ĸ������ع��ߡ�֧�ֶ��߳����ء��ϵ��������ҿ��ԴӶ����ַ���ߴ�һ����ַ�Ķ������������ͬһ���ļ����ʺ����ٲ�����ʱ���߳�������������ٶȡ�") .. "<br/><br/>" .. translate("����״̬ : ") .. state_msg .. "<br/><br/>")

t = m:section(NamedSection,"main", "axel")
t:tab("basic",translate("Basic Settings"))
e=t:taboption("basic",Flag,"enabled",translate("����"),"%s  %s"%{translate(""),"<b style=\"color:green\">"..translatef("��ǰAxel�İ汾: %s",s).."</b>"})
e=t:taboption("basic",Value,"SavePath",translate("����·��"),translate("�����ļ��ı���·�������磺<code>/mnt/sda1/download</code>"))
e.placeholder="/tmp/download"

return m