package EBIDumper;

use strict;

sub getSequences { $_[0]->{_sequences} }
sub setSequences { $_[0]->{_sequences} = $_[1] }

sub new {
    my ($class, $sequences) = @_;

    my $self = bless {}, $class;

    $self->setSequences($sequences);
    
    return $self;
}

sub convert { }


1;
