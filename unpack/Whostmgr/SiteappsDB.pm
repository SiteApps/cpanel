#!/usr/local/cpanel/3rdparty/bin/perl 

# Copyright SiteApps 2013
# All rights Reserved.

# targets the restricted cPanel perl environment, which is an antique perl and lacks most of the standard modules
# temporarily using this directly from the cPanel side API extensions

package Whostmgr::SiteappsDB;


use strict;
use warnings;

use vars '$debug';
$debug = 1;

BEGIN { push @INC, '/usr/local/cpanel' };

use Whostmgr::SiteappsTools;
use Scalar::Util qw(looks_like_number);
use Text::CSV_PP;
use Data::Dumper;

my $auth_filename = '/var/cpanel/siteapps/credentials';
my $users_filename = '/var/cpanel/siteapps/users';
my $plan_filename_base = '/var/cpanel/siteapps/plan_data_';

#
#
#

# adapted from List::MoreUtils:

sub zip (\@\@;\@\@\@\@\@\@\@\@\@\@\@\@\@\@\@\@\@\@\@\@\@\@\@\@\@\@\@\@\@\@) {
    my $max = -1;
    $max < $#$_ && ( $max = $#$_ ) foreach @_;
    map {
        my $ix = $_;
        map $_->[$ix], @_;
    } 0 .. $max;
}

#
#
#

sub _setup {
    return if -d '/var/cpanel/siteapps';
    my $old_umask = umask;
    umask 0077;
    mkdir '/var/cpanel/siteapps';
    umask $old_umask;
}

sub _create_file {
    my $fn = shift;

    # new empty file
    my $old_umask = umask;
    umask 0677;
    open my $fh, '>', $fn or die "$!: $fn; I am $< aka $>";
    close $fh;
    umask $old_umask;

    1;
}

sub _read_csv_data {
    my $filename = shift;

    _setup();

    my $csv = Text::CSV_PP->new({ binary => 1, eol => "\015\012" }) or die Text::CSV_PP->error_diag;

    open my $fh, '<', $filename or die $!;
    flock $fh, 2;
    my $header = $csv->getline( $fh );  @$header or die;
    my $data = $csv->getline( $fh );    @$data or die;
    close $fh;

    return { zip @$header, @$data };
}

sub _write_csv_data {
    my $filename = shift;
    my $data = shift;  ref $data or die;

    _setup();

    -f $filename or _create_file( $filename );

    my $csv = Text::CSV_PP->new({ binary => 1, eol => "\015\012" }) or die Text::CSV_PP->error_diag;

    my @keys = keys %$data;
    my @values = map $data->{ $_ }, @keys;

    # return if ! grep $_, @values; # don't write anything if there is no data to write # XXX

    open my $fh, '>>', $filename or die $!;
    flock $fh, 2;
    seek $fh, 0, 0 or die $!;
    truncate $fh, 0;
    chmod 0600, $filename or die "chmod 0600 $filename: $!";
    $csv->print( $fh, \@keys );
    $csv->print( $fh, \@values );
    close $fh;
}

sub _read_csv_data_multi {
    my $filename = shift;

    _setup();

    -f $filename or _create_file( $filename );

    my $csv = Text::CSV_PP->new({ binary => 1, eol => "\015\012" }) or die Text::CSV_PP->error_diag;

    my @records;

    if( -s $filename ) {
        open my $fh, '<', $filename or die $!;
        flock $fh, 2;
        my $header = $csv->getline( $fh );
        while( my $data = $csv->getline( $fh ) ) {
            # push @records, bless { zip @$header, @$data }, 'siteapps_plan';
            push @records, { zip @$header, @$data };
        }
        close $fh;
    }

    return \@records;

}

sub _write_csv_data_multi {

    my $filename = shift;
    my $fields = shift;
    my $items = shift;

    _setup();

    -f $filename or _create_file( $filename );

    my $csv = Text::CSV_PP->new({ binary => 1, eol => "\015\012" }) or die Text::CSV_PP->error_diag;

    open my $fh, '>>', $filename or die $!;

    flock $fh, 2;
    seek $fh, 0, 0 or die $!;
    truncate $fh, 0;
    chmod 0600, $filename or die "chmod 0600 $filename: $!";

    $csv->print( $fh, $fields );

    for my $record ( @$items ) {
        my @values = map $record->{ $_ }, @$fields;
        $csv->print( $fh, \@values );
    }

    close $fh;

    return 1;

}


