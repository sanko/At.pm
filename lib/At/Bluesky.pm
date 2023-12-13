package At::Bluesky {
    use v5.38;
    no warnings 'experimental::class', 'experimental::builtin';    # Be quiet.
    use feature 'class';
    use At;
    use Carp;
    #
    use At::Lexicon::com::atproto::label;
    use At::Lexicon::app::bsky::actor;
    use At::Lexicon::app::bsky::embed;
    use At::Lexicon::app::bsky::graph;
    use At::Lexicon::app::bsky::richtext;
    use At::Lexicon::app::bsky::notification;
    use At::Lexicon::app::bsky::feed;
    #
    class At::Bluesky : isa(At) {
        field $identifier : param = ();
        field $password : param   = ();
        #
        field $actor;
        method _actor ($a) { $actor = $a }
        method actor       {$actor}
        field $graph;
        method _graph ($g) { $graph = $g }
        method graph       {$graph}
        field $notification;
        method _notification ($n) { $notification = $n }
        method notification       {$notification}
        field $feed;
        method _feed ($f) { $feed = $f }
        method feed       {$feed}

        # Required in subclasses of At
        method host { URI->new('https://bsky.social') }
        ADJUST {
            $self->server->createSession( identifier => $identifier, password => $password ) if defined $identifier && defined $password; # auto-login
            $self->_repo( At::Lexicon::AtProto::Repo->new( client => $self, did => $self->http->session->did->_raw ) ) if defined $self->repo;
            $self->_actor( At::Lexicon::Bluesky::Actor->new( client => $self ) );
            $self->_graph( At::Lexicon::Bluesky::Graph->new( client => $self ) );
            $self->_notification( At::Lexicon::Bluesky::Notification->new( client => $self ) );
            $self->_feed( At::Lexicon::Bluesky::Feed->new( client => $self ) );
        }

        # Sugar
        method post (%args) {
            $args{createdAt} //= At::_now();
            my $post = At::Bluesky::Post->new(%args);
            Carp::confess 'text must be fewer than 300 characters' if length $args{text} > 300 || bytes::length $args{text} > 300;
            $self->repo->createRecord( collection => 'app.bsky.feed.post', record => { '$type' => 'app.bsky.feed.post', %{ $post->_raw } } );
        }
    }

    class At::Lexicon::Bluesky::Actor {
        field $client : param;

        method getPreferences () {
            $client->http->session // Carp::confess 'requires an authenticated client';
            my $res = $client->http->get( sprintf( '%s/xrpc/%s', $client->host(), 'app.bsky.actor.getPreferences' ) );
            $res = At::Lexicon::app::bsky::actor::preferences->new( items => $res->{preferences} ) if defined $res->{preferences};
            $res;
        }

        method getProfile ($actor) {
            $client->http->session // Carp::confess 'requires an authenticated client';
            my $res
                = $client->http->get( sprintf( '%s/xrpc/%s', $client->host(), 'app.bsky.actor.getProfile' ), { content => +{ actor => $actor } } );
            $res = At::Lexicon::app::bsky::actor::profileViewDetailed->new(%$res) if defined $res->{did};
            $res;
        }

        method getProfiles (@ids) {
            $client->http->session // Carp::confess 'requires an authenticated client';
            Carp::confess 'getProfiles( ... ) expects no more than 25 actors' if scalar @ids > 25;
            my $res
                = $client->http->get( sprintf( '%s/xrpc/%s', $client->host(), 'app.bsky.actor.getProfiles' ), { content => +{ actors => \@ids } } );
            $res->{profiles} = [ map { At::Lexicon::app::bsky::actor::profileViewDetailed->new(%$_) } @{ $res->{profiles} } ]
                if defined $res->{profiles};
            $res;
        }

        method getSuggestions ( $limit //= (), $cursor //= () ) {
            $client->http->session // Carp::confess 'requires an authenticated client';
            Carp::confess 'getSuggestions( ... ) expects a limit between 1 and 100 (default: 50)' if defined $limit && ( $limit < 1 || $limit > 100 );
            my $res = $client->http->get( sprintf( '%s/xrpc/%s', $client->host(), 'app.bsky.actor.getSuggestions' ),
                { content => +{ defined $limit ? ( limit => $limit ) : (), defined $cursor ? ( cursor => $cursor ) : () } } );
            $res->{actors} = [ map { At::Lexicon::app::bsky::actor::profileView->new(%$_) } @{ $res->{actors} } ] if defined $res->{actors};
            $res;
        }

        method searchActorsTypeahead ( $q, $limit //= () ) {
            $client->http->session // Carp::confess 'requires an authenticated client';
            Carp::confess 'getSuggestions( ... ) expects a limit between 1 and 100 (default: 50)' if defined $limit && ( $limit < 1 || $limit > 100 );
            my $res = $client->http->get(
                sprintf( '%s/xrpc/%s', $client->host(), 'app.bsky.actor.searchActorsTypeahead' ),
                { content => +{ q => $q, defined $limit ? ( limit => $limit ) : () } }
            );
            $res->{actors} = [ map { At::Lexicon::app::bsky::actor::profileView->new(%$_) } @{ $res->{actors} } ] if defined $res->{actors};
            $res;
        }

        method searchActors ( $q, $limit //= (), $cursor //= () ) {
            $client->http->session // Carp::confess 'requires an authenticated client';
            Carp::confess 'searchActorsTypeahead( ... ) expects a limit between 1 and 100 (default: 25)'
                if defined $limit && ( $limit < 1 || $limit > 100 );
            my $res = $client->http->get( sprintf( '%s/xrpc/%s', $client->host(), 'app.bsky.actor.searchActors' ),
                { content => +{ q => $q, defined $limit ? ( limit => $limit ) : (), defined $cursor ? ( cursor => $cursor ) : () } } );
            $res->{actors} = [ map { At::Lexicon::app::bsky::actor::profileView->new(%$_) } @{ $res->{actors} } ] if defined $res->{actors};
            $res;
        }

        method putPreferences (@preferences) {
            $client->http->session // Carp::confess 'requires an authenticated client';
            my $preferences = At::Lexicon::app::bsky::actor::preferences->new( items => \@preferences );
            my $res         = $client->http->post( sprintf( '%s/xrpc/%s', $client->host(), 'app.bsky.actor.putPreferences' ),
                { content => +{ preferences => $preferences->_raw } } );
            return $res eq '';    # TODO: check HTTP status instead?
        }
    }

    class At::Lexicon::Bluesky::Feed {
        field $client : param;

        method getSuggestedFeeds ( $limit //= (), $cursor //= () ) {
            $client->http->session // Carp::confess 'requires an authenticated client';
            Carp::cluck 'limit is too large' if defined $limit && $limit < 0;
            Carp::cluck 'limit is too small' if defined $limit && $limit > 100;
            my $res = $client->http->get( sprintf( '%s/xrpc/%s', $client->host(), 'app.bsky.feed.getSuggestedFeeds' ),
                { content => +{ defined $limit ? ( limit => $limit ) : (), defined $cursor ? ( cursor => $cursor ) : () } } );
            $res->{feeds} = [ map { At::Lexicon::app::bsky::feed::generatorView->new(%$_) } @{ $res->{feeds} } ] if defined $res->{feeds};
            $res;
        }

        method getTimeline ( $algorithm //= (), $limit //= (), $cursor //= () ) {
            $client->http->session // Carp::confess 'requires an authenticated client';
            Carp::cluck 'limit is too large' if defined $limit && $limit < 0;
            Carp::cluck 'limit is too small' if defined $limit && $limit > 100;
            my $res = $client->http->get(
                sprintf( '%s/xrpc/%s', $client->host(), 'app.bsky.feed.getTimeline' ),
                {   content => +{
                        defined $algorithm ? ( algorithm => $algorithm ) : (),
                        defined $limit     ? ( limit     => $limit )     : (),
                        defined $cursor    ? ( cursor    => $cursor )    : ()
                    }
                }
            );
            $res->{feed} = [ map { At::Lexicon::app::bsky::feed::feedViewPost->new(%$_) } @{ $res->{feed} } ] if defined $res->{feed};
            $res;
        }

        method searchPosts ( $q, $limit //= (), $cursor //= () ) {
            $client->http->session // Carp::confess 'requires an authenticated client';
            Carp::cluck 'limit is too large' if defined $limit && $limit < 0;
            Carp::cluck 'limit is too small' if defined $limit && $limit > 100;
            my $res = $client->http->get( sprintf( '%s/xrpc/%s', $client->host(), 'app.bsky.feed.searchPosts' ),
                { content => +{ q => $q, defined $limit ? ( limit => $limit ) : (), defined $cursor ? ( cursor => $cursor ) : () } } );
            $res->{posts} = [ map { At::Lexicon::app::bsky::feed::postView->new(%$_) } @{ $res->{posts} } ] if defined $res->{posts};
            $res;
        }

        method getAuthorFeed ( $actor, $limit //= (), $filter //= (), $cursor //= () ) {
            $client->http->session // Carp::confess 'requires an authenticated client';
            Carp::cluck 'limit is too large' if defined $limit && $limit < 0;
            Carp::cluck 'limit is too small' if defined $limit && $limit > 100;
            my $res = $client->http->get(
                sprintf( '%s/xrpc/%s', $client->host(), 'app.bsky.feed.getAuthorFeed' ),
                {   content => +{
                        actor => $actor,
                        defined $limit ? ( limit => $limit ) : (), defined $filter ? ( filter => $filter ) : (),
                        defined $cursor ? ( cursor => $cursor ) : ()
                    }
                }
            );
            $res->{feed} = [ map { At::Lexicon::app::bsky::feed::feedViewPost->new(%$_) } @{ $res->{feed} } ] if defined $res->{feed};
            $res;
        }

        method getRepostedBy ( $uri, $cid //= (), $limit //= (), $cursor //= () ) {
            $client->http->session // Carp::confess 'requires an authenticated client';
            Carp::cluck 'limit is too large' if defined $limit && $limit < 0;
            Carp::cluck 'limit is too small' if defined $limit && $limit > 100;
            my $res = $client->http->get(
                sprintf( '%s/xrpc/%s', $client->host(), 'app.bsky.feed.getRepostedBy' ),
                {   content => +{
                        uri => ( builtin::blessed $uri? $uri->as_string : $uri ),
                        defined $cid ? ( cid => $cid ) : (), defined $limit ? ( limit => $limit ) : (), defined $cursor ? ( cursor => $cursor ) : ()
                    }
                }
            );
            $res->{uri}        = URI->new( $res->{uri} ) if defined $res->{uri};
            $res->{repostedBy} = [ map { At::Lexicon::app::bsky::actor::profileView->new(%$_) } @{ $res->{repostedBy} } ]
                if defined $res->{repostedBy};
            $res;
        }

        method getActorFeeds ( $actor, $limit //= (), $cursor //= () ) {
            $client->http->session // Carp::confess 'requires an authenticated client';
            Carp::cluck 'limit is too large' if defined $limit && $limit < 0;
            Carp::cluck 'limit is too small' if defined $limit && $limit > 100;
            my $res = $client->http->get( sprintf( '%s/xrpc/%s', $client->host(), 'app.bsky.feed.getActorFeeds' ),
                { content => +{ actor => $actor, defined $limit ? ( limit => $limit ) : (), defined $cursor ? ( cursor => $cursor ) : () } } );
            $res->{feeds} = [ map { At::Lexicon::app::bsky::feed::generatorView->new(%$_) } @{ $res->{feeds} } ] if defined $res->{feeds};
            $res;
        }

        method getActorLikes ( $actor, $limit //= (), $cursor //= () ) {
            $client->http->session // Carp::confess 'requires an authenticated client';
            Carp::cluck 'limit is too large' if defined $limit && $limit < 0;
            Carp::cluck 'limit is too small' if defined $limit && $limit > 100;
            my $res = $client->http->get( sprintf( '%s/xrpc/%s', $client->host(), 'app.bsky.feed.getActorLikes' ),
                { content => +{ actor => $actor, defined $limit ? ( limit => $limit ) : (), defined $cursor ? ( cursor => $cursor ) : () } } );
            $res->{feed} = [ map { At::Lexicon::app::bsky::feed::feedViewPost->new(%$_) } @{ $res->{feed} } ] if defined $res->{feed};
            $res;
        }

        method getPosts (@uris) {
            $client->http->session // Carp::confess 'requires an authenticated client';
            Carp::confess 'too many uris' if scalar @uris > 25;
            my $res = $client->http->get( sprintf( '%s/xrpc/%s', $client->host(), 'app.bsky.feed.getPosts' ), { content => +{ uris => \@uris } } );
            $res->{posts} = [ map { At::Lexicon::app::bsky::feed::postView->new(%$_) } @{ $res->{posts} } ] if defined $res->{posts};
            $res;
        }

        #~ method getFeed () {
        #~ $client->http->session // Carp::confess 'requires an authenticated client';
        #~ my $res = $client->http->get( sprintf( '%s/xrpc/%s', $client->host(), 'app.bsky.feed.getFeed' ) );
        #~ use Data::Dump;
        #~ ddx $res;
        #~ $res = At::Lexicon::app::bsky::actor::preferences->new( items => $res->{preferences} ) if defined $res->{preferences};
        #~ $res;
        #~ }
    }

    class At::Lexicon::Bluesky::Graph {
        field $client : param;

        method getFollows ( $actor, $limit //= 50, $cursor //= () ) {
            $client->http->session // Carp::confess 'requires an authenticated client';
            my $res = $client->http->get(
                sprintf( '%s/xrpc/%s', $client->host(), 'app.bsky.graph.getFollows' ),
                { content => +{ actor => $actor, limit => $limit, cursor => $cursor } }
            );
            $res->{subject} = At::Lexicon::app::bsky::actor::profileView->new( %{ $res->{subject} } )               if defined $res->{subject};
            $res->{follows} = [ map { At::Lexicon::app::bsky::actor::profileView->new(%$_) } @{ $res->{follows} } ] if defined $res->{follows};
            $res;
        }

        method getFollowers ( $actor, $limit //= 50, $cursor //= () ) {
            $client->http->session // Carp::confess 'requires an authenticated client';
            my $res = $client->http->get(
                sprintf( '%s/xrpc/%s', $client->host(), 'app.bsky.graph.getFollowers' ),
                { content => +{ actor => $actor, limit => $limit, cursor => $cursor } }
            );
            $res->{subject}   = At::Lexicon::app::bsky::actor::profileView->new( %{ $res->{subject} } )                 if defined $res->{subject};
            $res->{followers} = [ map { At::Lexicon::app::bsky::actor::profileView->new(%$_) } @{ $res->{followers} } ] if defined $res->{followers};
            $res;
        }

        method getLists ( $actor, $limit //= 50, $cursor //= () ) {
            $client->http->session // Carp::confess 'requires an authenticated client';
            my $res = $client->http->get(
                sprintf( '%s/xrpc/%s', $client->host(), 'app.bsky.graph.getLists' ),
                { content => +{ actor => $actor, limit => $limit, cursor => $cursor } }
            );
            $res->{lists} = [ map { At::Lexicon::app::bsky::graph::listView->new(%$_) } @{ $res->{lists} } ] if defined $res->{lists};
            $res;
        }

        method getList ( $list, $limit //= 50, $cursor //= () ) {
            $client->http->session // Carp::confess 'requires an authenticated client';
            my $res = $client->http->get(
                sprintf( '%s/xrpc/%s', $client->host(), 'app.bsky.graph.getList' ),
                { content => +{ list => $list, limit => $limit, cursor => $cursor } }
            );
            $res->{list}  = At::Lexicon::app::bsky::graph::listView->new( %{ $res->{list} } )                    if defined $res->{list};
            $res->{items} = [ map { At::Lexicon::app::bsky::graph::listItemView->new(%$_) } @{ $res->{items} } ] if defined $res->{items};
            $res;
        }

        method getSuggestedFollowsByActor ($actor) {
            $client->http->session // Carp::confess 'requires an authenticated client';
            my $res = $client->http->get( sprintf( '%s/xrpc/%s', $client->host(), 'app.bsky.graph.getSuggestedFollowsByActor' ),
                { content => +{ actor => $actor } } );

            # current lexicon incorrectly claims this is a list of profileView objects
            $res->{suggestions} = [ map { At::Lexicon::app::bsky::actor::profileViewDetailed->new(%$_) } @{ $res->{suggestions} } ]
                if defined $res->{suggestions};
            $res;
        }

        method getBlocks ( $limit //= 50, $cursor //= () ) {
            $client->http->session // Carp::confess 'requires an authenticated client';
            my $res = $client->http->get( sprintf( '%s/xrpc/%s', $client->host(), 'app.bsky.graph.getBlocks' ),
                { content => +{ limit => $limit, cursor => $cursor } } );
            $res->{blocks} = [ map { At::Lexicon::app::bsky::graph::profileView->new(%$_) } @{ $res->{blocks} } ] if defined $res->{blocks};
            $res;
        }

        method getListBlocks ( $limit //= 50, $cursor //= () ) {
            $client->http->session // Carp::confess 'requires an authenticated client';
            my $res = $client->http->get( sprintf( '%s/xrpc/%s', $client->host(), 'app.bsky.graph.getListBlocks' ),
                { content => +{ limit => $limit, cursor => $cursor } } );
            $res->{lists} = [ map { At::Lexicon::app::bsky::graph::listView->new(%$_) } @{ $res->{lists} } ] if defined $res->{lists};
            $res;
        }

        method getMutes ( $limit //= 50, $cursor //= () ) {
            $client->http->session // Carp::confess 'requires an authenticated client';
            my $res = $client->http->get( sprintf( '%s/xrpc/%s', $client->host(), 'app.bsky.graph.getMutes' ),
                { content => +{ limit => $limit, cursor => $cursor } } );
            $res->{mutes} = [ map { At::Lexicon::app::bsky::graph::profileView->new(%$_) } @{ $res->{mutes} } ] if defined $res->{mutes};
            $res;
        }

        method getListMutes ( $limit //= 50, $cursor //= () ) {
            $client->http->session // Carp::confess 'requires an authenticated client';
            my $res = $client->http->get( sprintf( '%s/xrpc/%s', $client->host(), 'app.bsky.graph.getListMutes' ),
                { content => +{ limit => $limit, cursor => $cursor } } );
            $res->{lists} = [ map { At::Lexicon::app::bsky::graph::listView->new(%$_) } @{ $res->{lists} } ] if defined $res->{lists};
            $res;
        }

        method muteActor ($actor) {
            $client->http->session // Carp::confess 'requires an authenticated client';
            my $res
                = $client->http->post( sprintf( '%s/xrpc/%s', $client->host(), 'app.bsky.graph.muteActor' ), { content => +{ actor => $actor } } );
            $res;
        }

        method unmuteActor ($actor) {
            $client->http->session // Carp::confess 'requires an authenticated client';
            my $res
                = $client->http->post( sprintf( '%s/xrpc/%s', $client->host(), 'app.bsky.graph.unmuteActor' ), { content => +{ actor => $actor } } );
            $res;
        }

        method muteActorList ($list) {
            $client->http->session // Carp::confess 'requires an authenticated client';
            my $res
                = $client->http->post( sprintf( '%s/xrpc/%s', $client->host(), 'app.bsky.graph.muteActorList' ), { content => +{ list => $list } } );
            $res;
        }

        method unmuteActorList ($list) {
            $client->http->session // Carp::confess 'requires an authenticated client';
            my $res = $client->http->post( sprintf( '%s/xrpc/%s', $client->host(), 'app.bsky.graph.unmuteActorList' ),
                { content => +{ list => $list } } );
            $res;
        }
    }

    class At::Lexicon::Bluesky::Notification {
        field $client : param;

        method listNotifications ( $seenAt //= (), $limit //= 50, $cursor //= () ) {
            $client->http->session // Carp::confess 'requires an authenticated client';
            $seenAt = At::Protocol::Timestamp->new( timestamp => $seenAt ) if defined $seenAt && builtin::blessed $seenAt;
            my $res = $client->http->get(
                sprintf( '%s/xrpc/%s', $client->host(), 'app.bsky.notification.listNotifications' ),
                { content => +{ limit => $limit, cursor => $cursor, seenAt => defined $seenAt ? $seenAt->_raw : undef } }
            );
            $res->{notifications} = [ map { At::Lexicon::app::bsky::notification->new(%$_) } @{ $res->{notifications} } ]
                if defined $res->{notifications};
            $res;
        }

        method getUnreadCount ( $seenAt //= () ) {
            $client->http->session // Carp::confess 'requires an authenticated client';
            $seenAt = At::Protocol::Timestamp->new( timestamp => $seenAt ) if defined $seenAt && builtin::blessed $seenAt;
            my $res = $client->http->get(
                sprintf( '%s/xrpc/%s', $client->host(), 'app.bsky.notification.getUnreadCount' ),
                { content => +{ seenAt => defined $seenAt ? $seenAt->_raw : undef } }
            );
            $res;
        }

        method updateSeen ($seenAt) {
            $client->http->session // Carp::confess 'requires an authenticated client';
            $seenAt = At::Protocol::Timestamp->new( timestamp => $seenAt ) unless builtin::blessed $seenAt;
            my $res = $client->http->post( sprintf( '%s/xrpc/%s', $client->host(), 'app.bsky.notification.updateSeen' ),
                { content => +{ seenAt => $seenAt->_raw } } );
            $res;
        }

        method registerPush ( $appId, $platform, $serviceDid, $token ) {
            $client->http->session // Carp::confess 'requires an authenticated client';
            my $res = $client->http->post( sprintf( '%s/xrpc/%s', $client->host(), 'app.bsky.notification.registerPush' ),
                { content => +{ appId => $appId, platform => $platform, serviceDid => $serviceDid, token => $token } } );
            $res;
        }
    }
};
1;
__END__
=encoding utf-8

