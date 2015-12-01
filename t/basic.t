use strict;
use warnings;
use 5.010001;
use Test::More tests => 2;
use Test::Clustericious::Blocking;

is scalar blocking { 'hey there' }, 'hey there', 'scalar context';
is_deeply 
  [blocking { qw( one two three )}],
  [qw( one two three )],
  'list context';
