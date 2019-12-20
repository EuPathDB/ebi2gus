package OutputFile;

use strict;



sub getFileName { $_[0]->{_file_name} }
sub setFileName { $_[0]->{_file_name} = $_[1] }

sub getFileHandle { $_[0]->{_file_handle} }
sub setFileHandle { $_[0]->{_file_handle} = $_[1] }

sub getFieldDelimiter { $_[0]->{_field_delimiter} }
sub setFieldDelimiter { $_[0]->{_field_delimiter} = $_[1] }

sub getRowDelimiter { $_[0]->{_row_delimiter} }
sub setRowDelimiter { $_[0]->{_row_delimiter} = $_[1] }


sub getHeaderFields { $_[0]->{_header_fields} }
sub setHeaderFields { $_[0]->{_header_fields} = $_[1] }

sub nextPk { ++$_[0]->{_next_pk} }

sub new {
    my ($class, $realTableName, $outputDirectory) = @_;

    my $self = bless {}, $class;    

    my $fileName = $outputDirectory . "/$realTableName";
    
    $self->setFileName($fileName);

    my $fh;
    open($fh, ">$fileName") or die "Could not open file $fileName for writing: $!";

    $self->setFileHandle($fh);

    $self->setFieldDelimiter("#EOC#\t");
    $self->setRowDelimiter("#EOR#\n");

    return $self;
}

sub  writeHeader() {
    my ($self) = @_;

    my $headerFields = $self->getHeaderFields();
    
    my $fh = $self->getFileHandle();

    my $fieldDelim = $self->getFieldDelimiter();
    my $rowDelim = $self->getRowDelimiter();
    
    print $fh join($fieldDelim, @$headerFields) . $rowDelim;
}


sub  writeRow() {
    my ($self, $impToViewFieldMap, $row) = @_;

    my $headerFields = $self->getHeaderFields();

    my $fh = $self->getFileHandle();

    my $fieldDelim = $self->getFieldDelimiter();
    my $rowDelim = $self->getRowDelimiter();

    my @viewFields = map { $impToViewFieldMap->{$_} } @$headerFields;

    print $fh join($fieldDelim, map { $_ ? $row->{$_} : undef } @viewFields) . $rowDelim;
}


sub DESTROY {
    my ($self) = @_;

    close $self->getFileHandle();
}

1;