=head1 NAME

At::Bluesky - Bluesky Sugar for the AT Protocol

=head1 SYNOPSIS

    use At::Bluesky;
    my $at = At::Bluesky->new( identifier => 'sankor.bsky.social', password => '1111-aaaa-zzzz-0000' );
    $at->post( text => 'Hello world! I posted this via the API.' );

=head1 DESCRIPTION

This is a cookbook. Or, it will be, eventually.

=head1 Main Methods

Bluesky. It's new.

=head2 C<new( ... )>

    At::Bluesky->new( identifier => 'sanko', password => '1111-2222-3333-4444' );

Expected parameters include:

=over

=item C<identifier> - required

Handle or other identifier supported by the server for the authenticating user.

=item C<password> - required

This is the app password not the account's password. App passwords are generated at
L<https://bsky.app/settings/app-passwords>.

=back

=head1 Actor Methods

These methods act on data for actor in the Bluesky network. Bluesky uses "actors" as a general term for users.

=head2 C<getPreferences( )>

    $bsky->actor->getPreferences;

Get private preferences attached to the account.

On success, returns a new C<At::Lexicon::app::bsky::actor::preferences> object.

=head2 C<getProfile( ... )>

    $bsky->actor->getProfile( 'sankor.bsky.social' );

Get detailed profile view of an actor.

