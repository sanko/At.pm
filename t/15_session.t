use strict;
use warnings;
use Test2::V0;
use Test2::Tools::Class qw[isa_ok can_ok];
use Test2::Tools::Ref   qw[ref_ok];
#
BEGIN { chdir '../' if !-d 't'; }
use lib '../lib', 'lib', '../blib/arch', '../blib/lib', 'blib/arch', 'blib/lib', '../../', '.';
#
use At::Bluesky;
#
subtest 'live' => sub {
    isa_ok my $bsky = At::Bluesky->new( identifier => 'atperl.bsky.social', password => 'ck2f-bqxl-h54l-xm3l' ), [ 'At', 'At::Bluesky' ],
        '$bsky = At::Bluesky->new( identifier => ..., password => ... )';
    ref_ok my $session = $bsky->session, 'HASH', '$bsky->session';
    isa_ok my $resumed = At::Bluesky->resume(%$session), [ 'At', 'At::Bluesky' ], '$resumed = At::Bluesky->resume( ... )';
    ok $resumed->actor_getPreferences, '$resumed->actor_getPreferences()';
};
#
done_testing;
