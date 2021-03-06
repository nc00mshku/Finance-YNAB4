package Finance::YNAB4;

use 5.006;
use strict;
use warnings;
use Moose;
use namespace::autoclean;
use Sort::Naturally;
use JSON;

=head1 NAME

Finance::YNAB4 - YNAB4 detail extraction

=head1 VERSION

Version 0.01

=cut

=head1 SYNOPSIS

Reads/Parses ynab4 json file

    use Finance::YNAB4;

    my $ynab4 = Finance::YNAB4->new(budget_file => 'FILE_PATH');

    my @categories = $ynab4->categories;

=cut

our $VERSION = '0.01';

has 'budget_file', is => 'ro', isa => 'Str', required => 1;

=head2 RAW_DATA

    read only accessors to raw imported JSON data:

    accounts => 'ArrayRef'
    categories => 'ArrayRef'
    budgets => 'ArrayRef'

=cut
    
has 'accounts', is => 'ro', isa => 'ArrayRef', writer => 'store_accounts';
has 'categories', is => 'ro', isa => 'ArrayRef', writer => 'store_categories';
has 'budgets', is => 'ro', isa => 'ArrayRef', writer => 'store_budgets';

has '__budgeted', is => 'ro', isa => 'HashRef', builder => '__get_budgeted', lazy => 1, reader => 'get_budgeted';
has '__categories', is => 'ro', isa => 'HashRef', builder=> '__get_categories', lazy => 1, reader => 'get_categories';

sub BUILD {
    my $self = shift;
    $self->parse_budget;
}

=head1 SUBROUTINES/METHODS

=head2 get_categories

    return array of category names

    { allow_hidden => 0,
      allow_deleted => 0,
      allow_internal => 0,  # older budget files include __INTERNAL__ categories which aren't part of actual budget
    }

=cut
sub __get_categories {
    my ( $self, $attrs ) = @_;

    my @exclude = ();
    push @exclude, 'Hidden Categories' unless ($attrs->{allow_hidden});
    push @exclude, '__Internal__|Income' unless ($attrs->{allow_internal});
    my $re_skip = '('.join('|',@exclude).')';

    my $cat_hr = {};
    for my $cat (@{$self->categories}) {
	my $master_category = $cat->{name};
	my $master_entity = $cat->{entityId};
	next if ($master_category =~ qr/$re_skip/);
	next if ($cat->{isTombstone} && !$attrs->{allow_deleted});
	$cat_hr->{$master_entity}->{name} = $master_category;
	for my $sub_category (@{$cat->{subCategories}}) {
	    my $sub_cat_name = $sub_category->{name};
	    next if ($sub_category->{isTombstone} && !$attrs->{allow_deleted});
	    my $sub_hash = { name => $sub_cat_name,
			     masterEntityId => $master_entity,
	    };
	    $cat_hr->{$sub_category->{entityId}} = $sub_hash;
	}
    }
    return $cat_hr;
}

=head2 parse_budet
    
    read and store details from y4 json file

=cut
sub parse_budget {
    my $self = shift;
    
    my $ynab_budget_dir = $self->budget_file;
    my @data_folders = nsort glob "$ynab_budget_dir/data*";
    my $ynab4_dir = pop @data_folders;
    my $data_file_name = '/*/Budget.yfull';
    my @files = nsort glob "$ynab4_dir".$data_file_name;
    my $budget_file = pop @files;

    my $budget_data;
    {
        local $/;
        open  my $fh, "<", $budget_file or die "could not open $budget_file: $!";
        $budget_data = <$fh>;
    }

    my $budget = decode_json $budget_data;

    $self->store_accounts($budget->{accounts});
    $self->store_categories($budget->{masterCategories});
    $self->store_budgets($budget->{monthlyBudgets});
}

=head2 get_budget_ids
    
    keys for budget data - includes month as part of keyname

=cut
sub get_budget_ids {
    my $self = shift;
    return [sort keys %{$self->get_budgeted}];
}

=head2 get_category_name

    return name for a given category id

=cut
sub get_category_name {
    my $self = shift;
    my $id = shift;
    
    return $self->get_categories()->{$id}->{name};    
}

=head2 __get_budgeted

    extract budgeted category ammounts

=cut
sub __get_budgeted {
    my $self = shift;

    my $budgeted_hr = {};
    for my $budget (@{$self->budgets}) {
	my $mb_id = $budget->{entityId};
	my $subs = $budget->{monthlySubCategoryBudgets};
	next unless $subs;
	for my $sub_cat (@$subs) {
	    my $mcb_id = $sub_cat->{entityId};
	    my $budgeted = $sub_cat->{budgeted};
	    my $cat_id = $sub_cat->{categoryId};
	    $budgeted_hr->{$mcb_id}->{$cat_id} = $budgeted;
	}
    }
    return $budgeted_hr;
}




1;

=head1 AUTHOR

nc00mshku, C<< <nc00mshku at pastywhitesoftware.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-finance-ynab4 at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Finance-YNAB4>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Finance::YNAB4


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Finance-YNAB4>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Finance-YNAB4>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Finance-YNAB4>

=item * Search CPAN

L<http://search.cpan.org/dist/Finance-YNAB4/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2016 nc00mshku.

This program is free software; you can redistribute it and/or modify it
under the terms of the the Artistic License (2.0). You may obtain a
copy of the full license at:

L<http://www.perlfoundation.org/artistic_license_2_0>

Any use, modification, and distribution of the Standard or Modified
Versions is governed by this Artistic License. By using, modifying or
distributing the Package, you accept this license. Do not use, modify,
or distribute the Package, if you do not accept this license.

If your Modified Version has been derived from a Modified Version made
by someone other than you, you are nevertheless required to ensure that
your Modified Version complies with the requirements of this license.

This license does not grant you the right to use any trademark, service
mark, tradename, or logo of the Copyright Holder.

This license includes the non-exclusive, worldwide, free-of-charge
patent license to make, have made, use, offer to sell, sell, import and
otherwise transfer the Package with respect to any patent claims
licensable by the Copyright Holder that are necessarily infringed by the
Package. If you institute patent litigation (including a cross-claim or
counterclaim) against any party alleging that the Package constitutes
direct or contributory patent infringement, then this Artistic License
to you shall terminate on the date that such litigation is filed.

Disclaimer of Warranty: THE PACKAGE IS PROVIDED BY THE COPYRIGHT HOLDER
AND CONTRIBUTORS "AS IS' AND WITHOUT ANY EXPRESS OR IMPLIED WARRANTIES.
THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
PURPOSE, OR NON-INFRINGEMENT ARE DISCLAIMED TO THE EXTENT PERMITTED BY
YOUR LOCAL LAW. UNLESS REQUIRED BY LAW, NO COPYRIGHT HOLDER OR
CONTRIBUTOR WILL BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, OR
CONSEQUENTIAL DAMAGES ARISING IN ANY WAY OUT OF THE USE OF THE PACKAGE,
EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


=cut

1; # End of Finance::YNAB4
