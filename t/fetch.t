#!perl

use strict;
use warnings;

use Test::More tests => 10;
use Test::Fatal;
use Test::TinyMocker;
use MetaCPAN::API;

my $mcpan = MetaCPAN::API->new;
isa_ok( $mcpan, 'MetaCPAN::API' );

my $url  = '/release/distribution/hello';
my $flag = 0;

mock 'HTTP::Tiny'
    => methods 'get'
    => should {
        my $self = shift;
        isa_ok( $self, 'HTTP::Tiny' );
        is( $_[0], $url, 'Correct URL' );

        $flag++ == 0 and return {
            success => 1,
            content => '{"test":"test"}',
        };

        $flag++ == 2 and return {
            success => 1,
        };

        return {
            success => 1,
            content => 'string',
        };
    };

my $result = $mcpan->fetch($url);
is_deeply( $result, { test => 'test' }, 'Correct result' );

like(
    exception { $mcpan->fetch($url) },
    qr/^Missing content in return value/,
    'When content is missing',
);

like(
    exception { $mcpan->fetch($url) },
    qr/^Couldn't decode/,
    'JSON decode fail',
);

