#!/bin/bash
CPANEL_PATH="/usr/local/cpanel"
SITEAPPS_PATH="$CPANEL_PATH/3rdparty/siteapps"

 . $SITEAPPS_PATH/scripts/functions

function remove_rawopts_configuration {
    for apache_version in $SUPPORTED_APACHE_VERSIONS
    do
        if [ -s $RAWOPTS_DIR/$apache_version ]; then
            echo -en ""$BLUE"Removing mod_substitute from rawopts for $apache_version...$COLOR_END"
            egrep -v "\-\-enable\-substitute=shared" $RAWOPTS_DIR/$apache_version >  $RAWOPTS_DIR/$apache_version.new
            \mv  $RAWOPTS_DIR/$apache_version.new  $RAWOPTS_DIR/$apache_version
            echo -e ""$GREEN"done.$COLOR_END"
        fi
    done
}


function remove_custom_opt_mods
{
    echo -en ""$BLUE"Removing mod_substitute from custom opts mods...$COLOR_END"
    rm -rf $CUSTOM_OPT_MOD_DIR/Cpanel/Easy/ModSubstitute.pm* $CUSTOM_OPT_MOD_DIR/mod_substitute 2> /dev/null
    echo -e ""$GREEN"done.$COLOR_END"
}


function disable_substitute {
    track_event "Substitute" "Disable" "Started"
    substitute_error="Error disabling mod_substitute to auto include the SiteApps javascript TAG"
    remove_custom_opt_mods
    if [ -f $APACHE_CONFIG ]; then
        already_enabled=`grep "$LOAD_MODULE_LINE" $APACHE_CONFIG | egrep -v "^#" || echo ""`
        if [ ! "$already_enabled" = "" ]; then
            track_event "Substitute" "Disable" "Removing-Config"
            echo -e ""$BLUE"Removing mod_substitute from apache conf...$COLOR_END"
            egrep -v "$LOAD_MODULE_LINE" $APACHE_CONFIG > $APACHE_CONFIG.new
            \mv $APACHE_CONFIG.new $APACHE_CONFIG
            echo -e ""$GREEN"done.$COLOR_END"
            $APACHE_CTL configtest > /dev/null && $APACHE_CTL restart
            ensure_apache_is_running
        fi
        track_event "Substitute" "Disable" "Linking-newtemplates"
        echo -en ""$BLUE"Linking new to template and modules files...$COLOR_END"
        cd $CPANEL_PATH/Whostmgr/ || error "$substitute_error"
        ln -snf Siteapps.pm.no_autotag Siteapps.pm || error "$substitute_error"
        cd $CPANEL_PATH/Cpanel/ || error "$substitute_error"
        ln -snf Siteapps.pm.no_autotag Siteapps.pm || error "$substitute_error"
        cd $SITEAPPS_HTML_TEMPLATES || error "$substitute_error"
        ln -snf siteapps.tmpl.no_autotag siteapps.tmpl || error "$substitute_error"
        echo -e ""$GREEN"done.$COLOR_END"
        track_event "Substitute" "Disable" "Completed"
    else
        error "$substitute_error"
    fi
}
base_version=$(echo "$VERSION" | cut -d- -f1)
new_version=$(echo "$base_version-noautotag")
change_version $new_version

echo -e ""$BLUE"Disabling mod substitute on Apache..."
disable_substitute
echo -e ""$GREEN"mod_substitute is now OFF$COLOR_END"
