use strict;
use warnings;
use Test2::V0;
use Test2::Tools::Class qw[isa_ok can_ok];
#
BEGIN { chdir '../' if !-d 't'; }
use lib '../lib', 'lib', '../blib/arch', '../blib/lib', 'blib/arch', 'blib/lib', '../../', '.';
#
use At;
#
subtest 'live' => sub {
    my $at = At->new( host => 'https://bsky.social', identifier => 'atperl.bsky.social', password => 'ck2f-bqxl-h54l-xm3l' );
    use At::Lexicon::app::bsky::feed;
    ok my $newpost
        = $at->createRecord( $at->did, 'app.bsky.feed.post',
        { '$type' => 'app.bsky.feed.post', text => 'Hello world! I posted this via the API. Today is ' . localtime, createdAt => time } ),
        'createRecord';
    isa_ok $newpost->{uri}, ['URI'];
    my ($rkey) = ( $newpost->{uri}->as_string =~ m[at://did:plc:.+?/app.bsky.feed.post/(.+)] );
    diag $rkey;
    ok $at->deleteRecord( $at->did, 'app.bsky.feed.post', $rkey ), sprintf '$at->deleteRecord( "%s", ... )', $rkey;
    #
    subtest 'describeRepo' => sub {
        ok my $desc = $at->describeRepo( $at->did ), sprintf '$at->describeRepo( "%s", ... )', $at->did->_raw;
        is $desc->{collections},  [ 'app.bsky.feed.like', 'app.bsky.feed.post', 'app.bsky.graph.follow' ], ' ->{collections}';
        is $desc->{handle}->_raw, 'atperl.bsky.social',                                                    ' ->{handle}';
    };
    #
    isa_ok my $create = At::Lexicon::com::atproto::repo::applyWrites::create->new(
        collection => 'app.bsky.feed.post',
        rkey       => $rkey,
        value      => {
            '$type'   => 'app.bsky.feed.post',
            text      => 'Hello world! I posted this via the API.',
            createdAt => At::Protocol::Timestamp->new( timestamp => time )->_raw
        }
    );
    isa_ok my $delete = At::Lexicon::com::atproto::repo::applyWrites::delete->new( collection => 'app.bsky.feed.post', rkey => $rkey );

    #~ ok $at->applyWrites( $at->did, [ $create, $delete ], 1 );
};
#
done_testing;
