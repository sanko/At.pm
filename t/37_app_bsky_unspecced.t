use strict;
use warnings;
use Test2::V0;
use Test2::Tools::Class     qw[isa_ok];
use Test2::Tools::Exception qw[try_ok];
#
BEGIN { chdir '../' if !-d 't'; }
use lib '../lib', 'lib', '../blib/arch', '../blib/lib', 'blib/arch', 'blib/lib', '../../', '.';
#
use At::Bluesky;
#
subtest 'live' => sub {
    my $bsky = At::Bluesky->new( identifier => 'atperl.bsky.social', password => 'ck2f-bqxl-h54l-xm3l' );
    subtest 'getPopularFeedGenerators' => sub {
        ok my $res = $bsky->getPopularFeedGenerators(), '$bsky->getPopularFeedGenerators()';
        isa_ok $res->{feeds}->[0], ['At::Lexicon::app::bsky::feed::generatorView'], '...returns a list of ::bsky::feed::generatorView objects';
    };
    subtest 'searchActorsSkeleton' => sub {
    SKIP: {
            my $res = eval { $bsky->searchActorsSkeleton('perl'), '$bsky->searchActorsSkeleton("perl")' };
            skip 'searchActorsSkeleton is unsupported' if !$res;
            isa_ok $res->{actors}->[0], ['At::Lexicon::app::bsky::unspecced::skeletonSearchActor'],
                '...returns a list of ::bsky::unspecced::skeletonSearchActor objects';
        }
    };
    subtest 'searchPostsSkeleton' => sub {
    SKIP: {
            my $res = eval { $bsky->searchPostsSkeleton('perl'), '$bsky->searchPostsSkeleton("perl")' };
            skip 'searchPostsSkeleton is unsupported' if !$res;
            isa_ok $res->{posts}->[0], ['At::Lexicon::app::bsky::unspecced::skeletonSearchPost'],
                '...returns a list of ::bsky::unspecced::skeletonSearchPost objects';
        }
    };
};
#
done_testing;
