# SiteApps plugin for cPanel.

First, request a host API key from SiteApps [http://siteapps.com/hosting/become-a-partner] (http://siteapps.com/hosting/become-a-partner).

Then run the following command as root on the server:

`wget -q -O - https://raw.github.com/siteapps/cpanel/master/install_siteapps_cpanel_plugin.sh | bash`

This will install the plugin dependencies and the actual SiteApps plugin.


Now, you will notice the SiteApps option in your WHM Plugin menu.

![SiteApps Plugin](https://stpps.com/369/2.jpg)

Click on the SiteApps link, and paste the host API keys you received from SiteApps (Public and Private).

![API Keys](https://stpps.com/369/1.jpg)

That's it. Now your users will see an new box called SiteApps in cPanel.

Also there are some useful scripts to help you managing the plugin
located in $CPANEL_PATH/3rdparty/siteapps/scripts :

1. update_credentials.sh
 Used to inform the API Keys from the command line.
    update_credentials.sh <private_key> <public_key>
 It accepts 2 optional argments:
 -f don't ask for keys confirmation:
    update_credentials.sh <private_key> <public_key> -f
 -ff don't ask for keys confirmation and overwrite an existing keys file
(credentials file):
    update_credentials.sh <private_key> <public_key> -ff



 turn_off_mod_substitute.sh
 turn_on_mod_substitute.sh
 link_template_files.sh
 uninstall_siteapps_plugin.sh




![SiteApps Icon](https://stpps.com/369/3.jpg)
