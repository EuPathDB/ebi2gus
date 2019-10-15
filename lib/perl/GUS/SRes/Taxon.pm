package GUS::SRes::Taxon;
use base qw(GUSRow);

use strict;

sub getOrganism { $_[0]->{_organism} }
sub setOrganism { $_[0]->{_organism} = $_[1] }

sub init {
    my ($self, $organism) = @_;

    $self->setOrganism($organism);

    my $ncbiTaxonId = $organism->getNcbiTaxonId();
    
    return {ncbi_tax_id => $ncbiTaxonId};
}

1;
