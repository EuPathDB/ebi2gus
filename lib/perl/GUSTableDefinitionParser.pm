package GUSTableDefinitionParser;

use strict;

use XML::Simple;
use GUSTableDefinition;

sub getXMLAsObject { $_[0]->{_xml_as_object} }
sub setXMLAsObject { $_[0]->{_xml_as_object} = $_[1] }

sub new {
    my ($class, $xmlFile) = @_;

    #TODO: XMLin

    #TODO return $self;
}


sub makeTableDefinition {
    my ($self, $tableName) = @_;

    my $xml = $self->getXMLAsObject();

    # TODO
    # return GUSTableDefinition Object
}

1;
