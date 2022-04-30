package Grouper;

use strict;
use warnings;
use feature 'say';
use feature 'state';
 
use Moo;
use Data::Dumper;
use JSON::XS;

has csv => (
  is => 'ro',
  required => 1,
  clearer => 1,
);

has grouped_pricat => (
  is => 'ro',
  builder => 'group_pricat',
);

sub group_pricat {
  my ($self) = @_;

  my $grouped_pricat = $self->_distinguish_articles();
  $self->_move_common_attributes_from_variations($grouped_pricat);
  $self->_move_common_attributes_from_articles($grouped_pricat);

  # we don't need initial structure anymore
  $self->clear_csv;

  return $grouped_pricat;
}

sub _distinguish_articles {
  my ($self) = @_;

  my $grouped_pricat = {};

  my $pricat = $self->{csv};
  for my $line (@$pricat) {
    my $article_number = delete $line->{article_number};

    my $articles = ($grouped_pricat->{articles} //= {});
    my $article = ($articles->{$article_number} //= {variations => []});
    push @{$article->{variations}}, $line;
  }

  return $grouped_pricat;
}

sub _move_common_attributes_from_variations {
  my ($self, $grouped_pricat) = @_;

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
}

sub _move_common_attributes_from_articles {
  my ($self, $grouped_pricat) = @_;

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
}

sub return_json {
  my ($self) = @_;

  state $json_serializer = JSON::XS->new();
  $json_serializer->canonical([1]);
  $json_serializer->pretty([1]);
  return $json_serializer->encode($self->{grouped_pricat});
}


1;
