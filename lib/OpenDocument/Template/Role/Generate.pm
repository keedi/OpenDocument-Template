package OpenDocument::Template::Role::Generate;
# ABSTRACT: OpenDocument::Template role for generate

use Moose::Role;
use MooseX::SemiAffordanceAccessor;
use MooseX::StrictConstructor;
use autodie;

use Archive::Zip qw( :ERROR_CODES :CONSTANTS );
use Encode qw( encode );
use File::Spec::Functions;
use Template;

sub generate {
    my $self = shift;
    my $dest = shift || $self->dest;

    unless ($dest) {
        confess 'dest attr is needed';
        return;
    }

    my %config;
    $config{POST_CHOMP} = 1;
    $config{ENCODING}   = $self->encoding if $self->encoding;

    my $tt = Template->new( \%config );

    my $zip = Archive::Zip->new;
    die 'read error' unless $zip->read( $self->src ) == AZ_OK;

    for my $file ( keys %{ $self->config->{templates} } ) {
        my $content;
        $tt->process(
            catfile($self->template_dir, $file),
            $self->config->{templates}{$file},
            \$content,
        ) or die $tt->error;
        if ($self->encoding) {
            $zip->contents($file, encode($self->encoding, $content));
        }
        else {
            $zip->contents($file, $content);
        }
    }

    confess 'write error' unless $zip->writeToFileNamed( $dest ) == AZ_OK;
}

1;
__END__

