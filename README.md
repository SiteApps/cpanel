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



Also, there are some useful scripts to help you managing the plugin
located in $CPANEL_PATH/3rdparty/siteapps/scripts :

##### update_credentials.sh: 

Used to inform the API Keys from the command line.
```sh
update_credentials.sh <private_key> <public_key>
```
It accepts 2 optional argments:

   -  -f don't ask for keys confirmation:
```sh
update_credentials.sh <private_key> <public_key> -f
```    
   -  -ff don't ask for keys confirmation and overwrite an existing keys
      file
(credentials file):
```sh
update_credentials.sh <private_key> <public_key> -ff
```



##### turn_off_mod_substitute.sh: 

Turn off globally the "AutoTag" feature.

##### turn_on_mod_substitute.sh: 
Turn on globally the "AutoTag" feature.
#####  link_template_files.sh: 
Link the SiteApps HTML files to all the cPanel templates. It is runned
in the installation time, and should be runned again if you install
aditional cPanel themes.
##### uninstall_siteapps_plugin.sh: 
Remove all the SiteApps plugin files, and unregister the icons. 

```sh
uninstall_siteapps_plugin.sh 
```
It accepts 2 optional argments:

   -  -f remove the credentials (api keys) files:

```sh
uninstall_siteapps_plugin.sh -f
```    
   -  -ff remove the credentials (api keys) and the user's data files:

```sh
uninstall_siteapps_plugin.sh -ff
```
