#!/usr/bin/perl

use strict;
use warnings;
use feature 'say';

use Getopt::Long;
use Pod::Usage;
use Text::CSV_XS;
use Data::Dumper;

main();

sub main {
	my ($pricat_file, $mappings_file) = get_opts();

	my $pricat   = parse_csv($pricat_file);
	my $mappings = parse_csv($mappings_file);

	my $new_mappings = simplify_mappings($mappings);

	apply_mappings($pricat, $new_mappings);
	group_pricat($pricat);
# say Dumper ($pricat);
}


sub get_opts {
	my ($pricat_file, $mappings_file) = ('', '');

	GetOptions(
	    'pricat_file=s' => \$pricat_file,
	    'mappings_file=s' => \$mappings_file,
	);
	$pricat_file or pod2usage("Please specify (-p|--pricat_file) to work with\n");
	-e $pricat_file or pod2usage("$pricat_file destination is incorrect\n");
	$mappings_file or pod2usage("Please specify (-m|--mappings_file) to work with\n");
	-e $mappings_file or pod2usage("$mappings_file destination is incorrect\n");

	return ($pricat_file, $mappings_file);
}

sub parse_csv {
	my ($file) = @_;

	my $csv = Text::CSV_XS->new ({ binary => 1, auto_diag => 1, sep_char => ";" });
	open my $fh, "<:encoding(utf8)", $file or die "$file: $!";
	$csv->header($fh);

	my $parsed_csv = $csv->getline_hr_all($fh);
	return $parsed_csv;
}

sub simplify_mappings {
	my ($mappings) = @_;

	my $new_mappings = {};
	for my $mapping (@$mappings) {
		$new_mappings->{$mapping->{source_type}}{destination_type} = $mapping->{destination_type};
		$new_mappings->{$mapping->{source_type}}{replace}{$mapping->{source}} = $mapping->{destination};
	}

	return $new_mappings;
}

sub apply_mappings {
	my ($pricat, $mappings) = @_;

	for my $line (@$pricat) {
		for my $from (keys %$mappings) {
			my @from_fields = split(/\|/, $from);

			my $mapping = $mappings->{$from};
			my $rules = $mapping->{replace};

			my @initial_values;
			for my $from_field (@from_fields) {
				push @initial_values, delete $line->{$from_field};
			}
			my $initial_string = join('|', @initial_values);
			my $final_string = $rules->{$initial_string};
			$line->{$mapping->{destination_type}} = $final_string;
		}
	}
}

sub group_pricat {
	my ($pricat) = @_;

	my $grouped_pricat = {};
	for my $line (@$pricat) {
		# my $brand = delete $line->{brand};
		my $article_number = delete $line->{article_number};
		# my $ean = delete $line->{ean};

		my $articles = ($grouped_pricat->{articles} //= {});
		my $article = ($articles->{$article_number} //= {variations => []});
		push @{$article->{variations}}, $line;

	}

	say Dumper ($grouped_pricat);

}

1;