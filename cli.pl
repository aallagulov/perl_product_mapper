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

	say Dumper($parsed_csv);

	return $parsed_csv;
}

1;