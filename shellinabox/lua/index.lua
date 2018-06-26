local nixio = require "nixio"
local ksutil = require "luci.ksutil"
local http = require "luci.http"
local httpclient = require "luci.httpclient"

module("luci.controller.apps.shellinabox.index", package.seeall)

function index()
	entry({"apps", "shellinabox"}, call("action_index"))
	entry({"apps", "shellinabox", "shell"}, call("action_shell"))
	entry({"apps", "shellinabox", "shell", "styles.css"}, call("action_style"))
	entry({"apps", "shellinabox", "shell", "ShellInABox.js"}, call("action_js"))
	entry({"apps", "shellinabox", "shell", "keyboard.html"}, call("action_html"))
	entry({"apps", "shellinabox", "shell", "keyboard.png"}, call("action_png"))
end

function action_index()
    ksutil.shell_action("shellinabox")
end

function action_https()
    local b = httpclient.request_to_buffer("https://koolshare.ngrok.wang/softcenter/config.json.js")
    http.prepare_content("application/json")
    http.write(b)
end

function action_https2()
    local reader = httpclient.request_to_source("https://koolshare.ngrok.wang/softcenter/config.json.js")
    http.prepare_content("application/json")
    luci.ltn12.pump.all(reader, luci.http.write)
end

function action_shell()
    local method = http.getenv("REQUEST_METHOD")
    local options = {}
    if method == "POST" then
        http.prepare_content("application/json; charset=UTF-8")

        options.method = "POST"
        options.sndtimeo = 60
        options.rcvtimeo = 60
        options.headers = {}
        options.headers["Content-Type"] = "application/x-www-form-urlencoded; charset=utf-8"
        local forms = http.formvalue()
        options.body = forms
        local reader = httpclient.request_to_source("http://127.0.0.1:4200/?", options)
        luci.ltn12.pump.all(reader, luci.http.write)
    else
        http.prepare_content("text/html; charset=UTF-8")
        options.method = "GET"
        local reader = httpclient.request_to_source("http://127.0.0.1:4200", options)
        luci.ltn12.pump.all(reader, luci.http.write)
    end
end

function action_file(file,tp)
    local reader = httpclient.request_to_source("http://127.0.0.1:4200/"..file)
    http.prepare_content(tp)
    luci.ltn12.pump.all(reader, luci.http.write)
end

function action_style()
    action_file("styles.css", "text/css; charset=UTF-8")
end
function action_js()
    action_file("ShellInABox.js", "text/javascript; charset=UTF-8")
end
function action_html()
    action_file("keyboard.html", "text/html; charset=UTF-8")
end
function action_png()
    action_file("keyboard.png", "image/png")
end
