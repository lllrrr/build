m=Map("rebootschedule",translate("Reboot schedule"),
translate("<font color=\"green\"><b>A plug-in that makes timed tasks easier to use. It is modified with the original version of wulishui@gmail.com, which supports wulishui. Click below</font><font color=\"red\"> View usage example </font><font color=\"green\"> and then scan two Dimension Code Reward</font></b></br>") ..
translate("The string of the CRON expression is composed of five fields separated by spaces and executed commands. </br>* * * * * [command]</br>Five asterisks indicate (minutes) (hours) (days) (months) (weeks) according to their positions. commond indicates the command to be executed</br> The allowed range of values is minute (1-59), hour (0-23), day (1-31), month (1-12), week (0-6). </br>Each field can be composed of a value within the range or a combination of the following half-width special characters:</br>") ..
translate("1) An asterisk (*) indicates any value. If you use * in the \"minute\" field, it means that it will be triggered every minute. </br>2) A hyphen (-) indicates a range. If 5-20 is used in the \"minute\" field, it means that it will be triggered every minute from 5 to 20 minutes. </br>3) The comma (,) represents the split value. If you use 5,20 in the \"minute\" field, it means that it will be triggered every 5 minutes and 20 minutes. </br>4) Forward slash (/) means every time period. If you use 5-45/20 in the \"minute\" field, it means that it will be triggered every 20 minutes at 5 minutes, 25 minutes, and 45 minutes. </br>") ..
translate("<input class=\"cbi-button cbi-button-apply\" type=\"button\" value=\"" ..
translate("View usage example") ..
" \" onclick=\"window.open('http://'+window.location.hostname+'/reboothelp.jpg')\"/>") ..
translate("&nbsp;&nbsp;&nbsp;<input class=\"cbi-button cbi-button-apply\" type=\"button\" value=\"" ..
 translate("View crontab usage") ..
" \" onclick=\"window.open('https://tool.lu/crontab/')\"/>")
)

s=m:section(TypedSection,"crontab","")
s.template = "cbi/tblsection"
s.anonymous = false
s.addremove = true

p=s:option(Flag,"enable",translate("Enable"))
p.rmempty = false
p.default=0

month=s:option(Value,"month",translate("month"))
month.rmempty = false
month.default = '*'
month.size = 8

day=s:option(Value,"day",translate("day"))
day.rmempty = false
day.default = '*'
day.size = 8

hour=s:option(Value,"hour",translate("Hour"))
hour.rmempty = false
hour.default = '5'
hour.size = 8

minute=s:option(Value,"minute",translate("minute"))
minute.rmempty = false
minute.default = '0'
minute.size = 8

week=s:option(Value,"week",translate("weeks"))
week.rmempty = true
week:value('*',translate("Every day"))
week:value(1,translate("Monday"))
week:value(2,translate("Tuesday"))
week:value(3,translate("Wednesday"))
week:value(4,translate("Thursday"))
week:value(5,translate("Friday"))
week:value(6,translate("Saturday"))
week:value(7,translate("Sunday"))
week.default='*'
week.size = 8

command=s:option(Value,"command",translate("Task"))
command:value('sleep 5 && touch /etc/banner && reboot',translate("Reboots"))
command:value('/etc/init.d/network restart',translate("Restart network"))
command:value('ifdown wan && ifup wan',translate("Restart wan"))
command:value('killall -q pppd && sleep 5 && pppd file /tmp/ppp/options.wan', translate("Redial"))
command:value('ifdown wan',translate("Turn off networking"))
command:value('ifup wan',translate("Turn on networking"))
command:value('wifi down',translate("Turn off WIFI"))
command:value('wifi up',translate("Turn on WIFI"))
command:value('sync && echo 3 > /proc/sys/vm/drop_caches', translate("Free up memory"))
command:value('poweroff',translate("Turn off the power"))
command.default='sleep 5 && touch /etc/banner && reboot'

-- p = s:option(Button, "_baa", translate("Execute"))
-- p.inputtitle = translate("Apply")
-- p.inputstyle = "apply"
-- p.forcewrite = true
-- p.write = function(self, section)
--	 uci:get("rebootschedule", '@crontab[0]', 'command', section)
-- end

local open=luci.http.formvalue("cbi.apply")
if open then
  io.popen("/etc/init.d/rebootschedule restart")
end

return m
