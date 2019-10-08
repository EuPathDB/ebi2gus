package GUSTableDefinitionParser;

use strict;

use XML::Simple;
use GUSTableDefinition;

use Data::Dumper;

sub getXMLAsObject { $_[0]->{_xml_as_object} }
sub setXMLAsObject { $_[0]->{_xml_as_object} = $_[1] }

sub new {
    my ($class, $xmlFile) = @_;

    my $xml = XMLin($xmlFile, ForceArray => 1);

    my $tables = $xml->{'table'};

    my %ucTables = map { uc $_ => $tables->{$_} } keys %$tables;
    
    my $self = bless {}, $class;
    $self->setXMLAsObject(\%ucTables);

    return $self;
}


sub makeTableDefinition {
    my ($self, $tableName) = @_;
    
    my $xml = $self->getXMLAsObject();

    my $table = $xml->{$tableName};
    unless($table) {
	die "Could not find table [$tableName] in GUS Schema Definition xml\n";
    }

    return GUSTableDefinition->new($tableName, $table);
}

1;
