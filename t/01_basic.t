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

BEGIN {
  package Test::Scope::Guard;
  sub new { my ($class, $code) = @_; bless [$code], $class; }
  sub DESTROY { my $self = shift; $self->[0]->() }
}

print "1..6\n";

our $had_error;

# try to ensure this is the last-most END so we capture future tests
# running in other ENDs
require B;
my $reinject_retries = my $max_retry = 5;
my $end_worker;
$end_worker = sub {
  my $tail = (B::end_av()->ARRAY)[-1];
  if (!defined $tail or $tail == $end_worker) {
    $? = $had_error || 0;
    $reinject_retries = 0;
  }
  elsif ($reinject_retries--) {
    push @{B::end_av()->object_2svref}, $end_worker;
  }
  else {
    print STDERR "\n\nSomething is racing with @{[__FILE__]} for final END block definition - can't win after $max_retry iterations :(\n\n";
    require POSIX;
    POSIX::_exit( 255 );
  }
};
END { push @{B::end_av()->object_2svref}, $end_worker }

sub ok ($$) {
  $had_error++, print "not " if !$_[0];
  print "ok";
  print " - $_[1]" if defined $_[1];
  print "\n";
}

ok( eval "use Devel::GlobalDestruction; 1", "use Devel::GlobalDestruction" );

ok( defined &in_global_destruction, "exported" );

ok( defined prototype \&in_global_destruction, "defined prototype" );

ok( prototype \&in_global_destruction eq "", "empty prototype" );

ok( !in_global_destruction(), "not in GD" );

our $sg = Test::Scope::Guard->new(sub { ok( in_global_destruction(), "in GD" ) });
