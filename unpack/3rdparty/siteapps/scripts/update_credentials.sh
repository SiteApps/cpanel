#!/bin/bash
CPANEL_PATH="/usr/local/cpanel"
SITEAPPS_PATH="$CPANEL_PATH/3rdparty/siteapps"

 . $SITEAPPS_PATH/scripts/functions

function _help {

    echo "Usage:"
    echo "$0 private_key public_key [ -f | -ff ]"
    echo "  by default (no options), the script will write the file, asking for connfirmation."
    echo "  -f used to write the file but don't overwrite an existing one."
    echo "  -ff used to write the file and overwrite an existing one."

}

if [ "$1" = "--help" ];then
    _help
    exit 0
fi

if [ $# -lt 2 ]; then
    echo "No arguments supplied"
    echo "Use $0 private_key public_key [ -f | -ff ]"
    exit 1
fi

function write_credentials_file {
    track_event "Credentials" "File" "1"
    if [ -s $SITEAPPS_CREDENTIALS ]; then
        d=`date +%s`
        echo "Backuping existing file to $SITEAPPS_CREDENTIALS.$d"
        cp -a $SITEAPPS_CREDENTIALS $SITEAPPS_CREDENTIALS.$d
    fi

    echo -e "billing_url,active,private_key,public_key\r\nhttp://,1,$1,$2"  > $SITEAPPS_CREDENTIALS || error "Cannot write to file $SITEAPPS_CREDENTIALS"
    chmod 600 $SITEAPPS_CREDENTIALS || error "Cannot set permissions to credentials file $SITEAPPS_CREDENTIALS"
    echo "$SITEAPPS_CREDENTIALS created!"
}

test -d `dirname $SITEAPPS_CREDENTIALS` || mkdir -m 0700 -p `dirname $SITEAPPS_CREDENTIALS`

if [ "$3" = "-f" ] && [ ! -s $SITEAPPS_CREDENTIALS ]; then
    write_credentials_file $1 $2
    exit 0
elif [ "$3" = "-f" ] && [ -s $SITEAPPS_CREDENTIALS ]; then
    error "$SITEAPPS_CREDENTIALS already exists, please see help ($0 --help) to force."
fi

if [ "$3" = "-ff" ]; then
    write_credentials_file $1 $2
    exit 0
fi

echo "PRIVATE KEY: $1"
echo "PUBLIC KEY: $2"
echo -n "Is this correct ? (y/n)"
read ANSWER

if [ "$ANSWER" = "y" ]; then
    if [ -s $SITEAPPS_CREDENTIALS ]; then
        echo -n "$SITEAPPS_CREDENTIALS already exists, should I overwrite it ? (y/n)"
        read OVERWRITE_ANSWER
        if [ "$OVERWRITE_ANSWER" = "y" ]; then
            write_credentials_file $1 $2
        else
            echo "Creation of $SITEAPPS_CREDENTIALS aborted!"
            exit 1
        fi
    else
        write_credentials_file $1 $2
    fi
else 
    track_event "Credentials" "File" "0"
    echo "Creation of $SITEAPPS_CREDENTIALS aborted!"
fi
