# SiteApps plugin for cPanel.

First, request a host API key from SiteApps [https://siteapps.com/hosting/cpanel] (https://siteapps.com/hosting/cpanel).

Then run the following command as root on the server:

`wget -q -O - https://raw.github.com/siteapps/cpanel/master/install_siteapps_cpanel_plugin.sh | bash`

This will install the plugin dependencies and the actual SiteApps plugin.


Now, you will notice the SiteApps option in your WHM Plugin menu.

![SiteApps Plugin](https://stpps.com/369/2.jpg)

Click on the SiteApps link, and paste the host API keys you received from SiteApps (Public and Private).

![API Keys](https://stpps.com/369/1.jpg)

That's it. Now your users will see an SiteApps icon in the
Software/Services box in cPanel.


![SiteApps Icon](https://stpps.com/369/3.jpg)
