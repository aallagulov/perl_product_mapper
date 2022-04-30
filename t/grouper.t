use strict;
use warnings;
use feature 'say';

use Test::More;
use Test::Deep;
use Test::Output;
use Data::Dumper;

use FindBin;
use lib "$FindBin::Bin/../lib";

use Grouper;


# some unit tests for a /_distinguish_articles method
{


	for my $case (
		{
			csv => [{
				season => 'Winter',
				size => 'European size 41',
				article_number => 100,
				ean => 101,
			},
			{
				season => 'Winter',
				size => 'European size 42',
				article_number => 100,
				ean => 102,
			},
			{
				season => 'Summer',
				size => 'European size 41',
				article_number => 200,
				ean => 201,
			}],
			result => {
				articles => {
                    '200' => {
                        season => 'Summer',
                        variations => [
                            {
                            	ean => 201,
                            	size => 'European size 41',
                            }
                        ],
                    },
                    '100' => {
                    	season => 'Winter',
                        variations => [
                            {
                            	ean => 101,
                                size => 'European size 41',
                            },
                            {
                                ean => 102,
                                size => 'European size 42',
                            }
                        ],
                    }
                },
			},
		},
	)
	{
		my $grouper = Grouper->new(csv => $case->{csv});
		$grouper->group_pricat();
		cmp_deeply(
		  $grouper->{grouped_pricat},
		  $case->{result},
		  "result mapping is ok"
		);
	}
}

done_testing();