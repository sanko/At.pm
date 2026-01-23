use v5.42;
use Time::Piece;
use lib '../lib';
use At;
$|++;
#
my $at = At->new( share => '../share', host => 'https://bsky.social' );
use Data::Dump;
ddx $at->_locate_lexicon('com.atproto.server.activateAccount');
ddx $at->_locate_lexicon('com.atproto.repo.defs#commitMeta');
