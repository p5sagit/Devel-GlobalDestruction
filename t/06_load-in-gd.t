use strict;
use warnings;

BEGIN {
  if ($ENV{DEVEL_GLOBALDESTRUCTION_PP_TEST}) {
    unshift @INC, sub {
      die 'no XS' if $_[1] eq 'Devel/GlobalDestruction/XS.pm';
    };
  }
}

{
  package Test::Scope::Guard;
  sub new { my ($class, $code) = @_; bless [$code], $class; }
  sub DESTROY { my $self = shift; $self->[0]->() }
}

print "1..1\n";

our $alive = Test::Scope::Guard->new(sub {
  require Devel::GlobalDestruction;
  my $gd = Devel::GlobalDestruction::in_global_destruction();
  print(($gd ? '' : 'not ') . "ok 1 - global destruct detected when loaded during GD\n");
  exit($gd ? 0 : 1);
});

