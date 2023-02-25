package Music::CreatingRhythms;

# ABSTRACT: Perl from the C code of the book

our $VERSION = '0.0100';

use Moo;
use strictures 2;
use Algorithm::Combinatorics qw(permutations);
use Carp qw(croak);
use Data::Munge qw(list2re);
use Integer::Partition ();
use List::Util qw(all any);
use Math::Sequence::DeBruijn qw(debruijn);
use Music::AtonalUtil ();
use namespace::clean;

=head1 SYNOPSIS

  use Music::CreatingRhythms ();

  my $mcr = Music::CreatingRhythms->new(verbose => 1);

=head1 DESCRIPTION

C<Music::CreatingRhythms> provides the algorithms described in the
book, "Creating Rhythms", by Hollos. These algorithms are ported from
the C. Please see the link below for more information.

NB: Arguments are sometimes switched between book and software.

=head1 ATTRIBUTES

=head2 verbose

  $verbose = $mcr->verbose;

Show progress.

=cut

has verbose => (
    is      => 'ro',
    isa     => sub { croak "$_[0] is not a boolean" unless $_[0] =~ /^[01]$/ },
    default => sub { 0 },
);

=head1 METHODS

=head2 new

  $mcr = Music::CreatingRhythms->new(verbose => 1);

Create a new C<Music::CreatingRhythms> object.

=for Pod::Coverage BUILD

=cut

=head2 debruijn_n

  $sequence = $mcr->debruijn_n($n);

Generate the largest de Bruijn sequence of order B<n>.

=cut

sub debruijn_n {
    my ($self, $n) = @_;
    my $sequence = $n ? debruijn([1,0], $n) : 0;
    return [ split //, $sequence ];
}

=head2 part

  $partitions = $mcr->part($n);

Generate all partitions of B<n>.

=cut

sub part {
    my ($self, $n) = @_;
    my $i = Integer::Partition->new($n, { lexicographic => 1 });
    my @partitions;
    while (my $p = $i->next) {
        push @partitions, [ sort { $a <=> $b } @$p ];
    }
    return \@partitions;
}

=head2 parta

  $partitions = $mcr->parta($n, @intervals);

Generate all partitions of B<n> with allowed intervals
B<p1, p2, ... pn>.

=cut

sub parta {
    my ($self, $n, @parts) = @_;
    my $re = list2re @parts;
    my $i = Integer::Partition->new($n, { lexicographic => 1 });
    my @partitions;
    while (my $p = $i->next) {
      push @partitions, [ sort { $a <=> $b } @$p ]
        if all { $_ =~ /^$re$/ } @$p;
    }
    return \@partitions;
}

=head2 partam

  $partitions = $mcr->partam($n, $m, @intervals);

Generate all partitions of B<n> with B<m> parts from the intervals
B<p1, p2, ... pn>.

=cut

sub partam {
    my ($self, $n, $m, @parts) = @_;
    my $re = list2re @parts;
    my $i = Integer::Partition->new($n);
    my @partitions;
    while (my $p = $i->next) {
        push @partitions, [ sort { $a <=> $b } @$p ]
          if @$p == $m && all { $_ =~ /^$re$/ } @$p;
    }
    return \@partitions;
}

=head2 partm

  $partitions = $mcr->partm($n, $m);

Generate all partitions of B<n> into B<m> parts.

=cut

sub partm {
    my ($self, $n, $m) = @_;
    my $i = Integer::Partition->new($n);
    my @partitions;
    while (my $p = $i->next) {
        push @partitions, [ sort { $a <=> $b } @$p ]
          if @$p == $m;
    }
    return \@partitions;
}

=head2 permute

  $all_permutations = $mcr->permute(\@parts);

Return all permutations of the given B<parts> list as an
array-reference of array-references.

(For an efficient iterator, check out the L<Algorithm::Combinatorics>
module.)

=cut 

sub permute {
    my ($self, $parts) = @_;
    my @permutations = permutations($parts);
    return \@permutations;
}

=head2 reverse_at

  $sequence = $mcr->reverse_at($n, $parts);

Reverse a section of a B<parts> array-reference at B<n>.

=cut

sub reverse_at {
    my ($self, $n, $parts) = @_;
    my @head = @$parts[ 0 .. $n - 1 ];
    my @tail = reverse @$parts[ $n .. $#$parts ];
    my @data = (@head, @tail);
    return \@data;
}

=head2 rotate_n

  $sequence = $mcr->rotate_n($n, $parts);

Rotate a necklace of the given B<parts>, B<n> times.

=cut

sub rotate_n {
    my ($self, $n, $parts) = @_;
    my $atu = Music::AtonalUtil->new;
    my $sequence = $atu->rotate($n, $parts);
    return $sequence;
}

sub _allowed { # is p one of the parts?
    my ($self, $p, $parts) = @_;
    return any { $p == $_ } @$parts;
}

1;
__END__

=head1 SEE ALSO

L<https://abrazol.com/books/rhythm1/> "Creating Rhythms"

The F<t/01-methods.t> and F<eg/*> programs included with this distribution.

L<Algorithm::Combinatorics>

L<Data::Munge>

L<Integer::Partition>

L<List::Util>

L<Math::Sequence::DeBruijn>

L<Moo>

L<Music::AtonalUtil>

=cut
