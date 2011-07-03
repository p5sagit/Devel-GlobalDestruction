#!/usr/bin/perl -w

use strict;
require 5.006000;

use ExtUtils::MakeMaker;

WriteMakefile(
    NAME             => 'Devel::GlobalDestruction',
    VERSION_FROM     => 'lib/Devel/GlobalDestruction.pm',
    INSTALLDIRS      => 'site',
    SIGN             => 1,
    PL_FILES         => { },
    MIN_PERL_VERSION => '5.006000',
    PREREQ_PM        => {
        'Sub::Exporter' => 0,
    },
    (defined ${^GLOBAL_PHASE} ? (XS => {}, C => []) : ()),
);

