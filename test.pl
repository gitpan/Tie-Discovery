# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

######################### We start with some black magic to print on failure.

# Change 1..1 below to 1..last_test_to_print .
# (It may become useful if the test is moved to ./t subdirectory.)

BEGIN { $| = 1; print "1..7\n"; }
END {print "not ok 1\n" unless $loaded;}
use Tie::Discovery;
$loaded = 1;
print "ok 1\n";

######################### End of black magic.

my %test;
my $obj = tie %test, "Tie::Discovery" or print "not ";
print "ok 2\n";

$obj->store('debug',2);
print "ok 3\n";

print "not " if $test{debug} !=2;
$obj->store('debug',0);
print "ok 4\n";

$obj->register("one",sub {1});
print "not " if $test{one} != 1;
print "ok 5\n";
$obj->register("two",sub {$test{one}+1});
$obj->register("three",sub {$test{two}+1});
$obj->register("four",sub {$test{three}+$test{one}});

print "not " if $test{four} != 4;
print "ok 6\n";

eval {$obj->register("one", 1)};
print "not" unless $@;
print "ok 7\n";