#
# read and write site-wide siteapps auth data
#

# sub auth_data_fields { return qw/ public_key private_key billing_url / }; # XXX next version:  re-add billing_url or some variation of it
sub auth_data_fields { return qw/ public_key private_key / };

sub read_auth_data {


    _setup();

    my $csv = Text::CSV_PP->new({ binary => 1, eol => "\015\012" }) or die Text::CSV_PP->error_diag;

    if( -s $auth_filename ) {
        return _read_csv_data( $auth_filename );
    }

    # new blank record

    return { };

}

sub write_auth_data {

    my $auth_data = shift;

    _setup();

    _write_csv_data( $auth_filename, $auth_data, );

    return 1;
}

#
# read and write user information
#

sub users_data_fields { return qw/ user_id username user_key / };

sub read_users_data {


    if( -s $users_filename ) {
        return _read_csv_data_multi( $users_filename );
    }

    # no records

    return [ ];

}

sub write_users_data {

    my $users_data = shift;

    _write_csv_data_multi( $users_filename, [ users_data_fields() ], $users_data );

}

sub insert_user {


    my $data = shift;
    exists $data->{user_id} or die;
    looks_like_number(($data->{user_id})) or die;
    exists $data->{username} or die;
    Whostmgr::SiteappsTools::is_sanitized($data->{username}) or die;
    exists $data->{user_key} or die;

    my $users = read_users_data( );
    push @$users, $data;
    write_users_data( $users );
    return 1;

}

sub read_user_data {

    my $username = shift;
    Whostmgr::SiteappsTools::is_sanitized($username) or die;

    if( -s $users_filename ) {
        my $records = _read_csv_data_multi( $users_filename );
        (my $user) = grep $_->{username} eq $username, @$records;
        return $user;
    }

    # no records

    return [ ];
}

#
# read and write per-cpanel user's domains are registered with site apps 
#

sub plan_fields { return qw/ domain_name plan_id site_id site_key / };

sub read_plan_data {

    my $username = shift() or die;
    Whostmgr::SiteappsTools::is_sanitized($username) or die;
    my $plan_filename = $plan_filename_base . $username;

    if( -s $plan_filename ) {
        return _read_csv_data_multi( $plan_filename );
    }

    return [ ];
}

sub write_plan_data {

    my $username = shift() or die;
    Whostmgr::SiteappsTools::is_sanitized($username) or die;
    my $domains_and_plans = shift() or die;

    my $plan_filename = $plan_filename_base . $username;

    return _write_csv_data_multi( $plan_filename, [ plan_fields() ], $domains_and_plans );

}

# list all site_ids belonging to a given username

sub list_site_ids {

    my $username = shift() or die;
    my $domains_and_plans = read_plan_data( $username );
    (my @site_ids) = map $_->{site_id}, @$domains_and_plans;
    return \@site_ids;
}

# return just one record

sub get_plan {

    my $username = shift() or die;
    my $site_id = shift() or die;
    my $domains_and_plans = read_plan_data( $username );
    (my $record) = grep $_->{site_id} == $site_id, @$domains_and_plans;
    $record or return;
    return $record;
}

# update just one record

sub update_plan {

    my $username = shift() or die;
    my $data = shift() or die;

    my $site_id = $data->{site_id} or die;

    my $domains_and_plans = read_plan_data( $username );
    (my $record) = grep $_->{site_id} == $site_id, @$domains_and_plans;
    $record or return;

    for my $key (keys %$data) {
        exists $record->{$key} or die "don't know about field ``$key''";
        $record->{$key} = $data->{$key};
    }

    write_plan_data( $username, $domains_and_plans );

    return 1;

}

# insert a new record

sub insert_plan {

    my $username = shift() or die;

    my $data = shift;
    exists $data->{site_id} or die;

    my $domains_and_plans = read_plan_data( $username );

    (my $record) = grep $_->{site_id} == $data->{site_id}, @$domains_and_plans;
    # $record and warn "record for site_id $data->{site_id} already exists: " . Dumper( $record ) . " in " . Dumper( $domains_and_plans );
    return if $record;

    push @$domains_and_plans, $data;

    write_plan_data( $username, $domains_and_plans );
    return 1;

}

1;
