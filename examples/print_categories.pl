use 5.10.0;
use warnings;
use strict;
use FindBin qw/$Bin/;
use lib "$Bin/../lib";
use Finance::YNAB4;

my $budget = 'TEST~517C3803.ynab4';

my $ynab4 = Finance::YNAB4->new(budget_file => $budget);

my $categories = $ynab4->get_categories;

for my $cat_id (keys %{$categories}) {
    my $cat = $categories->{$cat_id};
    next unless ($cat->{masterEntityId});
    print join('|',($ynab4->get_category_name($cat->{masterEntityId}),$ynab4->get_category_name($cat_id)))."\n";
}
