#!/bin/bash
CPANEL_PATH="/usr/local/cpanel"
SITEAPPS_PATH="$CPANEL_PATH/3rdparty/siteapps"

 . $SITEAPPS_PATH/scripts/functions



function _help { 

    echo "Usage:"
    echo "$0 private_key public_key [ -f | -ff ]"
    echo "  by default (no options), the script will write the file, asking for connfirmation."
    echo "  -f used to also remove credentials file ."
    echo "  -ff used to remove also credentials and user data files."

}

if [ "$1" = "--help" ];then
    _help
    exit 0
fi


function remove_credentials_file {
    track_event "Uninstall" "Credentials" "2"
    echo -n "Removing $SITEAPPS_CREDENTIALS..."
    rm -f $SITEAPPS_CREDENTIALS
    echo "done."

}

function remove_all_data {
    track_event "Uninstall" "Data" "3"
    echo -n "Removing $SITEAPPS_DATADIR..."
    rm -rf $SITEAPPS_DATADIR
    echo "done."

}

function unregister_plugins {
    echo "Unregistering plugin icons (this can take a while)..."
    icons=$(find $SITEAPPS_PATH/icons/ -type f)

    for icon in $icons
    do
        icon_name=$(basename $icon | cut -d. -f1)
        echo -n " -Unregistering $icon_name..."
        $CPANEL_PATH/bin/unregister_cpanelplugin $icon > /dev/null
        echo "done."
    done

}

function unregister_cpanelapp {

    echo -n "Unregistering app..."
    $CPANEL_PATH/bin/unregister_appconfig $SITEAPPS_APPCONF_FILE > /dev/null
    test -f $CPANEL_PLUGIN_CACHE_FILE && rm -f $CPANEL_PLUGIN_CACHE_FILE
    echo "done."
}

function remove_autotags {
    $SITEAPPS_PATH/scripts/turn_off_mod_substitute.sh
    echo -n "Removing autotag configuration files (mod_substitute)..."
    test -d $APACHE_CONFIG_DIR && find $APACHE_CONFIG_DIR -name $AUTOTAG_CONF_FILENAME -exec rm -f {} \; && $CPANEL_PATH/scripts/ensure_vhost_includes --all-users > /dev/null
    echo "done."


}

function remove_files {
    for file in $FILES
    do
        echo -n " -Removing $file..."
        rm -rf $file
        echo "done."
    done
    template_links=$(find $CPANEL_PATH/base/frontend/ -type l -name siteapps*)
    for link in $template_links
    do
        echo -n " -Removing template link $link..."
        rm -f $link
        echo "done."
    done

    echo -n " -Removing directory $SITEAPPS_PATH..."
    rm -rf $SITEAPPS_PATH
    echo "done."

}
    

echo -n "Are you sure you want to UNINSTALL the SiteApps plugin ? (y/n)"
read ANSWER

if [ "$ANSWER" = "y" ]; then
    track_event "Uninstall" "Answer" "1"
    cd $CPANEL_PATH
    unregister_cpanelapp
    unregister_plugins
    if [ "$1" = "-f" ] && [ ! -s $SITEAPPS_CREDENTIALS ]; then
        remove_credentials_file
    fi

    if [ "$1" = "-ff" ]; then
        remove_all_data
    fi
    remove_autotags
    remove_files
    echo "Uninstall complete!"
else
    track_event "Uninstall" "Answer" "0"
    echo "SiteApps uninstall script aborted!"
fi
