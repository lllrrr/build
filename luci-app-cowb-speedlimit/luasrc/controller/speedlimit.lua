module("luci.controller.speedlimit", package.seeall)

function index()
    if not nixio.fs.access("/etc/config/speedlimit") then
    	return
    end

    entry({"admin", "control"}, firstchild(), "Control", 50).dependent = false
    entry({"admin", "control", "speedlimit"}, cbi("speedlimit"), _("速度限制"), 6).dependent = true
 end

