#!/usr/bin/perl

use strict;
use warnings;

# we need to run a test in GD and this fails
# use Test::More tests => 3;
# use ok 'Devel::GlobalDestruction';

BEGIN {
    package Test::Scope::Guard;
    sub new { my ($class, $code) = @_; bless [$code], $class; }
    sub DESTROY { my $self = shift; $self->[0]->() }
}

print "1..4\n";

sub ok ($$) {
    print "not " if !$_[0];
    print "ok";
    print " - $_[1]" if defined $_[1];
    print "\n";
}

ok( eval "use Devel::GlobalDestruction; 1", "use Devel::GlobalDestruction" );

ok( defined &in_global_destruction, "exported" );

ok( !in_global_destruction(), "not in GD" );

our $sg = Test::Scope::Guard->new(sub { ok( in_global_destruction(), "in GD" ) });


