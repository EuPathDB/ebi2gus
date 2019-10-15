package GUS::SRes::ExternalDatabase;
use base qw(GUSRow);

use strict;

sub init {
    my ($self, $name) = @_;

    return {name => $name};
}

1;