On success, returns a new C<At::Lexicon::app::bsky::actor::profileViewDetailed> object.

=head2 C<getProfiles( ... )>

    $bsky->actor->getProfiles( 'xkcd.com', 'marthawells.bsky.social' );

Get detailed profile views of multiple actors.

On success, returns a list of up to 25 new C<At::Lexicon::app::bsky::actor::profileViewDetailed> objects.

=head2 C<getSuggestions( [...] )>

    $bsky->actor->getSuggestions( ); # grab 50 results

    my $res = $bsky->actor->getSuggestions( 75 ); # limit number of results to 75

    $bsky->actor->getSuggestions( 75, $res->{cursor} ); # look for the next group of 75 results

Get a list of suggested actors, used for discovery.

Expected parameters include:

=over

=item C<limit> - optional

Maximum of 100, minimum of 1, and 50 is the default.

=item C<cursor> - optional

=back

On success, returns a list of actors as new C<At::Lexicon::app::bsky::actor::profileView> objects and (optionally) a
cursor.

=head2 C<searchActorsTypeahead( ..., [...] )>

    $bsky->actor->searchActorsTypeahead( 'joh' ); # grab 10 results

    $bsky->actor->searchActorsTypeahead( 'joh', 30 ); # limit number of results to 30

Find actor suggestions for a prefix search term.

