use strict;
use warnings;

BEGIN {
  if ($ENV{DEVEL_GLOBALDESTRUCTION_PP_TEST}) {
    no strict 'refs';
    no warnings 'redefine';

    for my $f (qw(DynaLoader::bootstrap XSLoader::load)) {
      my ($mod) = $f =~ /^ (.+) \:\: [^:]+ $/x;
      eval "require $mod" or die $@;

      my $orig = \&$f;
      *$f = sub {
        die 'no XS' if ($_[0]||'') eq 'Devel::GlobalDestruction';
        goto $orig;
      };
    }
  }
}

{
  package Test::Scope::Guard;
  sub new { my ($class, $code) = @_; bless [$code], $class; }
  sub DESTROY { my $self = shift; $self->[0]->() }
}

sub ok ($$) {
  print "not " if !$_[0];
  print "ok";
  print " - $_[1]" if defined $_[1];
  print "\n";
  !!$_[0]
}

use Devel::GlobalDestruction;

BEGIN {
  print "1..2\n";
  ok !in_global_destruction(), "BEGIN is not GD";
  my $foo = Test::Scope::Guard->new( sub {
    ok( !in_global_destruction(), "DESTROY in BEGIN still not GD" ) or do {
      require POSIX;
      POSIX::_exit(1);
    };
  });
}

