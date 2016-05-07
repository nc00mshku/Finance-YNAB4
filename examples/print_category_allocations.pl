use 5.10.0;
use warnings;
use strict;
use FindBin qw/$Bin/;
use lib "$Bin/../lib";
use Finance::YNAB4;

my $budget = 'TEST~517C3803.ynab4';
my $ynab4 = Finance::YNAB4->new(budget_file => $budget);

my $budeted_months = $ynab4->get_budget_ids;

my $budgets = $ynab4->get_budgeted;
for my $b_month (@$budeted_months) {
    print "[$b_month]\n";
    for my $cat_id (keys $budgets->{$b_month}) {
	my $category_name = $ynab4->get_category_name($cat_id);
	next unless $category_name;
	print "\t".join(',',($category_name,$budgets->{$b_month}->{$cat_id}))."\n";
    }
}

