#!/usr/local/cpanel/3rdparty/bin/perl


# Copyright eNom 2013
# All rights Reserved.

# targets the restricted cPanel perl environment, which is an antique perl and lacks most of the standard modules
# temporarily using this directly from the cPanel side API extensions


package Whostmgr::SiteappsTools;

sub is_sanitized {
    my $arg = shift;
    if ($arg =~ /^[a-zA-Z[0-9][a-zA-Z0-9\-:_\@\.]{0,64}$/)                                                                          
        { return 1; }
    return 0;

}
sub are_args_sanitized {

    my @args =  $_[0];
    foreach my $arg (@args) {
        if(!Whostmgr::SiteappsTools::is_sanitized($arg))
        {
            warn "Argment contains special chars: " . $arg;
            return 0;
        }
    }
    return 1;
}
1;
