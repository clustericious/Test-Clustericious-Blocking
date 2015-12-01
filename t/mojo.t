use strict;
use warnings;
use 5.010001;
BEGIN { $ENV{MOJO_MODE}='testing'; };
use Test::More tests => 3;
use Test::Clustericious::Blocking;
use Mojolicious::Lite;
use Test::Mojo;
use HTTP::Tiny;

app->log->level('fatal');

get '/foo' => sub { shift->render(text => 'a response') };

my $t = Test::Mojo->new;

$t->get_ok('/foo')
  ->content_is('a response');

my $url = $t->tx->req->url->to_abs;

note "url = $url";

is blocking { HTTP::Tiny->new->get($url)->{content} }, 'a response', 'with HTTP::Tiny';
