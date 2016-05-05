#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

plan tests => 1;

BEGIN {
    use_ok( 'Finance::YNAB4' ) || print "Bail out!\n";
}

diag( "Testing Finance::YNAB4 $Finance::YNAB4::VERSION, Perl $], $^X" );
