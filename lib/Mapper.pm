package Mapper;

use strict;
use warnings;
use feature 'say';
 
use Moo;
use Data::Dumper;

has csv => (
  is  => 'ro',
  required => 1,
  clearer => 1,
);

has processed_mappings => (
  is  => 'ro',
  builder => 'simplify_mappings',
);

sub simplify_mappings {
  my ($self) = @_;

  my $mappings = $self->{csv};

  my $new_mappings = {};
  for my $mapping (@$mappings) {
    $new_mappings->{$mapping->{source_type}}{destination_type} = $mapping->{destination_type};
    $new_mappings->{$mapping->{source_type}}{replace}{$mapping->{source}} = $mapping->{destination};
  }

  # we don't need initial structure anymore
  $self->clear_csv;

  return $new_mappings;
}

sub apply {
  my ($self, $line) = @_;

  my $processed_mappings = $self->{processed_mappings};
  for my $from (keys %$processed_mappings) {
    # we need to handle cases when 2 lines should me mapped into 1
    # ex. "EU|36;European size 36;size_group_code|size_code;size"
    # as well as cases when 1 line is mapped into 1
    # ex. "4;Indaco Nero;color_code;color"
    my @from_fields = split(/\|/, $from);

    my $mapping = $processed_mappings->{$from};
    my $rules = $mapping->{replace};

    my @initial_values;
    for my $from_field (@from_fields) {
      # as I understood - we don't need to have initial fields in result
      push(@initial_values, delete $line->{$from_field});
    }

    my $initial_string = join('|', @initial_values);
    my $final_string = $rules->{$initial_string} // $initial_string;
    $line->{$mapping->{destination_type}} = $final_string;
  }

  # clean up empty columns
  for my $column (keys %$line) {
    delete $line->{$column} unless $line->{$column};
  }
}

1;
