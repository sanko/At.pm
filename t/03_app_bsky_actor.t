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
    At::Lexicon::app::bsky::actor::profileViewBasic->new(
        did    => 'did:plc:z72i7hdynmk6r22z27h6tvur',
        handle => 'nice.fun.com',
        labels => [ { src => 'did:plc:z72i7hdynmk6r22z27h6tvur', uri => 'at://fdsafdsafdsa.testads.fdsafodsanl', val => 'hi', cts => time } ]
    ),
    ['At::Lexicon::app::bsky::actor::profileViewBasic'],
    '::profileViewBasic'
);
At::Lexicon::app::bsky::actor::profileView->new( handle => 'nice.fun.com', did => 'did:plc:z72i7hdynmk6r22z27h6tvur' );
#
isa_ok( At::Lexicon::app::bsky::actor::preferences->new( items => [] ), ['At::Lexicon::app::bsky::actor::preferences'], '::preferences (empty)' );
subtest 'coerced prefs' => sub {
    my $prefs = At::Lexicon::app::bsky::actor::preferences->new(
        items => [
            { enabled   => 1 },                               # adultContentPref
            { label     => 'test', visibility => 'hide' },    # contentLabelPref
            { pinned    => [],     saved      => [] },        # savedFeedsPref
            { birthDate => '2023-12-01T14:12:40Z' },          # personalDetailsPref
            { feed      => 'https://fun.com/feed/' },         # feedViewPref
            { sort      => 'newest' }                         # threadViewPref
        ]
    );
    isa_ok( $prefs->items->[0], ['At::Lexicon::app::bsky::actor::adultContentPref'],    '::preferences coerce (adultContentPref)' );
    isa_ok( $prefs->items->[1], ['At::Lexicon::app::bsky::actor::contentLabelPref'],    '::preferences coerce (contentLabelPref)' );
    isa_ok( $prefs->items->[2], ['At::Lexicon::app::bsky::actor::savedFeedsPref'],      '::preferences coerce (savedFeedsPref)' );
    isa_ok( $prefs->items->[3], ['At::Lexicon::app::bsky::actor::personalDetailsPref'], '::preferences coerce (personalDetailsPref)' );
    isa_ok( $prefs->items->[4], ['At::Lexicon::app::bsky::actor::feedViewPref'],        '::preferences coerce (feedViewPref)' );
    isa_ok( $prefs->items->[5], ['At::Lexicon::app::bsky::actor::threadViewPref'],      '::preferences coerce (threadViewPref)' );
};
#
done_testing;
