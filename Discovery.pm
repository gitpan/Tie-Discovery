package Tie::Discovery;

use strict;
use Carp;
use Tie::Hash;
@Tie::Discovery::ISA = qw(Tie::StdHash);
$Tie::Discovery::VERSION = '1.00';

sub TIEHASH {
	return bless {debug=>0},shift;
}

sub STORE {
	carp "Please don't do this. Use \$obj->store or \$obj->register instead.";
	store(@_);
}

sub store ($$$) { $_[0]->{$_[1]}=$_[2] };
sub register ($$\&) { 
croak "Second argument to register() should be coderef" 
	unless ref $_[2] eq "CODE";
$_[0]->{$_[1]}=$_[2] };

sub FETCH {
	if (ref $_[0]->{$_[1]} eq "CODE") {
		print STDERR "(Discovering $_[1]... " if $_[0]->{debug}>0;
		$_[0]->{$_[1]} = &{$_[0]->{$_[1]}};
		print STDERR ")" if $_[0]->{debug}>0;
	} 
	return $_[0]->{$_[1]};
}

1;
__END__

=head1 NAME

Tie::Discovery - Perl extension for `Discovery' hashes

=head1 SYNOPSIS

  use Tie::Discovery;
  my %config = ();
  my $obj = tie %config, "Tie::Discovery";

  sub discover_os { ... }
  $obj->register("os",\&discover_os);

  $config{os};

=head1 DESCRIPTION

A `discovery' hash is a hash that's designed to help you solve the data
dependency problem. It's based on the principle of least work; some
times, you may spend a lot of time in your program finding out paths,
filenames, operating system specifics, network information and so on
that you may not end up using. Discovery hashes allow you to get the
data when you need it, and only when you need it.

To use a discovery hash, first tie a hash as shown above. You will want
to keep hold of the object returned by C<tie>. You can then add things
to discover by calling the C<register> method as shown above. The above
code C<$obj-E<gt>register("os",\&discover_os);> means that when (and
only when!) the value C<$config{os}> is fetched, the sub C<&discover_os>
will be called to find it. The return value of that sub will then be
cached to save a look-up next time.

The real power comes from the fact that you may refer to the tied hash
inside of the discovery subroutines. This allows for fast, neat and
flexible top-down programming, and helps you avoid hard-coding values. 
For instance, let us find the OS by calling the F<uname> program.

	$obj->register( os => sub { `$config{path_to_uname}` } );

Now we need code to find the program itself:

	use File::Spec::Functions;
	$obj->register( path_to_uname => sub {
		foreach (path) {
			return catfile($_,"uname") if -x catfile($_,"uname")
		}
		die "Couldn't even find uname"
	};

Fetching C<$config{os}> may now need a further call to fetch
C<$config{path_to_uname}> unless the path is already cached. And, of
course, we needn't stop at two levels.

Fuller examples of this technique are seen in the forthcoming L<CTAN>
and L<SysConf> modules.

=head2 METHODS

Aside from the usual hash methods, the following are available:

=over 4

=item register(name,sub)

Registers C<name> as an entry in the hash, to be discovered by running
C<sub>

=item store(name,value)

Stores C<value> directly into the hash under the C<name> key. The only
time you should need to do this is to set the value of the C<debug> key;
if set, this shows a trace of the discovery process.

=head2 EXPORT

Nothing.

=head2 LIMITATIONS

At present, since a subroutine reference signifies something to look
up, you can't usefully return one from your discovery subroutine. 

=head1 AUTHOR

Simon Cozens <simon@cpan.org>

=head1 SEE ALSO

perl(1), L<Tie::Hash>

=cut
