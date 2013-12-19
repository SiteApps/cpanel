#!/bin/bash 
CPANEL_PATH="/usr/local/cpanel"
SITEAPPS_PATH="$CPANEL_PATH/3rdparty/siteapps"

 . $SITEAPPS_PATH/scripts/functions


function link_themes_templates {
    cd $CPANEL_PATH/base/frontend
    base_dir="$CPANEL_PATH/base/frontend"
    for destination in $(find $base_dir -maxdepth 1 -mindepth 1 -type d ; find $base_dir -maxdepth 1 -mindepth 1 -type l)
    do
        ln -snf $SITEAPPS_HTML_TEMPLATES/* $destination 2> /dev/null
    done
}

echo -en ""$BLUE"Linking web template files..."
link_themes_templates
echo -e ""$GREEN"done.$COLOR_END"
