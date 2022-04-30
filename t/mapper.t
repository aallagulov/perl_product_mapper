use strict;
use warnings;
use feature 'say';

use Test::More;
use Test::Deep;
use Test::Output;
use Data::Dumper;

use FindBin;
use lib "$FindBin::Bin/../lib";

use Mapper;


# some unit tests for a /apply method
{
	my $mapper = Mapper->new(csv => [{
		source => 'winter',
		destination => 'Winter',
		source_type => 'season',
		destination_type => 'season'
	},
	{
		source => 'EU|42',
		destination => 'European size 42',
		source_type => 'size_group_code|size_code',
		destination_type => 'size'
	}]);
	for my $case (
		{
			line => {
				season => 'summer',
				size_group_code => 'EU',
				size_code => '41',
			},
			result => {
				season => 'summer',
				# there is no corresponding mapping
				# and also no instructions on this case
				# so let it be like this
				size => 'EU|41',
			},
		},
		{
			line => {
				season => 'winter',
				size_group_code => 'EU',
				size_code => '42',
			},
			result => {
				season => 'Winter',
				size => 'European size 42',
			},
		},
		{
			line => {
				# all these empty fields will be cleaned up
				season => '',
				empty_not_mapped_column => '',
				size_group_code => '',
				size_code => '',
			},
			result => {
				# there is no corresponding mapping
				# and also no instructions on this case
				# so let it be like this
				size => '|',
			},
		},
	)
	{
		$mapper->apply($case->{line});
		cmp_deeply(
		  $case->{line},
		  $case->{result},
		  "result mapping is ok"
		);
	}
}

done_testing();