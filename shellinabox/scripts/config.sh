#!/bin/bash

. /koolshare/scripts/base.sh
. /koolshare/scripts/jshn.sh
. /koolshare/scripts/uci.sh

on_get() {
    local shellinabox_enabled
    config_load shellinabox
    config_get shellinabox_enabled main enabled

    status=`pidof shellinaboxd`

    echo '{"status":"'${status}'","enabled":"'$shellinabox_enabled'"}'
}

on_post() {
    local shellinabox_enabled
    local shellinabox_firwall

    json_load "$INPUT_JSON"
    json_get_var shellinabox_enabled "enabled"
    json_get_var shellinabox_firewall "firewall"
    uci -q batch <<-EOT
set shellinabox.main.enabled=$shellinabox_enabled
set shellinabox.main.firewall=$shellinabox_firewall
EOT

    if [ "$shellinabox_enabled"x = "1"x ]; then
        killall shellinaboxd
        $APP_ROOT/bin/shellinaboxd --css=$APP_ROOT/bin/white-on-black.css -b
        uci commit
        on_get
    elif [ "$shellinabox_enabled"x = "0"x ]; then
        killall shellinaboxd
        uci commit
        on_get
    else
        echo '{"status": "json_parse_failed"}'
    fi
}

on_start() {
    local shellinabox_enabled
    config_load shellinabox
    config_get shellinabox_enabled main enabled
    if [ "$shellinabox_enabled"x = "1"x ]; then
        killall shellinaboxd
        $APP_ROOT/bin/shellinaboxd --css=$APP_ROOT/bin/white-on-black.css -b
    fi
}

on_stop() {
    killall shellinaboxd
}

case $ACTION in
start)
    on_start
    ;;
post)
    on_post
    ;;
get)
    on_get
    ;;
installed)
    app_init_cfg '{"shellinabox":[{"_id":"main","enabled":"0"}]}'
    ;;
status)
    on_get
    ;;
stop)
    on_stop
    ;;
*)
    on_start
    ;;
esac

