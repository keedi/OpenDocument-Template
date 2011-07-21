package OpenDocument::Template::Util;
# ABSTRACT: utility function for OpenDocument::Template

use strict;
use warnings;
use autodie;

use File::Path qw( make_path );
use File::Slurp;
use File::Spec::Functions qw( catfile rel2abs );
use File::pushd;
use XML::Tidy;
use Archive::Zip qw( :ERROR_CODES :CONSTANTS );

sub update_template {
    my $self = shift;
    my $ot   = shift;

    return unless $ot;
    return unless ref $ot eq 'OpenDocument::Template';

    my %params = (
        output_dir => $ot->template_dir,
        prefix     => qr/(xxx|yyy|zzz)\./,
        @_,
    );

    make_path( $params{output_dir} ) unless -e $params{output_dir};

    my $src        = rel2abs( $ot->src );
    my $output_dir = rel2abs( $params{output_dir} );

    {
        my $dir = tempd();

        my $zip = Archive::Zip->new;
        die 'read error' unless $zip->read( $src ) == AZ_OK;

        for my $file ( keys %{ $ot->config->{templates} } ) {
            my $member = $zip->memberNamed($file);
            next unless $member;

            if ( $zip->extractMember($member) != AZ_OK ) {
                warn "$file does not exist\n";
                next;
            }

            my $tidy = XML::Tidy->new($file);
            $tidy->tidy;
            $tidy->write;

            my $text = read_file($file);
            my $regexp = $params{prefix};
            $text =~ s/${regexp}\w+/[% $& | xml %]/g;
            write_file( catfile($output_dir, $file), $text );
        }
    }
}

1;
__END__

=pod

=method update_template

update template.

    my $ot = OpenDocument::Template->new(
        config       => 'dcf.yml',
        template_dir => 'templates',
        src          => 'dcf-template.odt',
        dest         => 'dcf.odt',
    );
    OpenDocument::Template::Util->update_template(
        $ot,
        prefix     => qr/(xxx|yyy)\./,
        output_dir => 'result',
    );

=cut
