package OpenDocument::Template;
# ABSTRACT: generate OpenDocument from template

use Moose;
use MooseX::SemiAffordanceAccessor;
use MooseX::StrictConstructor;
use namespace::autoclean;
use autodie;

with qw(
    OpenDocument::Template::Role::Config
    OpenDocument::Template::Role::Generate
);

has 'template_dir' => (
    is       => 'rw',
    isa      => 'Str',
    required => 1,
    default  => q{.},
);

has 'src' => (
    is       => 'rw',
    isa      => 'Str',
    required => 1,
);

has 'dest' => (
    is       => 'rw',
    isa      => 'Str',
);

has 'encoding' => (
    is       => 'rw',
    isa      => 'Str',
    default  => q{utf8},
);

__PACKAGE__->meta->make_immutable;
no Moose;
1;
__END__

=pod

=head1 SYNOPSIS

    use OpenDocument::Template;
    
    my $ot = OpenDocument::Template->new(
        config       => 'dcf.yml',
        template_dir => 'templates',
        src          => 'dcf-template.odt',
        dest         => 'dcf.odt',
    );
    $ot->generate;

=head1 DESCRIPTION

This module needs two files, template ODT file and config file.
C<OpenDocument::Template> supports L<Config::Any> configuration file types.
The config file describes which files in ODT have to updated.
Following YAML file is a sample configuration.

    ---
    templates:
      styles.xml:
        title: DATA CLARIFICATION FORM
        header:
        no: BA07-CP01
        site_no: 11
        subjno: SN01-01
        issue_date: 2011-03-17
      content.xml:
        rows:
          - query_no: 1
            crf_page: 01/16
          - query_no: 2
            crf_page: 01/17
          - query_no: 3
            crf_page: 01/17
          - query_no: 4
            crf_page: 01/18

With above configuration, you must have two template files,
C<styles.xml> and C<content.xml>.
And each additional data will be used when template
files is processed.

=attr config

Config file path or hash reference.
Support various config files, check L<Config::Any> for detail.

=attr template_dir

Template directory which contains template file
to replace from source OpenDocument.
Default path is a current directory.

=attr src

Source open document file path

=attr dest

Destination open document file path

=attr encoding

Encoding to apply template.
Default encoding is 'utf8'.

=method new

Create new OpenDocument::Template object.

=method generate

Generate new OpenDocument from source document, template and data.

=cut
