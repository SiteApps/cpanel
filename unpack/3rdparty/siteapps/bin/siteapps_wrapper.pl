#!/usr/local/cpanel/3rdparty/bin/perl
# Copyright Siteapps 2013
# All rights Reserved.
use strict;
use warnings;

use Carp;
use IO::Handle;

my $debug = 0;

$SIG{__DIE__} = sub {
    print Dumper( [ "runtime error in siteapps_wrapper.pl: $_[0]: " . Carp::cluck() ] );
    exit;
};

$SIG{ALRM} = sub { die "timeout in " . __FILE__ };
alarm 60;

close STDERR;
open STDERR, '>>', '/usr/local/cpanel/logs/error_log';

use lib '/usr/local/cpanel';

use Whostmgr::Siteapps;
use Whostmgr::SiteappsDB;
use Cpanel::Siteapps;

use Data::Dumper;

$< == 0 or die "I was expecting to be run as root; instead I am $< or $>";

my $module = $ARGV[0];
my $func = $ARGV[1];
my $args = $ARGV[2]; # fuu

#my $module_fn = $module;
#$module_fn =~ s{::}{/}g;  # perl -e '$module = "Cpanel/Siteapps.pm"; require $module;' fails complaining it can't find the module, so just pre-use both modules that RPC methods should actually be called in
#$module_fn .= '.pm';
#require $module_fn;

our $VAR1;
eval $args; # populate $VAR1, but only after loading any module that might contain classes that data gets blessed into

warn "module: $module func: $func args: " . Dumper( $VAR1 ) if $debug;

# save STDOUT, since that's how we communicate our results back to our parent process
open my $saveout, '>&STDOUT' or die $!;
close STDOUT;
open STDOUT, '>>', '/usr/local/cpanel/logs/error_log';

my $code = $module->can($func) or die "siteapps_wrapper.pl: $module does not directly contain a $func function";
my $result = $code->( @$VAR1 );
$result = [ $result ] if ! ref($result) eq 'ARRAY';

warn "  ^--- that returned: " . Dumper( $result ) if $debug;

$saveout->print( Data::Dumper::Dumper( $result ) ); # this is not debugging; this communicates the result of the execution back to our caller

