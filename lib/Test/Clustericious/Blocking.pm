package Test::Clustericious::Blocking;

BEGIN { $ENV{DEVEL_HIDE_VERBOSE} = 0 }

use strict;
use warnings;
use 5.010001;
use Devel::Hide qw( EV );
use Mojolicious 6.00;
use forks;
use base qw( Exporter );

our @EXPORT = qw( blocking );

# ABSTRACT: (Deprecated) Run blocking code in a process using an unholy combination of forks and Mojolicious
# VERSION

=head1 SYNOPSIS

 use Test::Clustericious::Cluster;
 use Test::Clustericious::Blocking;
 use HTTP::Tiny;
 
 my $cluster = Test::Clustericious::Cluster->new;
 $cluster->create('MyApp');
 
 my $url = $cluster->url->clone;
 $url->path('/someroute');
 
 is blocking { HTTP::Tiny->new->get($url)->{content} }, 'some content';
 
 __DATA__
 
 @@ etc/MyApp.conf
 ---
 url: <%= clusters->url %>

=head1 DESCRIPTION

B<NOTE>: This module has been deprecated, and may be removed on or after 31 December 2018.
Please see L<https://github.com/clustericious/Clustericious/issues/46>.

B<Warning>: This module should be considered experimental.

L<Clustericious> inherits a great asynchronous API from L<Mojolicious> and 
L<Test::Clustericious::Cluster> is a great way to test one or more L<Clustericious>
services in the same process, but if you have a blocking client to test then
it gets hard.  This module provides a L</blocking> function which takes a code
block.  The code block is executed in a separate process using L<forks>, and the
return value is returned.  While it is waiting for the thread to complete, it
runs the L<Mojo::IOLoop> so that the non-blocking L<Clustericious> service can
do its thing.

Although designed to work with L<Clustericious>, it should work it does not 
depend on any L<Clustericious> code, and should work with any L<Mojolicious>
application.

=head1 FUNCTIONS

=head2 blocking

 my @values = blocking { ... };

Run the given block in a separate process, allowing it to block without blocking
the test overall.

=cut

sub blocking (&)
{
  my($code) = @_;

  my $wrapper = wantarray ? sub { [$code->()] } : sub { scalar $code->() };
  
  my $thread = threads->create($wrapper);
  Mojo::IOLoop->one_tick while $thread->is_running;

  wantarray ? @{ $thread->join } : $thread->join;
}

1;

=head1 CAVEATS

This module uses L<forks>, and turns off L<EV>, in order to work with L<Mojolicious>.
Most of those modules were never designed to work together, but hey this is Perl right?

This module should be declared as early as possible in your test file, so that it can
turn L<EV> off.

=cut