Expected parameters include:

=over

=item C<query> - required

Search query prefix; not a full query string.

=item C<limit> - optional

Maximum of 100, minimum of 1, and 10 is the default.

=back

On success, returns a list of actors as new C<At::Lexicon::app::bsky::actor::profileViewBasic> objects.

=head2 C<searchActors( ..., [...] )>

    $bsky->actor->searchActors( 'john' ); # grab 25 results

    my $res = $bsky->actor->searchActors( 'john', 30 ); # limit number of results to 30

    $bsky->actor->searchActors( 'john', 30, $res->{cursor} ); # next 30 results

Find actors (profiles) matching search criteria.

Expected parameters include:

=over

=item C<query> - required

Search query string. Syntax, phrase, boolean, and faceting is unspecified, but Lucene query syntax is recommended.

=item C<limit> - optional

Maximum of 100, minimum of 1, and 25 is the default.

=item C<cursor> - optional

=back

On success, returns a list of actors as new C<At::Lexicon::app::bsky::actor::profileViewBasic> objects and (optionally)
a cursor.

=head2 C<putPreferences( ... )>

    $bsky->actor->putPreferences( { '$type' => 'app.bsky.actor#adultContentPref', enabled => false } ); # pass along a coerced adultContentPref object

Set the private preferences attached to the account. This may be an C<At::Lexicon::app::bsky::actor::adultContentPref>,
C<At::Lexicon::app::bsky::actor::contentLabelPref>, C<At::Lexicon::app::bsky::actor::savedFeedsPref>,
C<At::Lexicon::app::bsky::actor::personalDetailsPref>, C<At::Lexicon::app::bsky::actor::feedViewPref>, or
C<At::Lexicon::app::bsky::actor::threadViewPref>. They're coerced if not already objects.

