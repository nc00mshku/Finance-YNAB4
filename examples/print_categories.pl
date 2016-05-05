use warnings;
use strict;
use FindBin qw/$Bin/;
use lib "$Bin/../lib";
use Finance::YNAB4;

my $budget = 'd:/files/finances/ynab_dropbox/Dropbox/YNAB/BDGT_Master_FR~D921BABD.ynab4';

my $ynab4 = Finance::YNAB4->new(budget_file => $budget);

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
