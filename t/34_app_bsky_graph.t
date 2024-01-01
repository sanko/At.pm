use strict;
use warnings;
use Test2::V0;
use Test2::Tools::Class qw[isa_ok];
#
BEGIN { chdir '../' if !-d 't'; }
use lib '../lib', 'lib', '../blib/arch', '../blib/lib', 'blib/arch', 'blib/lib', '../../', '.';
#
use At::Bluesky;

#~ #
isa_ok( At::Lexicon::app::bsky::graph::block->new( subject => 'did:plc:z72i7hdynmk6r22z27h6tvur', createdAt => time ),
    ['At::Lexicon::app::bsky::graph::block'], '::block' );
isa_ok(
    At::Lexicon::app::bsky::graph::listViewBasic->new( uri => 'at://blah.com', purpose => 'modlist', cid => 'cid://blah.here', name => 'Test' ),
    ['At::Lexicon::app::bsky::graph::listViewBasic'],
    '::listViewBasic'
);
isa_ok(
    At::Lexicon::app::bsky::graph::listView->new(
        '$type'   => 'app.bsky.graph#listView',
        uri       => 'at://blah.com',
        indexedAt => time,
        name      => 'Test',
        cid       => 'cid://blah.here',
        creator   => { handle => 'nice.fun.com', did => 'did:plc:z72i7hdynmk6r22z27h6tvur' },
        purpose   => 'app.bsky.graph.defs#modlist'
    ),
    ['At::Lexicon::app::bsky::graph::listView'],
    '::listView'
);
isa_ok(
    At::Lexicon::app::bsky::graph::listItemView->new(
        subject => { handle => 'no.way.man', did => 'did:plc:z72i7hdynmk6r22z27h6tvur' },
        uri     => 'at://blah.no/'
    ),
    ['At::Lexicon::app::bsky::graph::listItemView'],
    '::listItemView'
);
subtest 'live' => sub {
    my $bsky = At::Bluesky->new( identifier => 'atperl.bsky.social', password => 'ck2f-bqxl-h54l-xm3l' );
    subtest 'getSuggestedFeeds' => sub {
        ok my $feeds = $bsky->getSuggestedFeeds(), '$bsky->getSuggestedFeeds()';
        my $feed = $feeds->{feeds}->[0];
        isa_ok $feed,          ['At::Lexicon::app::bsky::feed::generatorView'], '...contains list of feeds';
        isa_ok $feed->creator, ['At::Lexicon::app::bsky::actor::profileView'],  '......feeds contain creators';
    };
};
#
done_testing;
