use strict;
use warnings;
use Test2::V0;
use Test2::Tools::Class qw[isa_ok];
no warnings 'experimental::builtin';    # Be quiet.
#
BEGIN { chdir '../' if !-d 't'; }
use lib '../lib', 'lib', '../blib/arch', '../blib/lib', 'blib/arch', 'blib/lib', '../../', '.';
#
use At::Bluesky;

#~ #
isa_ok( At::Lexicon::app::bsky::graph::block->new( subject => 'did:plc:z72i7hdynmk6r22z27h6tvur', createdAt => time ),
    ['At::Lexicon::app::bsky::graph::block'], '::block' );
isa_ok(
    At::Lexicon::app::bsky::graph::listViewBasic->new(
        uri     => 'at://blah.com',
        purpose => 'app.bsky.graph.defs#modlist',
        cid     => 'cid://blah.here',
        name    => 'Test'
    ),
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
    subtest 'getBlocks' => sub {
        ok my $blocks = $bsky->getBlocks(), '$bsky->getBlocks()';
    SKIP: {
            skip 'I have not banned anyone. ...yet' unless scalar @{ $blocks->{blocks} };
            isa_ok $blocks->{blocks}->[0], ['At::Lexicon::app::bsky::actor::profileView'], '...contains list of profileView objects';
        }
    };
    subtest 'getFollowers' => sub {
        ok my $followers = $bsky->getFollowers('bsky.app'), '$bsky->getFollowers("bsky.app")';
        isa_ok $followers->{followers}->[0], ['At::Lexicon::app::bsky::actor::profileView'], '...contains list of profileView objects';
    };
    subtest 'getFollows' => sub {
        ok my $follows = $bsky->getFollows('bsky.app'), '$bsky->getFollows("bsky.app")';
        isa_ok $follows->{follows}->[0], ['At::Lexicon::app::bsky::actor::profileView'], '...contains list of profileView objects';
    };
    subtest 'getSuggestedFollowsByActor' => sub {
        ok my $res = $bsky->getSuggestedFollowsByActor('bsky.app'), '$bsky->getSuggestedFollowsByActor("bsky.app")';
        isa_ok $res->{suggestions}->[0], ['At::Lexicon::app::bsky::actor::profileViewDetailed'], '...contains list of profileViewDetailed objects';
    };
    {
        my $list;
        subtest 'getLists' => sub {
            ok my $res   = $bsky->getLists('jacob.gold'), '$bsky->getLists("jacob.gold")';
            isa_ok $list = $res->{lists}->[0], ['At::Lexicon::app::bsky::graph::listView'], '...contains list of listView objects';
        };
        subtest 'getList' => sub {
        SKIP: {
                skip 'failed to gather list in previous test' unless defined $list && builtin::blessed $list;
                ok my $res = $bsky->getList( $list->uri->as_string ), '$bsky->getList(' . $list->uri->as_string . ')';
                isa_ok $res->{items}->[0], ['At::Lexicon::app::bsky::graph::listItemView'], '...contains list of listItemView objects';
            }
        };
        subtest 'getListBlocks' => sub {
            ok my $res = $bsky->getListBlocks(), '$bsky->getListBlocks()';
        SKIP: {
                skip 'not blocking any lists' unless scalar @{ $res->{lists} };
                isa_ok $res->{lists}->[0], ['At::Lexicon::app::bsky::graph::listView'], '...contains list of listView objects';
            }
        };
        subtest 'muteActorList' => sub {
            ok $bsky->muteActorList( $list->uri->as_string ), '$bsky->muteActorList(' . $list->uri->as_string . ')';
        };
        subtest 'getListMutes' => sub {
            ok my $res = $bsky->getListMutes(), '$bsky->getListMutes()';
        SKIP: {
                skip 'not muting any lists' unless scalar @{ $res->{lists} };
                isa_ok $res->{lists}->[0], ['At::Lexicon::app::bsky::graph::listView'], '...contains list of listView objects';
            }
        };
        subtest 'unmuteActorList' => sub {
            ok $bsky->unmuteActorList( $list->uri->as_string ), '$bsky->unmuteActorList(' . $list->uri->as_string . ')';
        };
        subtest 'muteActor' => sub {
            ok $bsky->muteActor('sankor.bsky.social'), '$bsky->muteActor("sankor.bsky.social")';
        };
        subtest 'getMutes' => sub {
            ok my $res = $bsky->getMutes(), '$bsky->getMutes()';
        SKIP: {
                skip 'not muting any lists' unless scalar @{ $res->{mutes} };
                isa_ok $res->{mutes}->[0], ['At::Lexicon::app::bsky::actor::profileView'], '...contains list of profileView objects';
            }
        };
        subtest 'unmuteActor' => sub {
            ok $bsky->unmuteActor('sankor.bsky.social'), '$bsky->unmuteActor("sankor.bsky.social")';
        };
    }
};
#
done_testing;
