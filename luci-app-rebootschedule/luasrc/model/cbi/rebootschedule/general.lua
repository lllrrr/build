m=Map("rebootschedule",translate("��ʱ���� Plus+"),
translate("<font color=\"green\"><b>�ö�ʱ����������õĲ�������� wulishui@gmail.com ��ԭ���޸ģ�֧�� wulishui �������� </font><font color=\"red\">�鿴ʹ��ʾ��</font><font color=\"green\"> ��ɨ���ά�����</font></b></br>") ..
translate("CRON���ʽ���ַ���������пո�ָ���ִ�������ֶ���ɡ� </br>* * * * * [command]</br>����ǺŰ���λ�÷ֱ��ʾ (��) (ʱ) (��) (��) (��) commond ��ʾ����ִ�е�����</br>�������ֵ��Χ�ǣ���(1-59), ʱ(0-23), ��(1-31)����(1-12), ��(0-6)��</br>ÿһ���ֶζ�����ʹ�÷�Χ֮�ڵ���ֵ�������°�ǵ������ַ������ɣ�</br>") ..
translate("1) �Ǻ� (*) ��ʾ����ֵ�����ڡ����ӡ��ֶ�ʹ��*, ��ʾÿ���Ӷ��ᴥ��һ�Ρ�</br>2) ���ַ� (-) ��ʾ��Χ�����ڡ����ӡ��ֶ�ʹ��5-20����ʾ�ڴ�5�ֵ�20��ʱ��ÿ���Ӵ���һ�Ρ�</br>3) ���� (,) ��ʾ�ָ���ֵ�����ڡ����ӡ��ֶ�ʹ��5,20����ʾ��ÿ5�ֺ�20��ʱ����һ�Ρ�</br>4) ��б�� (/) ��ʾÿ��ʱ�Ρ����ڡ����ӡ��ֶ�ʹ��5-45/20����ʾ��5�ֺ�25�ֺ�45��ÿ��20���Ӵ���һ�Ρ�</br>") ..
translate("<input class=\"cbi-button cbi-button-apply\" type=\"button\" value=\"" ..
translate("�鿴ʹ��ʾ��") ..
" \" onclick=\"window.open('http://'+window.location.hostname+'/reboothelp.jpg')\"/>") ..
translate("&nbsp;&nbsp;&nbsp;<input class=\"cbi-button cbi-button-apply\" type=\"button\" value=\"" ..
 translate("crontab�����÷�") ..
" \" onclick=\"window.open('https://tool.lu/crontab/')\"/>")
)

s=m:section(TypedSection,"crontab","")
s.template = "cbi/tblsection"
s.addremove = true
s.anonymous = true

p=s:option(Flag,"enable",translate("Enable"))
p.rmempty = false
p.default=0

month=s:option(Value,"month",translate("��"))
month.rmempty = false
month.default = '*'
month.size = 10

day=s:option(Value,"day",translate("��"))
day.rmempty = false
day.default = '*'
day.size = 10

hour=s:option(Value,"hour",translate("ʱ"))
hour.rmempty = false
hour.default = '5'
hour.size = 10

minute=s:option(Value,"minute",translate("��"))
minute.rmempty = false
minute.default = '0'
minute.size = 10

week=s:option(Value,"week",translate("��"))
week.rmempty = true
week:value('*',translate("Everyday"))
week:value(1,translate("Monday"))
week:value(2,translate("Tuesday"))
week:value(3,translate("Wednesday"))
week:value(4,translate("Thursday"))
week:value(5,translate("Friday"))
week:value(6,translate("Saturday"))
week:value(7,translate("Sunday"))
week.default='*'
week.size = 10

command=s:option(Value,"command",translate("ִ�е�����"))
command:value('sleep 5 && touch /etc/banner && reboot',translate("����ϵͳ"))
command:value('/etc/init.d/network restart',translate("��������"))
command:value('ifdown wan && ifup wan',translate("����wan"))
command:value('killall -q pppd && sleep 5 && pppd file /tmp/ppp/options.wan', translate("���²���"))
command:value('ifdown wan',translate("�ر�����"))
command:value('ifup wan',translate("������"))
command:value('wifi down',translate("�ر�WIFI"))
command:value('wifi up',translate("��WIFI"))
command:value('sync && echo 3 > /proc/sys/vm/drop_caches', translate("�ͷ��ڴ�"))
command:value('poweroff',translate("�رյ�Դ"))
command.default='sleep 5 && touch /etc/banner && reboot'
command.size = 10
-- command.datatype="uinteger"
-- command.placeholder = "53"

-- p = s:option(Button, "_baa", translate("����ִ��"))
-- p.inputtitle = translate("Ӧ��")
-- p.inputstyle = "apply"
-- p.forcewrite = true
-- p.write = function(self, section)
	-- uci:get("rebootschedule", '@crontab[0]', 'command', section)
-- end

local e=luci.http.formvalue("cbi.apply")
if e then
  io.popen("/etc/init.d/rebootschedule restart")
end

return m
