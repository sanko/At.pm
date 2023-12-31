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
    subtest 'graph_getBlocks' => sub {
        ok my $blocks = $bsky->graph_getBlocks(), '$bsky->graph_getBlocks()';
    SKIP: {
            skip 'I have not banned anyone. ...yet' unless scalar @{ $blocks->{blocks} };
            isa_ok $blocks->{blocks}->[0], ['At::Lexicon::app::bsky::actor::profileView'], '...contains list of profileView objects';
        }
    };
    subtest 'graph_getFollowers' => sub {
        ok my $followers = $bsky->graph_getFollowers('bsky.app'), '$bsky->graph_getFollowers("bsky.app")';
        isa_ok $followers->{followers}->[0], ['At::Lexicon::app::bsky::actor::profileView'], '...contains list of profileView objects';
    };
    subtest 'graph_getFollows' => sub {
        ok my $follows = $bsky->graph_getFollows('bsky.app'), '$bsky->graph_getFollows("bsky.app")';
        isa_ok $follows->{follows}->[0], ['At::Lexicon::app::bsky::actor::profileView'], '...contains list of profileView objects';
    };
    subtest 'graph_getSuggestedFollowsByActor' => sub {
        ok my $res = $bsky->graph_getSuggestedFollowsByActor('bsky.app'), '$bsky->graph_getSuggestedFollowsByActor("bsky.app")';
        isa_ok $res->{suggestions}->[0], ['At::Lexicon::app::bsky::actor::profileViewDetailed'], '...contains list of profileViewDetailed objects';
    };
    {
        my $list;
        subtest 'graph_getLists' => sub {
            ok my $res   = $bsky->graph_getLists('jacob.gold'), '$bsky->graph_getLists("jacob.gold")';
            isa_ok $list = $res->{lists}->[0], ['At::Lexicon::app::bsky::graph::listView'], '...contains list of listView objects';
        };
        subtest 'graph_getList' => sub {
        SKIP: {
                skip 'failed to gather list in previous test' unless defined $list && builtin::blessed $list;
                ok my $res = $bsky->graph_getList( $list->uri->as_string ), '$bsky->graph_getList(' . $list->uri->as_string . ')';
                isa_ok $res->{items}->[0], ['At::Lexicon::app::bsky::graph::listItemView'], '...contains list of listItemView objects';
            }
        };
        subtest 'graph_getListBlocks' => sub {
            ok my $res = $bsky->graph_getListBlocks(), '$bsky->graph_getListBlocks()';
        SKIP: {
                skip 'not blocking any lists' unless scalar @{ $res->{lists} };
                isa_ok $res->{lists}->[0], ['At::Lexicon::app::bsky::graph::listView'], '...contains list of listView objects';
            }
        };
        subtest 'graph_muteActorList' => sub {
            ok $bsky->graph_muteActorList( $list->uri->as_string ), '$bsky->graph_muteActorList(' . $list->uri->as_string . ')';
        };
        subtest 'graph_getListMutes' => sub {
            ok my $res = $bsky->graph_getListMutes(), '$bsky->graph_getListMutes()';
        SKIP: {
                skip 'not muting any lists' unless scalar @{ $res->{lists} };
                isa_ok $res->{lists}->[0], ['At::Lexicon::app::bsky::graph::listView'], '...contains list of listView objects';
            }
        };
        subtest 'graph_unmuteActorList' => sub {
            ok $bsky->graph_unmuteActorList( $list->uri->as_string ), '$bsky->graph_unmuteActorList(' . $list->uri->as_string . ')';
        };
        subtest 'graph_muteActor' => sub {
            ok $bsky->graph_muteActor('sankor.bsky.social'), '$bsky->graph_muteActor("sankor.bsky.social")';
        };
        subtest 'graph_getMutes' => sub {
            ok my $res = $bsky->graph_getMutes(), '$bsky->graph_getMutes()';
        SKIP: {
                skip 'not muting any lists' unless scalar @{ $res->{mutes} };
                isa_ok $res->{mutes}->[0], ['At::Lexicon::app::bsky::actor::profileView'], '...contains list of profileView objects';
            }
        };
        subtest 'graph_unmuteActor' => sub {
            ok $bsky->graph_unmuteActor('sankor.bsky.social'), '$bsky->graph_unmuteActor("sankor.bsky.social")';
        };
    }
};
#
done_testing;