On success, returns a true value.

=head1 Feed Methods



=head2 C<getSuggestedFeeds( [...] )>

    $bsky->feed->getSuggestedFeeds( );

Get a list of suggested feeds for the viewer.

Expected parameters include:

=over

=item C<limit>

The number of feeds to return. Min. is 1, max is 100, 50 is the default.

=item C<cursor>

=back

On success, returns a list of feeds as new C<At::Lexicon::app::bsky::feed::generatorView> objects and (optionally) a
cursor.

=head2 C<getTimeline( [...] )>

    $bsky->feed->getTimeline( );

    $bsky->feed->getTimeline( 'reverse-chronological', 30 );

Get a view of the actor's home timeline.

Expected parameters include:

=over

=item C<algorithm>

Potential values include: C<reverse-chronological>

=item C<limit>

The number of posts to return. Min. is 1, max is 100, 50 is the default.

=item C<cursor>

=back

On success, returns the feed containing a list of new C<At::Lexicon::app::bsky::feed::feedViewPost> objects and
(optionally) a cursor.

=head2 C<searchPosts( ..., [...] )>

    $bsky->feed->searchPosts( "perl" );

Find posts matching search criteria.

Expected parameters include:

=over

=item C<q> - required

Search query string; syntax, phrase, boolean, and faceting is unspecified, but Lucene query syntax is recommended.

