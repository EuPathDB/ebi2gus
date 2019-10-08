package OutputFile;

use strict;

sub getFileName { $_[0]->{_file_name} }
sub setFileName { $_[0]->{_file_name} = $_[1] }

sub getFileHandle { $_[0]->{_file_handle} }
sub setFileHandle { $_[0]->{_file_handle} = $_[1] }

sub nextPk { ++$_[0]->{_next_pk} }

sub new {
    my ($class, $realTableName, $outputDirectory) = @_;

    my $self = bless {}, $class;    

    my $fileName = $outputDirectory . "/$realTableName";
    
    $self->setFileName($fileName);

    my $fh;
    open($fh, ">>$fileName") or die "Could not open file $fileName for writing: $!";

    $self->setFileHandle($fh);

    return $self;
}

sub DESTROY {
    my ($self) = @_;

    close $self->getFileHandle();
}

1;
