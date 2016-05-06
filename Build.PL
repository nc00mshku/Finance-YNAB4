use 5.006;
use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'Finance::YNAB4',
    license             => 'artistic_2',
    dist_author         => q{nc00mshku <nc00mshku@pastywhitesoftware.com>},
    dist_version_from   => 'lib/Finance/YNAB4.pm',
    release_status      => 'stable',
    configure_requires => {
        'Module::Build' => 0,
    },
    build_requires => {
        'Test::More' => 0,
    },
    requires => {
	'Moose' => 2.0,
	'Sort::Naturally' => 1.03,
	'JSON' => 2.25,
    },
    add_to_cleanup     => [ 'Finance-YNAB4-*' ],
    create_makefile_pl => 'traditional',
);

$builder->create_build_script();
