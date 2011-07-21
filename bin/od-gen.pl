#!/usr/bin/env perl
# ABSTRACT: generate template applied OpenDocument file
# PODNAME: od-gen.pl

use 5.010;
use utf8;
use strict;
use warnings;
use autodie;
use Getopt::Long::Descriptive;
use OpenDocument::Template;

binmode STDIN,  ':utf8';
binmode STDOUT, ':utf8';

my ( $opt, $usage ) = describe_options(
    "%c %o ...",
    [ 'config|c=s',       'config file'          ],
    [
        'template-dir|t=s',
        'template directory (default: .)',
        { default => q{.} },
    ],
    [ 'src|s=s',          'source ODT file'      ],
    [ 'dest|d=s',         'destination ODT file' ],
    [],
    [ 'verbose|v', 'print extra stuff', { default => 0 } ],
    [ 'help|h',    'print usage message and exit'        ],
);

print($usage->text), exit if $opt->help;
print($usage->text), exit unless $opt->config && -f $opt->config;
print($usage->text), exit unless $opt->src    && -f $opt->src;
print($usage->text), exit unless $opt->dest;

my $ot = OpenDocument::Template->new(
    config       => $opt->config,
    template_dir => $opt->template_dir,
    src          => $opt->src,
    dest         => $opt->dest,
);
$ot->generate;
