package GUS::Core::ProjectInfo;
use base qw(GUSRow Exporter);

use strict;

our @EXPORT = qw($projectId);

our $projectId;

sub new {
    my $class = shift;


    print STDERR "NEW METHOD FOR PROJECT INFO\n";
    
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

    print STDERR "INIT METHOD FOR PROJECT INFO\n";
    
    return {name => $name,
	    release => $release};
}

1;
