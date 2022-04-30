#!/usr/bin/perl

use strict;
use warnings;
use feature 'say';

use Getopt::Long;
use Pod::Usage;
use Text::CSV_XS;
use JSON::XS;
use Data::Dumper;

main();

sub main {
	my ($pricat_file, $mappings_file) = get_opts();

	my $pricat   = parse_csv($pricat_file);
	my $mappings = parse_csv($mappings_file);

	my $new_mappings = simplify_mappings($mappings);

	apply_mappings($pricat, $new_mappings);
	my $grouped_pricat = group_pricat($pricat);

	my $json_serializer = JSON::XS->new();
	$json_serializer->canonical([1]);
	$json_serializer->pretty([1]);
 say $json_serializer->encode($grouped_pricat);
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

		for my $column (keys %$line) {
			delete $line->{$column} unless $line->{$column};
		}
	}
}

sub group_pricat {
	my ($pricat) = @_;

	my $grouped_pricat = {};
	for my $line (@$pricat) {
		my $article_number = delete $line->{article_number};

		my $articles = ($grouped_pricat->{articles} //= {});
		my $article = ($articles->{$article_number} //= {variations => []});
		push @{$article->{variations}}, $line;
	}

	# moving common attribute from variations to atricles
	for my $article (values %{$grouped_pricat->{articles}}) {
		my $different_values_per_column = {};

		my $variations = $article->{variations};
		for my $variation (@$variations) {
			for my $column (keys %$variation) {
				my $value = $variation->{$column};
				$different_values_per_column->{$column}{$value} = 1;
			}
		}

		for my $column (keys %$different_values_per_column) {
			if (scalar (keys %{$different_values_per_column->{$column}}) > 1) {
				delete $different_values_per_column->{$column};
			}
		}

		for my $variation (@$variations) {
			for my $column (keys %$variation) {
				if ($different_values_per_column->{$column}) {
					delete $variation->{$column};
				}
			}
		}

		for my $column (keys %$different_values_per_column) {
			$article->{$column} = (keys %{$different_values_per_column->{$column}})[0];
		}
	}

	# moving common attribute from articles to brands
	my $different_values_per_column = {};
	for my $article (values %{$grouped_pricat->{articles}}) {
		for my $column (keys %$article) {
			next if $column eq 'variations';
			my $value = $article->{$column};
			$different_values_per_column->{$column}{$value} = 1;
		}
	}

	for my $column (keys %$different_values_per_column) {
		if (scalar (keys %{$different_values_per_column->{$column}}) > 1) {
			delete $different_values_per_column->{$column};
		}
	}

	for my $article (values %{$grouped_pricat->{articles}}) {
		for my $column (keys %$article) {
			if ($different_values_per_column->{$column}) {
				delete $article->{$column};
			}
		}
	}

	for my $column (keys %$different_values_per_column) {
		$grouped_pricat->{$column} = (keys %{$different_values_per_column->{$column}})[0];
	}

	return $grouped_pricat;
}

1;