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
            { enabled   => 1,                       '$type'    => 'app.bsky.actor.defs#adultContentPref' },
            { label     => 'test',                  visibility => 'hide', '$type' => 'app.bsky.actor.defs#contentLabelPref' },
            { pinned    => [],                      saved      => [],     '$type' => 'app.bsky.actor.defs#savedFeedsPref' },
            { birthDate => '2023-12-01T14:12:40Z',  '$type'    => 'app.bsky.actor.defs#personalDetailsPref' },
            { feed      => 'https://fun.com/feed/', '$type'    => 'app.bsky.actor.defs#feedViewPref' },
            { sort      => 'newest',                '$type'    => 'app.bsky.actor.defs#threadViewPref' }
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
subtest 'live' => sub {
    my $bsky = At::Bluesky->new( identifier => 'atperl.bsky.social', password => 'ck2f-bqxl-h54l-xm3l' );
    isa_ok $bsky->actor->getPreferences(), ['At::Lexicon::app::bsky::actor::preferences'], q[$bsky->actor->getPreferences()];
    isa_ok $bsky->actor->getProfile('atperl.bsky.social'), ['At::Lexicon::app::bsky::actor::profileViewDetailed'],
        q[$bsky->actor->getProfile('atperl.bsky.social')];
    {
        my $ret = $bsky->actor->getProfiles( 'atperl.bsky.social', 'bsky.app' );
        is scalar @{ $ret->{profiles} }, 2, q[$bsky->actor->getProfiles( 'atperl.bsky.social', 'bsky.app' )];
        isa_ok $ret->{profiles}[0], ['At::Lexicon::app::bsky::actor::profileViewDetailed'], '...returned list of profileViewDetailed'
    }
    {
        my $ret = $bsky->actor->getSuggestions();
        ok scalar @{ $ret->{actors} }, q[$bsky->actor->getSuggestions( )];    # should be 50 but the default might change
        isa_ok $ret->{actors}[0], ['At::Lexicon::app::bsky::actor::profileView'], '...returned list of profileView'
    }
    {
        my $ret = $bsky->actor->searchActorsTypeahead('perl');
        ok scalar @{ $ret->{actors} }, q[$bsky->actor->searchActorsTypeahead( )];    # should be 10 but the default might change
        isa_ok $ret->{actors}[0], ['At::Lexicon::app::bsky::actor::profileView'], '...returned list of profileView'
    }
    {
        my $ret = $bsky->actor->searchActors('perl');
        ok scalar @{ $ret->{actors} }, q[$bsky->actor->searchActors( )];             # should be 25 but the default might change
        isa_ok $ret->{actors}[0], ['At::Lexicon::app::bsky::actor::profileView'], '...returned list of profileView'
    }
    ok $bsky->actor->putPreferences( { label => 'test', visibility => 'hide', '$type' => 'app.bsky.actor.defs#contentLabelPref' } ),
        q[$bsky->actor->putPreferences( { ..., '$type' => 'app.bsky.actor.defs#contentLabelPref' } )];
};
#
done_testing;
