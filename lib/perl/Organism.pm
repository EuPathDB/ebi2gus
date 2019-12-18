package Organism;

use strict;

use XML::Simple;

sub getNcbiTaxonId { $_[0]->{_ncbi_tax_id} }
sub setNcbiTaxonId { $_[0]->{_ncbi_tax_id}  = $_[1] }

sub getGenomeDatabaseVersion { $_[0]->{_genome_database_version} }
sub setGenomeDatabaseVersion { $_[0]->{_genome_database_version} = $_[1] }

sub getGenomeDatabaseName { $_[0]->{_genome_database_name} }
sub setGenomeDatabaseName { $_[0]->{_genome_database_name} = $_[1] }

sub getChromosomeMap { $_[0]->{_chromosome_map} }
sub setChromosomeMap { $_[0]->{_chromosome_map} = $_[1] }


sub new {
    my ($class, $ncbiTaxId, $genomeDatabaseName, $genomeDatabaseVersion, $chromosomeMapFile) = @_;

    unless(defined $ncbiTaxId) {
	die "Required ncbi_taxon_id missing from organism xml";
    }

    unless($genomeDatabaseName && $genomeDatabaseVersion) {
	die "GenomeDatabase requires name and version. Found [$genomeDatabaseName] and [$genomeDatabaseVersion]"
    }

    my %chromosomeMap;
    if(-e $chromosomeMapFile) {
	open(MAP, $chromosomeMapFile) or die "Cannot open $chromosomeMapFile for reading: $!";

	while(<MAP>) {
	    chomp;

	    my @a = split(/\t/, $_);
	    $chromosomeMap{$a[0]} = {chromosome => $a[1], chromosome_order_num => $a[2]};
	}
	close MAP;
    }
    my $self = bless {}, $class;

    $self->setNcbiTaxonId($ncbiTaxId);
    $self->setGenomeDatabaseName($genomeDatabaseName);
    $self->setGenomeDatabaseVersion($genomeDatabaseVersion);
    $self->setChromosomeMap(\%chromosomeMap);

    return $self;
}

1;
