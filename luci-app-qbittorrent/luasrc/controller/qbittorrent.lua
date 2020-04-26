
local fs   = require "nixio.fs"
local sys  = require "luci.sys"
local http = require "luci.http"
local util = require "luci.util"
local uci  = require "luci.model.uci".cursor()

module("luci.controller.qbittorrent",package.seeall)

function index()
  if not nixio.fs.access("/etc/config/qbittorrent")then
    return
  end

	entry({"admin","nas","qbittorrent","status"},
		call("act_status"))
  
 	entry({"admin", "nas", "qbittorrent"},
		firstchild(), _("qBittorrent")).dependent = false
		
	entry({"admin", "nas", "qbittorrent", "config"},
		cbi("qbittorrent/config"), _("Global settings"), 1)

	entry({"admin", "nas", "qbittorrent", "file"},
		form("qbittorrent/files"), _("configuration file"), 2)

	entry({"admin", "nas", "qbittorrent", "log"},
		form("qbittorrent/log"), _("Operation log"), 3)

	entry({"admin", "nas", "qbittorrent","view"},
		template("qbittorrent/log_template"))
end

function act_status()
  local e={}
  e.running=luci.sys.call("pgrep qbittorrent-nox >/dev/null")==0
  http.prepare_content("application/json")
  http.write_json(e)
end