=item C<limit>

The number of posts to return. Min. is 1, max is 100, 25 is the default.

=item C<cursor>

Optional pagination mechanism; may not necessarily allow scrolling through entire result set.

=back

On success, returns a list of posts containing new C<At::Lexicon::app::bsky::feed::postView> objects and (optionally) a
cursor. The total number of hits might also be returned. If so, the value may be rounded/truncated, and it may not be
possible to paginate through all hits

=head2 C<getAuthorFeed( ..., [...] )>

    $bsky->feed->getAuthorFeed( "bsky.app" );

Get a view of an actor's feed.

Expected parameters include:

=over

=item C<actor> - required

=item C<limit>

The number of posts to return. Min. is 1, max is 100, 50 is the default.

=item C<filter>

Options:

=over

=item C<posts_with_replies> - default

=item C<posts_no_replies>

=item C<posts_with_media>

=item C<posts_and_author_threads>

=back

=item C<cursor>

Optional pagination mechanism; may not necessarily allow scrolling through entire result set.

=back

On success, returns a feed of posts containing new C<At::Lexicon::app::bsky::feed::feedViewPost> objects and
(optionally) a cursor.

=head2 C<getRepostedBy( ..., [...] )>

    $bsky->feed->getRepostedBy( 'at://did:plc:z72i7hdynmk6r22z27h6tvur/app.bsky.feed.post/3kghpdkfnsk2i' );

