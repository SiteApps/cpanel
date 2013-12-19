#!/usr/local/cpanel/3rdparty/bin/perl

# Copyright Siteapps 2013
# All rights Reserved.


use strict;
use warnings;

use lib '/usr/local/cpanel';

use Whostmgr::Siteapps;
use Whostmgr::SiteappsDB;

use CGI                        ();
use List::MoreUtils 'zip';
use JSON::PP;
use Data::Dumper;

use Whostmgr::HTMLInterface    ();
use Whostmgr::ACLS             ();

use Cpanel::Config ();
use Cpanel::AcctUtils ();
use Cpanel::Sys ();

# $Cpanel::App::appname = 'addon_siteapps.cgi'; # XXX is this necessary for whostmgr stuff?

# only root may execute this

Whostmgr::ACLS::init_acls();

if ( ! Whostmgr::ACLS::checkacl( 'all' ) ) {
    # not root or effectively root
    print 'Access Denied.';
    exit;
}

#
#
#

$| = 1;

my $debug = 0;

print "Content-type: text/html\r\n\r\n";

Whostmgr::HTMLInterface::defheader( "SiteApps", '', '/cgi/addon_siteapps.cgi' );

#
#
#

my $auth_data = Whostmgr::SiteappsDB::read_auth_data();

my $activated = 0;   # form data submitted and the login info in it is correct

my $submitted = CGI::param('submit') ? 1 : 0;

my $error_message = '';

if( $submitted ) {

    my $updated = 0;

    for my $field ( Whostmgr::SiteappsDB::auth_data_fields ) {
        if( defined CGI::param($field) ) {
            my $value = CGI::param($field);
            if( $field eq 'public_key' and $value !~ m/^\w+$/ ) {
                 $error_message .= qq{Please enter a valid value for the "Public Key" field.<br>};
            } elsif( $field eq 'private_key' and $value !~ m/^\w+$/i ) {
                 $error_message .= qq{Please enter a valid value for the "Private Key" field.<br>};
            } elsif( $field eq 'billing_url' and $value !~ m{^http(s?)://} ) {
                $error_message .= qq{Please enter a valid value for the "Billing URL" field.  It should start with <tt>http://</tt> or <tt>https://</tt><br>};
            } else {
                $updated = 1;
                $auth_data->{$field} = $value;
            }
        }
    }

    Whostmgr::SiteappsDB::write_auth_data( $auth_data ) if $updated;

}

my $all_fields = 1;
$all_fields = 0 if grep ! defined $auth_data->{ $_ }, Whostmgr::SiteappsDB::auth_data_fields;
# print "<br clear='all'>\nmissing fields: " . join ', ', grep ! defined $auth_data->{ $_ }, Whostmgr::SiteappsDB::auth_data_fields;

if( $submitted and $all_fields ) {

    my $check_login = Whostmgr::Siteapps::getActivePlans();

    # print "<pre>" . Dumper($check_login) . "</pre>";
    if( $check_login->{response} and $check_login->{response} =~ m/AuthorizationException/ ) {
        # this returns a wrapper on HTTP failure, and bad credentials generates an HTTP 400 response.
        # the actual JSON response isn't decoded in that case, but is returned with the raw headers/body in the "response" field.
        # so, that's why I'm regex matching that here.
        $error_message .= 'Please check your public and private keys and try again.';
    } elsif( $check_login->{error} ) {
        $error_message .= ' ' . $check_login->{error}; # something cryptic like "non-100 status code from siteapps.com: ..." but show it anyway, as a fallback
    }

    if( $error_message ) {

        $activated = 0; # flop back to 'Activate' message for submit button rather than 'Update'

    } else {

        $activated = 1;

    }

} elsif( $all_fields ) {

    my $check_login = Whostmgr::Siteapps::getActivePlans();
    $activated = 1 unless $check_login->{error};

}

$auth_data->{active} = $activated;
$auth_data->{billing_url} ||= 'http://',
Whostmgr::SiteappsDB::write_auth_data( $auth_data );

# print "<br clear='all'>\n error_message => ``$error_message'' activated = ``$activated'' submitted = ``$submitted' all_fields = ``$all_fields''\n";

Cpanel::Template::process_template(
    'whostmgr',
    {
        template_file => 'siteapps.tmpl',
        data          => {
            %$auth_data, 
            login_incorrect => length($error_message) ? 1 : 0,
            error_message => $error_message,
            activated => $activated,
            submitted => $submitted,
        },
    },
);


