#!/usr/bin/perl

use strict;
use warnings;
use feature 'say';

use Getopt::Long;
use Pod::Usage;
use Text::CSV_XS;
use Data::Dumper;

use lib './lib';
use Mapper;
use Grouper;

main();

sub main {
	my $options = get_opts();

	my $csv_mappings = parse_csv(
		$options->{mappings_file}
	);
	my $mapper = Mapper->new(csv => $csv_mappings);

	my $csv_pricat = parse_csv($options->{pricat_file});
	for my $line (@$csv_pricat) {
	    $mapper->apply($line);
	}

	my $grouper = Grouper->new(
		csv           => $csv_pricat,
		pretty_output => $options->{pretty_output},
		sorted_output => $options->{sorted_output},
	);
	say $grouper->return_json();
}


sub get_opts {
	my $options = {
		pretty_output => 0,
		sorted_output => 0,
	};

	GetOptions(
	    'pricat_file=s' => \$options->{pricat_file},
	    'mappings_file=s' => \$options->{mappings_file},
	    'pretty_output' => \$options->{pretty_output},
	    'sorted_output' => \$options->{sorted_output},
	);
	$options->{pricat_file} or pod2usage("Please specify (-p|--pricat_file) to work with\n");
	-e $options->{pricat_file} or pod2usage("$options->{pricat_file} destination is incorrect\n");
	$options->{mappings_file} or pod2usage("Please specify (-m|--mappings_file) to work with\n");
	-e $options->{mappings_file} or pod2usage("$options->{mappings_file} destination is incorrect\n");

	return $options;
}

sub parse_csv {
	my ($file) = @_;

	my $csv = Text::CSV_XS->new ({ binary => 1, auto_diag => 1, sep_char => ";" });
	open my $fh, "<:encoding(utf8)", $file or die "$file: $!";
	$csv->header($fh);

	my $parsed_csv = $csv->getline_hr_all($fh);
	return $parsed_csv;
}

1;