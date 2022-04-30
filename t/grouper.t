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
					brand => 'abibas',
					season => 'Winter',
					size => 'European size 41',
					article_number => 100,
					ean => 101,
				},
				{
					brand => 'abibas',
					season => 'Summer',
					size => 'European size 41',
					article_number => 300,
					ean => 301,
				},
				{
					brand => 'abibas',
					season => 'Winter',
					size => 'European size 42',
					article_number => 100,
					ean => 102,
				},
				{
					brand => 'abibas',
					season => 'Summer',
					size => 'European size 41',
					article_number => 200,
					ean => 201,
				},
				{
					brand => 'abibas',
					season => 'Summer',
					size => 'European size 41',
					article_number => 300,
					ean => 302,
				}
			],
			result => {
				brand => 'abibas',
				articles => {
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
                            },
                        ],
                    },
                    '200' => {
                        season => 'Summer',

                        # there is a corner case if we have only 1 variations
                        # all the fields from it will be article fields

                    	ean => 201,
                    	size => 'European size 41',

                        variations => [
                            {

                            }
                        ],
                    },
                    '300' => {
                        season => 'Summer',
                        size => 'European size 41',
                        variations => [
                        	{
                            	ean => 301,
                            },
                            {
                                ean => 302,
                            },
                        ],
                    },
                },
			},
		},
	)
	{
		my $grouper = Grouper->new(csv => $case->{csv});
		cmp_deeply(
		  $grouper->{grouped_pricat},
		  $case->{result},
		  "result groupping is ok"
		);
	}
}

done_testing();