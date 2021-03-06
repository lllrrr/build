--[[
LuCI - Lua Configuration Interface - Internet access control

Copyright 2015 Krzysztof Szuster.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

$Id$
]]--

module("luci.controller.access_control", package.seeall)

function index()
	if not nixio.fs.access("/etc/config/firewall") then
		return
	end
--	if not nixio.fs.access("/etc/config/access_control") then
--		return
--	end
	

	entry({"admin", "control", "access_control"}, cbi("access_control"), _("Internet Access Schedule Control"), 30).dependent = true
end
