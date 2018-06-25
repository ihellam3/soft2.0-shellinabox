local nixio = require "nixio"
local ksutil = require "luci.ksutil"

module("luci.controller.apps.shellinabox.index", package.seeall)

function index()
	entry({"apps", "shellinabox"}, call("action_index"))
end

function action_index()
    ksutil.shell_action("shellinabox")
end

