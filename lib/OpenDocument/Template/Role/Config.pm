package OpenDocument::Template::Role::Config;
# ABSTRACT: OpenDocument::Template role for config

use Moose::Role;
use Moose::Util::TypeConstraints;
use MooseX::SemiAffordanceAccessor;
use MooseX::StrictConstructor;
use autodie;

use Config::Any;

subtype 'OpenDocument::Template::Types::Config'
    => as 'HashRef';

coerce 'OpenDocument::Template::Types::Config'
    => from 'Str'
        => via {
            return unless -f;

            my $configs = Config::Any->load_files({
                files   => [ $_ ],
                use_ext => 1,
            });
            return unless $configs;
            return unless ref($configs) eq 'ARRAY';

            for (@$configs) {
                my ($filename, $config) = %$_;
                return $config;
            }
        };

has 'config' => (
    is       => 'rw',
    isa      => 'OpenDocument::Template::Types::Config',
    required => 1,
    coerce   => 1,
    default  => sub { { templates => {} } },
);

1;
__END__

