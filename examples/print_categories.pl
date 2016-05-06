use warnings;
use strict;
use FindBin qw/$Bin/;
use lib "$Bin/../lib";
use Finance::YNAB4;

my $budget = 'TEST~517C3803.ynab4';

my $ynab4 = Finance::YNAB4->new(budget_file => $budget);

my $categories = $ynab4->get_categories({allow_hidden=>0});

for my $cat (keys %{$categories}) {
    print "$cat|".$categories->{$cat}->{name}."\n";
    for my $sub_cat (@{$categories->{$cat}->{sub_cats}}) {
	print "\t".$sub_cat->{entityId}."|".$sub_cat->{name}."\n";
    }
}
