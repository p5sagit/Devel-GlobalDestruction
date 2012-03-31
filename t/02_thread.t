use Config;
BEGIN {
  unless ($Config{useithreads}) {
    print "1..0 # SKIP your perl does not support ithreads\n";
    exit 0;
  }
}

BEGIN {
  unless (eval { require threads }) {
    print "1..0 # SKIP threads.pm not installed\n";
    exit 0;
  }
}

use threads;
use warnings;
use strict;

my $t = threads->create(sub { do 't/01_basic.t' });
$t->join;

exit 0;