Get a list of reposts.

Expected parameters include:

=over

=item C<uri> - required

=item C<cid>

=item C<limit>

The number of authors to return. Min. is 1, max is 100, 50 is the default.

=item C<cursor>

=back

On success, returns the original uri, a list of reposters as C<At::Lexicon::app::bsky::actor::profileView> objects and
(optionally) a cursor and the original cid.

=head2 C<getActorFeeds( ..., [...] )>

    $bsky->feed->getActorFeeds( 'bsky.app' );

Get a list of feeds created by the actor.

Expected parameters include:

=over

=item C<actor> - required

=item C<limit>

The number of feeds to return. Min. is 1, max is 100, 50 is the default.

=item C<cursor>

=back

On success, returns a list of feeds as C<At::Lexicon::app::bsky::feed::generatorView> objects and (optionally) a
cursor.

=head2 C<getActorLikes( ..., [...] )>

    $bsky->feed->getActorLikes( 'bsky.app' );

Get a list of posts liked by an actor.

Expected parameters include:

=over

=item C<actor> - required

=item C<limit>

The number of posts to return. Min. is 1, max is 100, 50 is the default.

=item C<cursor>

=back

On success, returns a list of posts as C<At::Lexicon::app::bsky::feed::feedViewPost> objects and (optionally) a cursor.

=head2 C<getPosts( ... )>

    $bsky->feed->getPosts( 'at://did:plc:ewvi7nxzyoun6zhxrhs64oiz/app.bsky.feed.post/3kftlbujmfk24' );

Get a view of an actor's feed.

Expected parameters include:

=over

=item C<uris> - required

List of C<at://> URIs. No more than 25 at a time.

=back

On success, returns a list of posts as C<At::Lexicon::app::bsky::feed::postView> objects.


























































































































































































=head1 Graph Methods

Methods related to the Bluesky social graph.

=head2 C<getFollows( ..., [ ... ] )>

    $bsky->graph->getFollows('sankor.bsky.social');

Get a list of who the actor follows.

Expected parameters include:

=over

=item C<actor>

=item C<limit> - optional

Maximum of 100, minimum of 1, and 50 is the default.

=item C<cursor> - optional

=back

On success, returns a list of follows as C<At::Lexicon::app::bsky::actor::profileView> objects and the original actor
as the subject, and, potentially, a cursor.

=head2 C<getFollowers( ..., [ ... ] )>

    $bsky->graph->getFollowers('sankor.bsky.social');

Get a list of an actor's followers.

Expected parameters include:

=over

=item C<actor>

=item C<limit> - optional

Maximum of 100, minimum of 1, and 50 is the default.

=item C<cursor> - optional

=back

On success, returns a list of followers as C<At::Lexicon::app::bsky::actor::profileView> objects and the original actor
as the subject, and, potentially, a cursor.

=head2 C<getLists( ..., [ ... ] )>

    $bsky->graph->getLists('sankor.bsky.social');

Get a list of lists that belong to an actor.

Expected parameters include:

=over

=item C<actor>

=item C<limit> - optional

Maximum of 100, minimum of 1, and 50 is the default.

=item C<cursor> - optional

=back

On success, returns a list of C<At::Lexicon::app::bsky::graph::listView> objects and, potentially, a cursor.

=head2 C<getList( ..., [ ... ] )>

    $bsky->graph->getList('at://did:plc:.../app.bsky.graph.list/...');

Get a list of actors.

Expected parameters include:

=over

=item C<list>

Full AT URI.

=item C<limit> - optional

Maximum of 100, minimum of 1, and 50 is the default.

=item C<cursor> - optional

=back

On success, returns a list of C<At::Lexicon::app::bsky::graph::listItemView> objects, the original list as a
C<At::Lexicon::app::bsky::graph::listView> object and, potentially, a cursor.

