module("luci.controller.rebootschedule", package.seeall)
function index()
	if not nixio.fs.access("/etc/config/rebootschedule") then return end
	entry({"admin", "services", "rebootschedule"},
		alias("admin", "services", "rebootschedule", "general"),
		_("Reboot schedule"), 10)

	entry({"admin", "services", "rebootschedule", "general"},
		cbi("rebootschedule/general"),
		_("General Settings"), 20).leaf = true

	entry({"admin", "services", "rebootschedule", "crontab"},
		cbi("rebootschedule/crontab"),
		_("crontabs"), 30).leaf = true
end
