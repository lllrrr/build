-- Copyright 2012 Gabor Varga <vargagab@gmail.com>
-- Licensed to the public under the Apache License 2.0.

module("luci.controller.axel", package.seeall)

function index()
	 if not nixio.fs.access("/etc/config/axel") then
		 return
	 end
	
	entry({"admin", "nas"}, firstchild(), "NAS", 44).dependent = false
	-- entry({"admin","nas","axel","status"},call("act_status")).leaf=true

	local page = entry({"admin", "nas", "axel"}, cbi("axel"), _("axel"))
	page.dependent = true

end
-- function act_status()
  -- local e={}
  -- e.running=luci.sys.call("pgrep axel > /dev/null") == 0
  -- luci.http.prepare_content("application/json")
  -- luci.http.write_json(e)
-- end