=head2 C<getSuggestedFollowsByActor( ... )>

    $bsky->graph->getSuggestedFollowsByActor('sankor.bsky.social');

Get suggested follows related to a given actor.

Expected parameters include:

=over

=item C<actor>

=back

On success, returns a list of C<At::Lexicon::app::bsky::actor::profileViewDetailed> objects.

=head2 C<getBlocks( [ ... ] )>

    $bsky->graph->getBlocks( );

Get a list of who the actor is blocking.

Expected parameters include:

=over

=item C<limit> - optional

Maximum of 100, minimum of 1, and 50 is the default.

=item C<cursor> - optional

=back

On success, returns a list of C<At::Lexicon::app::bsky::actor::profileView> objects.

=head2 C<getListBlocks( [ ... ] )>

    $bsky->graph->getListBlocks( );

Get lists that the actor is blocking.

Expected parameters include:

=over

=item C<limit> - optional

Maximum of 100, minimum of 1, and 50 is the default.

=item C<cursor> - optional

=back

On success, returns a list of C<At::Lexicon::app::bsky::graph::listView> objects and, potentially, a cursor.

=head2 C<getMutes( [ ... ] )>

    $bsky->graph->getMutes( );

Get a list of who the actor mutes.

Expected parameters include:

=over

=item C<limit> - optional

Maximum of 100, minimum of 1, and 50 is the default.

=item C<cursor> - optional

=back

On success, returns a list of C<At::Lexicon::app::bsky::actor::profileView> objects.

=head2 C<getListMutes( [ ... ] )>

    $bsky->graph->getListMutes( );

Get lists that the actor is muting.

Expected parameters include:

=over

=item C<limit> - optional

Maximum of 100, minimum of 1, and 50 is the default.

=item C<cursor> - optional

=back

On success, returns a list of C<At::Lexicon::app::bsky::graph::listView> objects and, potentially, a cursor.

=head2 C<muteActor( ... )>

    $bsky->graph->muteActor( 'sankor.bsky.social' );

Mute an actor by DID or handle.

Expected parameters include:

=over

=item C<actor>

Person to mute.

=back

=head2 C<unmuteActor( ... )>

    $bsky->graph->unmuteActor( 'sankor.bsky.social' );

Unmute an actor by DID or handle.

Expected parameters include:

=over

=item C<actor>

Person to mute.

=back

=head2 C<muteActorList( ... )>

    $bsky->graph->muteActorList( 'at://...' );

Mute a list of actors.

Expected parameters include:

=over

=item C<list>

=back

=head2 C<unmuteActorList( ... )>

    $bsky->graph->unmuteActorList( 'at://...' );

Unmute a list of actors.

Expected parameters include:

=over

=item C<list>

=back

=head1 Notification Methods

Notifications keep you up to date.

=head2 C<listNotifications( [...] )>

    $bsky->notification->listNotifications( );

Get a list of notifications.

Expected parameters include:

=over

=item C<limit>

=item C<seenAt>

A timestamp.

=item C<cursor>

=back

On success, returns a list of notifications as C<At::Lexicon::app::bsky::notification> objects and, optionally, a
cursor.

=head2 C<getUnreadCount( [...] )>

    $bsky->notification->getUnreadCount( );

Get the count of unread notifications.

Expected parameters include:

=over

=item C<seenAt>

A timestamp.

=back

On success, returns a count of unread notifications.

=head2 C<updateSeen( ... )>

    $bsky->notification->updateSeen( time );

Notify server that the user has seen notifications.

Expected parameters include:

=over

=item C<seenAt> - required

A timestamp.

=back

=head2 C<registerPush( [...] )>

    $bsky->notification->registerPush(

    );

Register for push notifications with a service.

Expected parameters include:

=over

=item C<appId> - required

=item C<platform> - required

Known values include 'ios', 'android', and 'web'.

=item C<serviceDid> - required

=item C<token> - required

=back




























=begin todo

=head1 Temporary Methods

Sugar.

=head2 C<post( ... )>

This one is easy.

    use At;
    my $bsky = At::Bluesky->new( identifier => 'sankor.bsky.social', password => '1111-aaaa-zzzz-0000' );
    $bsky->post( text => 'Nice.' );

Expected parameters:

=over

=item C<createdAt> - required

Timestamp in ISO 8601.

=item C<text> - required

Post content. 300 max chars.

=back

=end todo

=head1 LICENSE

Copyright (C) Sanko Robinson.

This library is free software; you can redistribute it and/or modify it under the terms found in the Artistic License
2. Other copyrights, terms, and conditions may apply to data transmitted through this module.

=head1 AUTHOR

Sanko Robinson E<lt>sanko@cpan.orgE<gt>

=begin stopwords

Bluesky ios cid reposters reposts

=end stopwords

=cut
