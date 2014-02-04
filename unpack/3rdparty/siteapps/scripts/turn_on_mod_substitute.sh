#!/bin/bash 
CPANEL_PATH="/usr/local/cpanel"
SITEAPPS_PATH="$CPANEL_PATH/3rdparty/siteapps"

 . $SITEAPPS_PATH/scripts/functions

function configure_rawopts {

    test -d $RAWOPTS_DIR || mkdir -p $RAWOPTS_DIR
    for apache_version in $SUPPORTED_APACHE_VERSIONS
    do
        echo -en ""$BLUE"Adding rawopts for $apache_version...$COLOR_END"
        f_version="$RAWOPTS_DIR/$apache_version"
        if [ -s $f_version ]; then
            egrep "\-\-enable\-substitute=shared" $f_version > /dev/null || echo "--enable-substitute=shared" >>  $f_version
            continue
        fi
        echo "--enable-substitute=shared" >>  $f_version
        echo -e ""$GREEN"done.$COLOR_END"
    done
}


function configure_custom_opt_mods
{
    echo -en ""$BLUE"Unpacking mod_substitute as custom opt mod...$COLOR_END"
    test -d $CUSTOM_OPT_MOD_DIR || mkdir -p $CUSTOM_OPT_MOD_DIR
    tar --no-overwrite-dir --no-same-owner -zxf $SITEAPPS_PATH/mod_substitute/custom_opt_mods.tar.gz -C $CUSTOM_OPT_MOD_DIR
    echo -e ""$GREEN"done.$COLOR_END"
}



function enable_substitute {
    track_event "Substitute" "Enable" "0"
    substitute_error="Error installing mod_substitute to auto include the SiteApps javascript TAG"
    cd $SITEAPPS_PATH/mod_substitute
    if [ -f $APACHE_CONFIG ]; then
        configure_custom_opt_mods
        already_enabled=`grep "$LOAD_MODULE_LINE" $APACHE_CONFIG | egrep -v "^#" || echo ""`
        if [ "$already_enabled" = "" ]; then
            track_event "Substitute" "Enable" "1"
            echo -e ""$BLUE"Compiling mod_substitute...$COLOR_END"
            if [ -d /home/cpeasyapache/src/httpd-$APACHE_MAJOR_VERSION ]; then
                $APXS -ci /home/cpeasyapache/src/httpd-$APACHE_MAJOR_VERSION/modules/filters/mod_substitute.c > /dev/null
            else
                $APXS -ci mod_substitute.c > /dev/null || error "$substitute_error"
            fi
            echo -e ""$GREEN"done.$COLOR_END"
            echo -e ""$BLUE" Restarting apache...$COLOR_END"
            echo $LOAD_MODULE_LINE >> $APACHE_CONFIG
            $APACHE_CTL configtest > /dev/null && $APACHE_CTL restart
            echo -e ""$GREEN"done.$COLOR_END"
            ensure_apache_is_running
        fi
        track_event "Substitute" "Enable" "2"
        echo -en ""$BLUE"Linking new to template and modules files...$COLOR_END"
        cd $CPANEL_PATH/Whostmgr/ || error "$substitute_error"
        ln -snf Siteapps.pm.autotag Siteapps.pm || error "$substitute_error"
        cd - > /dev/nul
        cd $CPANEL_PATH/Cpanel/ || error "$substitute_error"
        ln -snf Siteapps.pm.autotag Siteapps.pm || error "$substitute_error"
        cd - > /dev/nul
        cd $SITEAPPS_HTML_TEMPLATES || error "$substitute_error"
        ln -snf siteapps.tmpl.autotag siteapps.tmpl || error "$substitute_error"
        cd - > /dev/nul
        echo -e ""$GREEN"done.$COLOR_END"
        track_event "Substitute" "Enable" "3"
    else
        error "$substitute_error"
    fi
}
base_version=$(echo "$VERSION" | cut -d- -f1)
new_version=$(echo "$base_version-autotag")
change_version $new_version
echo -e ""$BLUE"Enabling mod substitute on Apache..."
enable_substitute
echo -e ""$GREEN"mod_substitute is now ON.$COLOR_END"

