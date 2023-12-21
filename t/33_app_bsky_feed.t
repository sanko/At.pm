use strict;
use warnings;
use Test2::V0;
use Test2::Tools::Class qw[isa_ok];
#
BEGIN { chdir '../' if !-d 't'; }
use lib '../lib', 'lib', '../blib/arch', '../blib/lib', 'blib/arch', 'blib/lib', '../../', '.';
#
use At::Bluesky;
#
isa_ok(
    At::Lexicon::app::bsky::feed::postView->new(
        uri        => 'https://blah.com/fun/fun/fun/',
        cid        => 'fdsafsd',
        author     => { did  => 'did:web:fdsafdafdsafdlsajkflds', handle => 'my.name.here' },
        record     => { user => 'defined' },
        indexedAt  => '2023-12-13T01:51:24Z',
        viewer     => { repost => 'https://original.com/fdsafdsa/', like => 'https://like.com/fdsafdsaf/', replyDisabled => !1 },
        threadgate => { cid    => 'fdsa' }
    ),
    ['At::Lexicon::app::bsky::feed::postView'],
    '::postView'
);
#
subtest 'live' => sub {
    my $bsky = At::Bluesky->new( identifier => 'atperl.bsky.social', password => 'ck2f-bqxl-h54l-xm3l' );
    subtest 'getSuggestedFeeds' => sub {
        ok my $feeds = $bsky->getSuggestedFeeds(), '$bsky->getSuggestedFeeds()';
        my $feed = $feeds->{feeds}->[0];
        isa_ok $feed,          ['At::Lexicon::app::bsky::feed::generatorView'], '...contains list of feeds';
        isa_ok $feed->creator, ['At::Lexicon::app::bsky::actor::profileView'],  '......feeds contain creators';
    };
    #
    subtest 'getTimeline' => sub {
        ok my $timeline = $bsky->getTimeline(), '$bsky->getTimeline()';
        my $post = $timeline->{feed}->[0];
        isa_ok $post, ['At::Lexicon::app::bsky::feed::feedViewPost'], '...contains list of feedViewPost objects';
    };
    #
    subtest 'searchPosts' => sub {
        ok my $results = $bsky->searchPosts('perl'), '$bsky->searchPosts("perl")';
        my $post = $results->{posts}->[0];
        isa_ok $post, ['At::Lexicon::app::bsky::feed::postView'], '...contains list of postView objects';
    };
    {
        my $replied;    # Set in getAuthorFeed and used later on
        subtest 'getAuthorFeed' => sub {
            ok my $results = $bsky->getAuthorFeed('bsky.app'), '$bsky->getAuthorFeed("bsky.app")';
            my $post = $results->{feed}->[0];
            isa_ok $post, ['At::Lexicon::app::bsky::feed::feedViewPost'], '...contains list of feedViewPost objects';

            # Store the latest!
            ($replied) = grep { $_->post->replyCount } @{ $results->{feed} };
        };
        subtest 'getRepostedBy' => sub {
            $replied // skip_all 'failed to find a reposted post';
            ok my $results = $bsky->getRepostedBy( $replied->post->uri, $replied->post->cid ), sprintf '$bsky->getRepostedBy("%s...", "%s...")',
                substr( $replied->post->uri->as_string, 0, 25 ), substr( $replied->post->cid, 0, 10 );
            my $post = $results->{repostedBy}->[0];
            isa_ok $post, ['At::Lexicon::app::bsky::actor::profileView'], '...contains list of profileView objects';
        };
    }
    subtest 'getActorFeeds' => sub {
        ok my $results = $bsky->getActorFeeds('bsky.app'), '$bsky->getActorFeeds("bsky.app")';
        my $post = $results->{feeds}->[0];
        isa_ok $post, ['At::Lexicon::app::bsky::feed::generatorView'], '...contains list of generatorView objects';
    };
    subtest 'getActorLikes' => sub {
        ok my $results = $bsky->getActorLikes('atperl.bsky.social'), '$bsky->getActorLikes("atperl.bsky.social")';
        if ( !scalar @{ $results->{feed} } ) { skip_all 1, 'I apparently do not like anything. Weird' }
        else {
            my $post = $results->{feed}->[0];
            isa_ok $post, ['At::Lexicon::app::bsky::feed::feedViewPost'], '...contains list of feedViewPost objects';
        }
    };
    subtest 'getPosts' => sub {    # hardcoded from https://bsky.app/profile/atproto.com/post/3kftlbujmfk24
        ok my $results = $bsky->getPosts('at://did:plc:ewvi7nxzyoun6zhxrhs64oiz/app.bsky.feed.post/3kftlbujmfk24'), '$bsky->getPosts(...)';
        my $post = $results->{posts}->[0];
        isa_ok $post, ['At::Lexicon::app::bsky::feed::postView'], '...contains list of postView objects';
    };
    subtest 'getPostThread' => sub {    # hardcoded from https://bsky.app/profile/atproto.com/post/3kftlbujmfk24
        ok my $results = $bsky->getPostThread('at://did:plc:ewvi7nxzyoun6zhxrhs64oiz/app.bsky.feed.post/3kftlbujmfk24'),
            '$bsky->getPostThread("at://did:plc:ewvi...")';
        isa_ok $results->{thread}, ['At::Lexicon::app::bsky::feed::threadViewPost'], '...returns a threadViewPost object';
    };
    subtest 'getLikes' => sub {
        ok my $results = $bsky->getLikes('at://did:plc:ewvi7nxzyoun6zhxrhs64oiz/app.bsky.feed.post/3kftlbujmfk24'),
            '$bsky->getLikes("at://did:plc:ewvi...")';
        isa_ok $results->{likes}->[0], ['At::Lexicon::app::bsky::feed::getLikes::like'], '...contains list of ::feed::getLikes::like objects';
    };

    #~ subtest 'getFeedGenerator' => sub {
    #~ ok my $results = $bsky->getFeedGenerator('at://did:web:ewvi7nxzyoun6zhxrhs64oiz/app.bsky.feed.generator'),
    #~ '$bsky->getFeedGenerator("at://did:plc:ewvi...")';
    #~ my $post = $results->{repostedBy}->[0];
    #~ isa_ok $post, ['At::Lexicon::app::bsky::actor::profileView'], '...contains list of profileView objects';
    #~ };
};
#
done_testing;
