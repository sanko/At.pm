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
subtest 'notificaton' => sub {
    my $notification = At::Lexicon::app::bsky::notification->new(
        author => {
            avatar      => 'https://fake.image/test.jpeg',
            description => 'random description for a test',
            did         => 'did:plc:sLklfdsaio23jklazfvjgyyqo',
            displayName => 'Totally A. Test',
            handle      => 'test.com',
            indexedAt   => '2023-10-11T07:09:20.887Z',
            labels      => [],
            viewer      => { blockedBy => !1, muted => !1, },
        },
        cid           => 'fjdsa9f38warpjcmaur83mrjakrfufca8w9rtmuwjaiocuyfdsar83aw9ru',
        indexedAt     => '2023-11-20T23:03:53.219Z',
        isRead        => !1,
        labels        => [],
        reason        => 'like',
        reasonSubject => 'at://did:plc:lfdsjkalfeiwoaeaaf923fsa/app.bsky.feed.post/9fdkfakfods89',
        record        => {
            '$type'     => 'app.bsky.feed.like',
            'createdAt' => '2023-11-22T23:40:53.555Z',
            'subject'   => {
                cid => 'fjdsa9f38warpjcmaur83mrjakrfufca8w9rtmuwjaiocuyfdsar83aw9ru',
                uri => 'at://did:plc:lfdsjkalfeiwoaeaaf923fsa/app.bsky.feed.post/9fdkfakfods89',
            },
        },
        uri => 'at://did:plc:ba9bo32fksdaf2398ua8c9ap/app.bsky.feed.like/8ufdsjdsoapfj',
    );
    isa_ok( $notification, ['At::Lexicon::app::bsky::notification'], '::notificaton' );
};
#
done_testing;
