package Music::BitVector;

# ABSTRACT: Perl from the C code of the book

our $VERSION = '0.0100';

use Moo;
use strictures 2;
use Algorithm::Combinatorics qw(permutations);
use Carp qw(croak);
use Integer::Partition ();
use List::Util qw(any);
use Math::Sequence::DeBruijn qw(debruijn);
use Music::AtonalUtil ();
use namespace::clean;

=head1 SYNOPSIS

  use Music::BitVector ();

  my $mbv = Music::BitVector->new(verbose => 1);

=head1 DESCRIPTION

C<Music::BitVector> provides the algorithms described in the
book, "Creating Rhythms", by Hollos. These algorithms are ported from
the C. Please see the link below for more information.

NB: Arguments are sometimes switched between book and software.

=head1 ATTRIBUTES

=head2 verbose

  $verbose = $mbv->verbose;

Show progress.

=cut

has verbose => (
    is      => 'ro',
    isa     => sub { croak "$_[0] is not a boolean" unless $_[0] =~ /^[01]$/ },
    default => sub { 0 },
);

=head1 METHODS

=head2 new

  $mbv = Music::BitVector->new(verbose => 1);

Create a new C<Music::BitVector> object.

=for Pod::Coverage BUILD

=cut

=head2 debruijn_n

  $sequence = $mbv->debruijn_n($n);

Generate the largest de Bruijn sequence of order B<n>.

=cut

sub debruijn_n {
    my ($self, $n) = @_;
    my $sequence = $n ? debruijn([1,0], $n) : 0;
    return [ split //, $sequence ];
}

=head2 part

  $partitions = $mbv->part($n);

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

=head2 permute

  $all_permutations = $mbv->permute(\@parts);

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

  $sequence = $mbv->reverse_at($n, $parts);

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

  $sequence = $mbv->rotate_n($n, $parts);

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

L<Integer::Partition>

L<List::Util>

L<Math::Sequence::DeBruijn>

L<Moo>

L<Music::AtonalUtil>

=cut