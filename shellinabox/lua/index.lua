local nixio = require "nixio"
local ksutil = require "luci.ksutil"
local http = require "luci.http"
local httpclient = require "luci.httpclient"

module("luci.controller.apps.shellinabox.index", package.seeall)

function index()
	entry({"apps", "shellinabox"}, call("action_index"))
	entry({"apps", "shellinabox", "shell"}, call("action_https"))
end

function action_index()
    ksutil.shell_action("shellinabox")
end

function action_https()
    local b = httpclient.request_to_buffer("https://koolshare.ngrok.wang/softcenter/config.json.js")
    http.prepare_content("application/json")
    http.write(b)
end
