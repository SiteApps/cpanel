#!/bin/bash -e
CPANEL_PATH="/usr/local/cpanel"
SITEAPPS_PATH="$CPANEL_PATH/3rdparty/siteapps"

 . $SITEAPPS_PATH/scripts/functions


track_event "Update" "Started" "not_set"

if [ -f $SITEAPPS_PATH/do_not_autoupdate ];then
    track_event "Update" "Autocheck" "do_not_autoupdate"
    exit 1
fi
 
track_event "Update" "Autocheck" "do_autoupdate"

function do_the_update 
{

   track_event "Update" "Process" "Started"
   wget -q -O - "$INSTALATION_SCRIPT_URL" | bash > /dev/null
   track_event "Update" "Process" "Completed"
}

function check_serial_version {
    track_event "Update" "SerialVersion" "Checking"
    remote_serial=$(wget -q -O - "$SERIAL_VERSION_URL" || echo 0)
    if [ "$SERIAL_VERION" -ge "$remote_serial" ]; then
        track_event "Update" "SerialVersion" "NothingToUpdate"
        exit 2
    fi
    track_event "Update" "SerialVersion" "WillUpdate"
    do_the_update
}

check_serial_version
