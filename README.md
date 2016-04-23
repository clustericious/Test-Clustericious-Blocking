# Test::Clustericious::Blocking [![Build Status](https://secure.travis-ci.org/clustericious/Test-Clustericious-Blocking.png)](http://travis-ci.org/clustericious/Test-Clustericious-Blocking)

Run blocking code in a process using an unholy combination of forks and Mojolicious

# SYNOPSIS

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

# DESCRIPTION

**Warning**: This module should be considered experimental.

[Clustericious](https://metacpan.org/pod/Clustericious) inherits a great asynchronous API from [Mojolicious](https://metacpan.org/pod/Mojolicious) and 
[Test::Clustericious::Cluster](https://metacpan.org/pod/Test::Clustericious::Cluster) is a great way to test one or more [Clustericious](https://metacpan.org/pod/Clustericious)
services in the same process, but if you have a blocking client to test then
it gets hard.  This module provides a ["blocking"](#blocking) function which takes a code
block.  The code block is executed in a separate process using [forks](https://metacpan.org/pod/forks), and the
return value is returned.  While it is waiting for the thread to complete, it
runs the [Mojo::IOLoop](https://metacpan.org/pod/Mojo::IOLoop) so that the non-blocking [Clustericious](https://metacpan.org/pod/Clustericious) service can
do its thing.

Although designed to work with [Clustericious](https://metacpan.org/pod/Clustericious), it should work it does not 
depend on any [Clustericious](https://metacpan.org/pod/Clustericious) code, and should work with any [Mojolicious](https://metacpan.org/pod/Mojolicious)
application.

# FUNCTIONS

## blocking

    my @values = blocking { ... };

Run the given block in a separate process, allowing it to block without blocking
the test overall.

# CAVEATS

This module uses [forks](https://metacpan.org/pod/forks), and turns off [EV](https://metacpan.org/pod/EV), in order to work with [Mojolicious](https://metacpan.org/pod/Mojolicious).
Most of those modules were never designed to work together, but hey this is Perl right?

This module should be declared as early as possible in your test file, so that it can
turn [EV](https://metacpan.org/pod/EV) off.

# AUTHOR

Graham Ollis <plicease@cpan.org>

# COPYRIGHT AND LICENSE

This software is copyright (c) 2015 by Graham Ollis.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
