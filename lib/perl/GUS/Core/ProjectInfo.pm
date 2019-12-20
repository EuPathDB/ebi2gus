package GUS::Core::ProjectInfo;
use base qw(GUSRow Exporter);

use strict;

our @EXPORT = qw($projectId);

our $projectId;

sub new {
    my $class = shift;
    
    # this bit calls init
    my $self = $class->SUPER::new(@_);

    if($projectId) {
	die "Cannot have more than one project id";
    }
    
    $projectId = $self->getPrimaryKey();

    
    return $self;
}


sub init {
    my ($self, $name, $release) = @_;

    my $primaryKey = $self->getPrimaryKey();

    
    return {name => $name,
	    release => $release,
    row_project_id => $primaryKey};
}

1;
