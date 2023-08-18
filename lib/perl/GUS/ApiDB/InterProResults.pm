package GUS::ApiDB::InterProResults;
use base qw(GUSRow);

use strict;

sub init {
    my ($self, $transcriptSourceId, $proteinSourceId, $geneSourceId, $projectId, $organismAbbrev, $ncbiTaxId, $interproDbName, $interproPrimaryId, $interproSecondaryId, $interproDesc, $interproStartMin, $interproEndMin) = @_;

    return {transcript_source_id => $transcriptSourceId,
            protein_source_id => $proteinSourceId,
            gene_source_id => $geneSourceId,
            project_id => $projectId,
            organism_abbrev => $organismAbbrev,
            ncbi_tax_id => $ncbiTaxId,
            interpro_db_name => $interproDbName,
            interpro_primary_id => $interproPrimaryId,
            interpro_secondary_id => $interproSecondaryId,
            interpro_desc => $interproDesc,
            interpro_start_min => $interproStartMin,
            interpro_end_min => $interproEndMin
            };
}

1;
