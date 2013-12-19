#!/usr/local/cpanel/3rdparty/bin/perl


# Copyright eNom 2013
# All rights Reserved.

# targets the restricted cPanel perl environment, which is an antique perl and lacks most of the standard modules
# temporarily using this directly from the cPanel side API extensions

package Whostmgr::SiteappsTAG;

use Whostmgr::SiteappsTools;
use Scalar::Util qw(looks_like_number);

use strict;
use warnings;

use vars '$debug';
$debug = 1;

BEGIN { push @INC, '/usr/local/cpanel' };

use File::Path qw(make_path remove_tree);

my $apache_conf_dir = '/usr/local/apache/conf/userdata/std/2/';
my $siteapps_vh_conf = 'siteapps_tag.conf';
open(my $version_file, '<', '/usr/local/cpanel/3rdparty/siteapps/version')  or die "Unable to open version file, $!";
our $plugin_version;
while (<$version_file>)
{
    chomp;
    $plugin_version = $_;
}
$plugin_version = $plugin_version . '-autotag';
#
#
#


sub _create_file {
    my $fn = shift;

    # new empty file
    my $old_umask = umask;
    umask 0022;
    open my $fh, '>', $fn or die "$!: $fn; I am $< aka $>";
    close $fh;
    umask $old_umask;

    1;
}


sub insert_tag {

    my $data = shift;
    exists $data->{username} or die;
    Whostmgr::SiteappsTools::is_sanitized($data->{username}) or die;
    exists $data->{site_id} or die;;
    looks_like_number($data->{site_id}) or die;
    exists $data->{site_url} or die;
    Whostmgr::SiteappsTools::is_sanitized($data->{site_url}) or die;
    my $conf_dir = $apache_conf_dir . $data->{username} . '/' . $data->{site_url};
    make_path($conf_dir);

    my $tag_config = "<IfModule mod_substitute.c>\nAddOutputFilterByType SUBSTITUTE text/html\n Substitute 's|</head>|<script type=\"text/javascript\">\$SA = {s:" . $data->{site_id} . ", tag_info: ". $plugin_version .", asynch: 1, useBlacklistUrl: 1};(function() {   var sa = document.createElement(\"script\");   sa.type = \"text/javascript\";   sa.async = true;   sa.src = (\"https:\" == document.location.protocol ? \"https://\" + \$SA.s + \".sa\" : \"http://\" + \$SA.s + \".a\") + \".siteapps.com/\" + \$SA.s + \".js\";   var t = document.getElementsByTagName(\"script\")[0];   t.parentNode.insertBefore(sa, t);})();</script></head>|i'\n</IfModule>";

    my $filename = $conf_dir . '/' . $siteapps_vh_conf;
    -e $filename and remove_tree($filename);
    _create_file( $filename );

    open (FH, '>' . $filename) or die;
    print FH $tag_config;
    close (FH);

    system("/usr/local/cpanel/scripts/ensure_vhost_includes", "--user=" . $data->{username}, "--domain=" . $data->{site_url}) == 0 or die;
}

sub remove_tag {

    my $data = shift;
    exists $data->{username} or die;
    Whostmgr::SiteappsTools::is_sanitized($data->{username}) or die;
    exists $data->{site_url} or die;;
    Whostmgr::SiteappsTools::is_sanitized($data->{site_url}) or die;
    my $conf_file = $apache_conf_dir . $data->{username} . '/' . $data->{site_url} . '/'. $siteapps_vh_conf;
    -e $conf_file and remove_tree($conf_file);

    system("/usr/local/cpanel/scripts/ensure_vhost_includes", "--user=" . $data->{username}) == 0 or die;
}

sub is_tag_installed {

    my $data = shift;
    exists $data->{username} or die;
    Whostmgr::SiteappsTools::is_sanitized($data->{username}) or die;
    exists $data->{site_url} or die;;
    Whostmgr::SiteappsTools::is_sanitized($data->{site_url}) or die;
    my $conf_file = $apache_conf_dir . $data->{username} . '/' . $data->{site_url} . '/'. $siteapps_vh_conf;
    -e $conf_file and return 1;
    return 0;
}




1;
