# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl WWW-PageSpeed.t'

#########################

use Test::More tests => 1;
BEGIN { use_ok('WWW::PageSpeed') };

#########################

my $key = $ENV{PAGESPEED_APIKEY} || 'Need a Key';
my $ps = new WWW::PageSpeed(key => $key);
