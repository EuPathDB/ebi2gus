#!/usr/bin/env perl
use strict;
use warnings;

use Bio::EnsEMBL::Registry;

use Data::Dumper;

use Bio::SeqIO;
use Bio::Seq;

my $registry = 'Bio::EnsEMBL::Registry';

my $count = $registry->load_all("/usr/local/etc/ensembl_registry.conf", 1);

my $slice_adaptor = $registry->get_adaptor('default', 'Core', 'Slice' );

my @slices = @{ $slice_adaptor->fetch_all('toplevel') };

my @logics = ("repeatmask_repbase", "repeatmask_customlib", "trf", "dust");

foreach my $logic (@logics) {
    my $seqio = Bio::SeqIO->new(-file   => ">/tmp/${logic}.fasta",
                                -format => 'fasta' );

    foreach my $slice (@slices) {

        foreach my $repeatFeature (@{$slice->get_all_RepeatFeatures($logic)} ) {

            my $logicName = $repeatFeature->analysis()->logic_name();
            my $displayName = $repeatFeature->display_id();

            my $seqRegionEnd = $repeatFeature->seq_region_end();
            my $seqRegionStart = $repeatFeature->seq_region_start();
            my $seqRegionName = $repeatFeature->seq_region_name();
            my $seqRegionStrand = $repeatFeature->seq_region_strand() == -1 ? '-' : '+';


            my $start = $repeatFeature->start();
            my $end = $repeatFeature->end();

            my $location = "$seqRegionName:$seqRegionStart-$seqRegionEnd($seqRegionStrand)";

            my $dbid = $repeatFeature->dbID();

            my $defline = "display_id=$displayName location=$location analysis=$logicName" ;

            my $seq = Bio::Seq->new(-display_id => $dbid,
                                    -desc => $defline,
                                    -seq => $repeatFeature->feature_Slice()->seq());

            $seqio->write_seq($seq);
        }
    }
}



1;
