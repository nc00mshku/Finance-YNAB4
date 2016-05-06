use warnings;
use strict;
use FindBin qw/$Bin/;
use lib "$Bin/../lib";
use Finance::YNAB4;
use Data::Printer;
my $budget = 'Test~4AC3463B.ynab4';

my $ynab4 = Finance::YNAB4->new(budget_file => $budget);
p $ynab4->budgets;die;
for my $cat (@{$ynab4->categories}) {
    my $master_category = $cat->{name};
    next if ($master_category =~ /(Hidden Categories|__Internal__|Income)/);
    next if ($cat->{isTombstone});
    print "$master_category\n";
    for my $sub_category (@{$cat->{subCategories}}) {
    	next if ($sub_category->{isTombstone});
    	print "\t".$sub_category->{name}."\n";
    }
}
