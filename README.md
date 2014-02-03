# SiteApps plugin for cPanel.

First, request a host API key from SiteApps
[http://siteapps.com/hosting/become-a-partner]
(http://siteapps.com/hosting/become-a-partner).

Then run the following command as root on the server:

`wget -q -O -
https://raw.github.com/siteapps/cpanel/master/install_siteapps_cpanel_plugin.sh
| bash`

This will install the plugin dependencies and the actual SiteApps
plugin.


Now, you will notice the SiteApps option in your WHM Plugin menu.

![SiteApps Plugin](https://stpps.com/369/2.jpg)

Click on the SiteApps link, and paste the host API keys you received
from SiteApps (Public and Private).

![API Keys](https://stpps.com/369/1.jpg)

That's it. Now your users will see an new box called SiteApps in cPanel.

![SiteApps Icon](https://stpps.com/369/3.jpg)



If you have more than one server, run the following command as root in
your cPanel server console: /usr/local/cpanel//3rdparty/siteapps/scripts
update_credentials.sh <<private_key>> <<public_key>> -ff

This and other [useful scripts](http://support.siteapps.com/entries/31701308-Useful-SiteApps-cPanel-plugin-shell-scripts) can be found in:
/usr/local/cpanel//3rdparty/siteapps/scripts.
