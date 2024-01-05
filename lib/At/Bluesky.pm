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
    use At::Lexicon::app::bsky::unspecced;
    #
    class At::Bluesky : isa(At) {

        # Required in subclasses of At
        method host { URI->new('https://bsky.social') }

        # Sugar
        method post (%args) {
            $args{createdAt} //= At::_now();
            my $post = At::Bluesky::Post->new(%args);
            Carp::confess 'text must be fewer than 300 characters' if length $args{text} > 300 || bytes::length $args{text} > 300;
            $self->repo->createRecord( collection => 'app.bsky.feed.post', record => { '$type' => 'app.bsky.feed.post', %{ $post->_raw } } );
        }
    }

    #~ class At::Lexicon::Bluesky::Actor
    {

        method getPreferences () {
            $self->http->session // Carp::confess 'requires an authenticated client';
            my $res = $self->http->get( sprintf( '%s/xrpc/%s', $self->host(), 'app.bsky.actor.getPreferences' ) );
            $res = At::Lexicon::app::bsky::actor::preferences->new( items => $res->{preferences} ) if defined $res->{preferences};
            $res;
        }

        method getProfile ($actor) {
            $self->http->session // Carp::confess 'requires an authenticated client';
            my $res = $self->http->get( sprintf( '%s/xrpc/%s', $self->host(), 'app.bsky.actor.getProfile' ), { content => +{ actor => $actor } } );
            $res = At::Lexicon::app::bsky::actor::profileViewDetailed->new(%$res) if defined $res->{did};
            $res;
        }

        method getProfiles (@ids) {
            $self->http->session // Carp::confess 'requires an authenticated client';
            Carp::confess 'getProfiles( ... ) expects no more than 25 actors' if scalar @ids > 25;
            my $res = $self->http->get( sprintf( '%s/xrpc/%s', $self->host(), 'app.bsky.actor.getProfiles' ), { content => +{ actors => \@ids } } );
            $res->{profiles} = [ map { At::Lexicon::app::bsky::actor::profileViewDetailed->new(%$_) } @{ $res->{profiles} } ]
                if defined $res->{profiles};
            $res;
        }

        method getSuggestions ( $limit //= (), $cursor //= () ) {
            $self->http->session // Carp::confess 'requires an authenticated client';
            Carp::confess 'getSuggestions( ... ) expects a limit between 1 and 100 (default: 50)' if defined $limit && ( $limit < 1 || $limit > 100 );
            my $res = $self->http->get( sprintf( '%s/xrpc/%s', $self->host(), 'app.bsky.actor.getSuggestions' ),
                { content => +{ defined $limit ? ( limit => $limit ) : (), defined $cursor ? ( cursor => $cursor ) : () } } );
            $res->{actors} = [ map { At::Lexicon::app::bsky::actor::profileView->new(%$_) } @{ $res->{actors} } ] if defined $res->{actors};
            $res;
        }

        method searchActorsTypeahead ( $q, $limit //= () ) {
            $self->http->session // Carp::confess 'requires an authenticated client';
            Carp::confess 'getSuggestions( ... ) expects a limit between 1 and 100 (default: 50)' if defined $limit && ( $limit < 1 || $limit > 100 );
            my $res = $self->http->get(
                sprintf( '%s/xrpc/%s', $self->host(), 'app.bsky.actor.searchActorsTypeahead' ),
                { content => +{ q => $q, defined $limit ? ( limit => $limit ) : () } }
            );
            $res->{actors} = [ map { At::Lexicon::app::bsky::actor::profileView->new(%$_) } @{ $res->{actors} } ] if defined $res->{actors};
            $res;
        }

        method searchActors ( $q, $limit //= (), $cursor //= () ) {
            $self->http->session // Carp::confess 'requires an authenticated client';
            Carp::confess 'searchActorsTypeahead( ... ) expects a limit between 1 and 100 (default: 25)'
                if defined $limit && ( $limit < 1 || $limit > 100 );
            my $res = $self->http->get( sprintf( '%s/xrpc/%s', $self->host(), 'app.bsky.actor.searchActors' ),
                { content => +{ q => $q, defined $limit ? ( limit => $limit ) : (), defined $cursor ? ( cursor => $cursor ) : () } } );
            $res->{actors} = [ map { At::Lexicon::app::bsky::actor::profileView->new(%$_) } @{ $res->{actors} } ] if defined $res->{actors};
            $res;
        }

        method putPreferences (@preferences) {
            $self->http->session // Carp::confess 'requires an authenticated client';
            my $preferences = At::Lexicon::app::bsky::actor::preferences->new( items => \@preferences );
            my $res         = $self->http->post( sprintf( '%s/xrpc/%s', $self->host(), 'app.bsky.actor.putPreferences' ),
                { content => +{ preferences => $preferences->_raw } } );
            $res->{success};
        }
    }

    #~ class At::Lexicon::Bluesky::Feed
    {

        method getSuggestedFeeds ( $limit //= (), $cursor //= () ) {
            $self->http->session // Carp::confess 'requires an authenticated client';
            Carp::cluck 'limit is too large' if defined $limit && $limit < 0;
            Carp::cluck 'limit is too small' if defined $limit && $limit > 100;
            my $res = $self->http->get( sprintf( '%s/xrpc/%s', $self->host(), 'app.bsky.feed.getSuggestedFeeds' ),
                { content => +{ defined $limit ? ( limit => $limit ) : (), defined $cursor ? ( cursor => $cursor ) : () } } );
            $res->{feeds} = [ map { At::Lexicon::app::bsky::feed::generatorView->new(%$_) } @{ $res->{feeds} } ] if defined $res->{feeds};
            $res;
        }

        method getTimeline ( $algorithm //= (), $limit //= (), $cursor //= () ) {
            $self->http->session // Carp::confess 'requires an authenticated client';
            Carp::cluck 'limit is too large' if defined $limit && $limit < 0;
            Carp::cluck 'limit is too small' if defined $limit && $limit > 100;
            my $res = $self->http->get(
                sprintf( '%s/xrpc/%s', $self->host(), 'app.bsky.feed.getTimeline' ),
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
            $self->http->session // Carp::confess 'requires an authenticated client';
            Carp::cluck 'limit is too large' if defined $limit && $limit < 0;
            Carp::cluck 'limit is too small' if defined $limit && $limit > 100;
            my $res = $self->http->get( sprintf( '%s/xrpc/%s', $self->host(), 'app.bsky.feed.searchPosts' ),
                { content => +{ q => $q, defined $limit ? ( limit => $limit ) : (), defined $cursor ? ( cursor => $cursor ) : () } } );
            $res->{posts} = [ map { At::Lexicon::app::bsky::feed::postView->new(%$_) } @{ $res->{posts} } ] if defined $res->{posts};
            $res;
        }

        method getAuthorFeed ( $actor, $limit //= (), $filter //= (), $cursor //= () ) {
            $self->http->session // Carp::confess 'requires an authenticated client';
            Carp::cluck 'limit is too large' if defined $limit && $limit < 0;
            Carp::cluck 'limit is too small' if defined $limit && $limit > 100;
            my $res = $self->http->get(
                sprintf( '%s/xrpc/%s', $self->host(), 'app.bsky.feed.getAuthorFeed' ),
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
            $self->http->session // Carp::confess 'requires an authenticated client';
            Carp::cluck 'limit is too large' if defined $limit && $limit < 0;
            Carp::cluck 'limit is too small' if defined $limit && $limit > 100;
            my $res = $self->http->get(
                sprintf( '%s/xrpc/%s', $self->host(), 'app.bsky.feed.getRepostedBy' ),
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
            $self->http->session // Carp::confess 'requires an authenticated client';
            Carp::cluck 'limit is too large' if defined $limit && $limit < 0;
            Carp::cluck 'limit is too small' if defined $limit && $limit > 100;
            my $res = $self->http->get( sprintf( '%s/xrpc/%s', $self->host(), 'app.bsky.feed.getActorFeeds' ),
                { content => +{ actor => $actor, defined $limit ? ( limit => $limit ) : (), defined $cursor ? ( cursor => $cursor ) : () } } );
            $res->{feeds} = [ map { At::Lexicon::app::bsky::feed::generatorView->new(%$_) } @{ $res->{feeds} } ] if defined $res->{feeds};
            $res;
        }

        method getActorLikes ( $actor, $limit //= (), $cursor //= () ) {
            $self->http->session // Carp::confess 'requires an authenticated client';
            Carp::cluck 'limit is too large' if defined $limit && $limit < 0;
            Carp::cluck 'limit is too small' if defined $limit && $limit > 100;
            my $res = $self->http->get( sprintf( '%s/xrpc/%s', $self->host(), 'app.bsky.feed.getActorLikes' ),
                { content => +{ actor => $actor, defined $limit ? ( limit => $limit ) : (), defined $cursor ? ( cursor => $cursor ) : () } } );
            $res->{feed} = [ map { At::Lexicon::app::bsky::feed::feedViewPost->new(%$_) } @{ $res->{feed} } ] if defined $res->{feed};
            $res;
        }

        method getPosts (@uris) {
            $self->http->session // Carp::confess 'requires an authenticated client';
            Carp::confess 'too many uris' if scalar @uris > 25;
            my $res = $self->http->get( sprintf( '%s/xrpc/%s', $self->host(), 'app.bsky.feed.getPosts' ), { content => +{ uris => \@uris } } );
            $res->{posts} = [ map { At::Lexicon::app::bsky::feed::postView->new(%$_) } @{ $res->{posts} } ] if defined $res->{posts};
            $res;
        }

        method getPostThread ( $uri, $depth //= (), $parentHeight //= () ) {
            $self->http->session // Carp::confess 'requires an authenticated client';
            Carp::confess 'depth is too low'         if defined $depth        && $depth < 0;
            Carp::confess 'depth is too high'        if defined $depth        && $depth > 1000;
            Carp::confess 'parentHeight is too low'  if defined $parentHeight && $parentHeight < 0;
            Carp::confess 'parentHeight is too high' if defined $parentHeight && $parentHeight > 1000;
            my $res = $self->http->get(
                sprintf( '%s/xrpc/%s', $self->host(), 'app.bsky.feed.getPostThread' ),
                {   content =>
                        +{ uri => $uri, defined $depth ? ( depth => $depth ) : (), defined $parentHeight ? ( parentHeight => $parentHeight ) : () }
                }
            );
            $res->{thread} = At::_topkg( $res->{thread}->{'$type'} )->new( %{ $res->{thread} } )
                if defined $res->{thread} && defined $res->{thread}{'$type'};
            $res;
        }

        method getLikes ( $uri, $cid //= (), $limit //= (), $cursor //= () ) {
            $self->http->session // Carp::confess 'requires an authenticated client';
            Carp::confess 'limit is too low'  if defined $limit && $limit < 1;
            Carp::confess 'limit is too high' if defined $limit && $limit > 100;
            my $res = $self->http->get(
                sprintf( '%s/xrpc/%s', $self->host(), 'app.bsky.feed.getLikes' ),
                {   content => +{
                        uri => $uri,
                        defined $cid ? ( cid => $cid ) : (), defined $limit ? ( limit => $limit ) : (), defined $cursor ? ( cursor => $cursor ) : ()
                    }
                }
            );
            $res->{likes} = [ map { At::Lexicon::app::bsky::feed::getLikes::like->new(%$_) } @{ $res->{likes} } ] if defined $res->{likes};
            $res;
        }

        method getListFeed ( $list, $limit //= (), $cursor //= () ) {
            $self->http->session // Carp::confess 'requires an authenticated client';
            Carp::confess 'limit is too low'  if defined $limit && $limit < 1;
            Carp::confess 'limit is too high' if defined $limit && $limit > 100;
            my $res = $self->http->get( sprintf( '%s/xrpc/%s', $self->host(), 'app.bsky.feed.getListFeed' ),
                { content => +{ list => $list, defined $limit ? ( limit => $limit ) : (), defined $cursor ? ( cursor => $cursor ) : () } } );
            $res->{feed} = [ map { At::Lexicon::app::bsky::feed::feedViewPost->new(%$_) } @{ $res->{feed} } ] if defined $res->{feed};
            $res;
        }

        method getFeedSkeleton ( $feed, $limit //= (), $cursor //= () ) {
            $self->http->session // Carp::confess 'requires an authenticated client';
            Carp::confess 'limit is too low'  if defined $limit && $limit < 1;
            Carp::confess 'limit is too high' if defined $limit && $limit > 100;
            my $res = $self->http->get( sprintf( '%s/xrpc/%s', $self->host(), 'app.bsky.feed.getFeedSkeleton' ),
                { content => +{ feed => $feed, defined $limit ? ( limit => $limit ) : (), defined $cursor ? ( cursor => $cursor ) : () } } );
            $res->{feed} = [ map { At::Lexicon::app::bsky::feed::skeletonFeedPost->new(%$_) } @{ $res->{feed} } ] if defined $res->{feed};
            $res;
        }

        method getFeedGenerator ($feed) {
            $self->http->session // Carp::confess 'requires an authenticated client';
            my $res = $self->http->get( sprintf( '%s/xrpc/%s', $self->host(), 'app.bsky.feed.getFeedGenerator' ), { content => +{ feed => $feed } } );
            $res->{view} = At::Lexicon::app::bsky::feed::generatorView->new( %{ $res->{view} } ) if defined $res->{view};
            $res;
        }

        method getFeedGenerators (@feeds) {
            $self->http->session // Carp::confess 'requires an authenticated client';
            my $res
                = $self->http->get( sprintf( '%s/xrpc/%s', $self->host(), 'app.bsky.feed.getFeedGenerators' ), { content => +{ feeds => \@feeds } } );
            $res->{feeds} = [ map { At::Lexicon::app::bsky::feed::generatorView->new(%$_) } @{ $res->{feeds} } ] if defined $res->{feeds};
            $res;
        }

        method getFeed ( $feed, $cursor //= () ) {
            $self->http->session // Carp::confess 'requires an authenticated client';
            my $res = $self->http->get(
                sprintf( '%s/xrpc/%s', $self->host(), 'app.bsky.feed.getFeed' ),
                { content => +{ feed => $feed, defined $cursor ? ( cursor => $cursor ) : () } }
            );
            $res->{feed} = [ map { At::Lexicon::app::bsky::feed::feedViewPost->new(%$_) } @{ $res->{feed} } ] if defined $res->{feed};
            $res;
        }

        method describeFeedGenerator () {
            $self->http->session // Carp::confess 'requires an authenticated client';
            my $res = $self->http->get( sprintf( '%s/xrpc/%s', $self->host(), 'app.bsky.feed.describeFeedGenerator' ) );
            $res->{did}   = At::Protocol::DID->new( uri => $res->{did} ) if defined $res->{did};
            $res->{feeds} = [ map { At::Lexicon::app::bsky::feed::describeFeedGenerator::feed->new(%$_) } @{ $res->{feeds} } ]
                if defined $res->{feeds};
            $res->{links} = At::Lexicon::app::bsky::feed::describeFeedGenerator::links->new( %{ $res->{links} } ) if defined $res->{links};
            $res;
        }
    }

    #~ class At::Lexicon::Bluesky::Graph
    {

        method getFollows ( $actor, $limit //= (), $cursor //= () ) {
            $self->http->session // Carp::confess 'requires an authenticated client';
            my $res = $self->http->get( sprintf( '%s/xrpc/%s', $self->host(), 'app.bsky.graph.getFollows' ),
                { content => +{ actor => $actor, defined $limit ? ( limit => $limit ) : (), defined $cursor ? ( cursor => $cursor ) : () } } );
            $res->{subject} = At::Lexicon::app::bsky::actor::profileView->new( %{ $res->{subject} } )               if defined $res->{subject};
            $res->{follows} = [ map { At::Lexicon::app::bsky::actor::profileView->new(%$_) } @{ $res->{follows} } ] if defined $res->{follows};
            $res;
        }

        method getFollowers ( $actor, $limit //= (), $cursor //= () ) {
            $self->http->session // Carp::confess 'requires an authenticated client';
            my $res = $self->http->get( sprintf( '%s/xrpc/%s', $self->host(), 'app.bsky.graph.getFollowers' ),
                { content => +{ actor => $actor, defined $limit ? ( limit => $limit ) : (), defined $cursor ? ( cursor => $cursor ) : () } } );
            $res->{subject}   = At::Lexicon::app::bsky::actor::profileView->new( %{ $res->{subject} } )                 if defined $res->{subject};
            $res->{followers} = [ map { At::Lexicon::app::bsky::actor::profileView->new(%$_) } @{ $res->{followers} } ] if defined $res->{followers};
            $res;
        }

        method getLists ( $actor, $limit //= (), $cursor //= () ) {
            $self->http->session // Carp::confess 'requires an authenticated client';
            my $res = $self->http->get( sprintf( '%s/xrpc/%s', $self->host(), 'app.bsky.graph.getLists' ),
                { content => +{ actor => $actor, defined $limit ? ( limit => $limit ) : (), defined $cursor ? ( cursor => $cursor ) : () } } );
            $res->{lists} = [ map { At::Lexicon::app::bsky::graph::listView->new(%$_) } @{ $res->{lists} } ] if defined $res->{lists};
            $res;
        }

        method getList ( $list, $limit //= (), $cursor //= () ) {
            $self->http->session // Carp::confess 'requires an authenticated client';
            my $res = $self->http->get( sprintf( '%s/xrpc/%s', $self->host(), 'app.bsky.graph.getList' ),
                { content => +{ list => $list, defined $limit ? ( limit => $limit ) : (), defined $cursor ? ( cursor => $cursor ) : () } } );
            $res->{list}  = At::Lexicon::app::bsky::graph::listView->new( %{ $res->{list} } )                    if defined $res->{list};
            $res->{items} = [ map { At::Lexicon::app::bsky::graph::listItemView->new(%$_) } @{ $res->{items} } ] if defined $res->{items};
            $res;
        }

        method getSuggestedFollowsByActor ($actor) {
            $self->http->session // Carp::confess 'requires an authenticated client';
            my $res = $self->http->get( sprintf( '%s/xrpc/%s', $self->host(), 'app.bsky.graph.getSuggestedFollowsByActor' ),
                { content => +{ actor => $actor } } );

            # current lexicon incorrectly claims this is a list of profileView objects
            $res->{suggestions} = [ map { At::Lexicon::app::bsky::actor::profileViewDetailed->new(%$_) } @{ $res->{suggestions} } ]
                if defined $res->{suggestions};
            $res;
        }

        method getBlocks ( $limit //= (), $cursor //= () ) {
            $self->http->session // Carp::confess 'requires an authenticated client';
            my $res = $self->http->get( sprintf( '%s/xrpc/%s', $self->host(), 'app.bsky.graph.getBlocks' ),
                { content => +{ defined $limit ? ( limit => $limit ) : (), defined $cursor ? ( cursor => $cursor ) : () } } );
            $res->{blocks} = [ map { At::Lexicon::app::bsky::graph::profileView->new(%$_) } @{ $res->{blocks} } ] if defined $res->{blocks};
            $res;
        }

        method getListBlocks ( $limit //= (), $cursor //= () ) {
            $self->http->session // Carp::confess 'requires an authenticated client';
            my $res = $self->http->get( sprintf( '%s/xrpc/%s', $self->host(), 'app.bsky.graph.getListBlocks' ),
                { content => +{ defined $limit ? ( limit => $limit ) : (), defined $cursor ? ( cursor => $cursor ) : () } } );
            $res->{lists} = [ map { At::Lexicon::app::bsky::graph::listView->new(%$_) } @{ $res->{lists} } ] if defined $res->{lists};
            $res;
        }

        method getMutes ( $limit //= (), $cursor //= () ) {
            $self->http->session // Carp::confess 'requires an authenticated client';
            my $res = $self->http->get( sprintf( '%s/xrpc/%s', $self->host(), 'app.bsky.graph.getMutes' ),
                { content => +{ defined $limit ? ( limit => $limit ) : (), defined $cursor ? ( cursor => $cursor ) : () } } );
            $res->{mutes} = [ map { At::Lexicon::app::bsky::actor::profileView->new(%$_) } @{ $res->{mutes} } ] if defined $res->{mutes};
            $res;
        }

        method getListMutes ( $limit //= (), $cursor //= () ) {
            $self->http->session // Carp::confess 'requires an authenticated client';
            my $res = $self->http->get( sprintf( '%s/xrpc/%s', $self->host(), 'app.bsky.graph.getListMutes' ),
                { content => +{ defined $limit ? ( limit => $limit ) : (), defined $cursor ? ( cursor => $cursor ) : () } } );
            $res->{lists} = [ map { At::Lexicon::app::bsky::graph::listView->new(%$_) } @{ $res->{lists} } ] if defined $res->{lists};
            $res;
        }

        method muteActor ($actor) {
            $self->http->session // Carp::confess 'requires an authenticated client';
            my $res = $self->http->post( sprintf( '%s/xrpc/%s', $self->host(), 'app.bsky.graph.muteActor' ), { content => +{ actor => $actor } } );
            $res->{success};
        }

        method unmuteActor ($actor) {
            $self->http->session // Carp::confess 'requires an authenticated client';
            my $res = $self->http->post( sprintf( '%s/xrpc/%s', $self->host(), 'app.bsky.graph.unmuteActor' ), { content => +{ actor => $actor } } );
            $res->{success};
        }

        method muteActorList ($list) {
            $self->http->session // Carp::confess 'requires an authenticated client';
            my $res = $self->http->post( sprintf( '%s/xrpc/%s', $self->host(), 'app.bsky.graph.muteActorList' ), { content => +{ list => $list } } );
            $res->{success};
        }

        method unmuteActorList ($list) {
            $self->http->session // Carp::confess 'requires an authenticated client';
            my $res
                = $self->http->post( sprintf( '%s/xrpc/%s', $self->host(), 'app.bsky.graph.unmuteActorList' ), { content => +{ list => $list } } );
            $res->{success};
        }
    }

    #~ class At::Lexicon::Bluesky::Notification
    {

        method listNotifications ( $seenAt //= (), $limit //= 50, $cursor //= () ) {
            $self->http->session // Carp::confess 'requires an authenticated client';
            $seenAt = At::Protocol::Timestamp->new( timestamp => $seenAt ) if defined $seenAt && builtin::blessed $seenAt;
            my $res = $self->http->get( sprintf( '%s/xrpc/%s', $self->host(), 'app.bsky.notification.listNotifications' ),
                { content => +{ limit => $limit, cursor => $cursor, seenAt => defined $seenAt ? $seenAt->_raw : undef } } );
            $res->{notifications} = [ map { At::Lexicon::app::bsky::notification->new(%$_) } @{ $res->{notifications} } ]
                if defined $res->{notifications};
            $res;
        }

        method getUnreadCount ( $seenAt //= () ) {
            $self->http->session // Carp::confess 'requires an authenticated client';
            $seenAt = At::Protocol::Timestamp->new( timestamp => $seenAt ) if defined $seenAt && builtin::blessed $seenAt;
            my $res = $self->http->get(
                sprintf( '%s/xrpc/%s', $self->host(), 'app.bsky.notification.getUnreadCount' ),
                { content => +{ defined $seenAt ? ( seenAt => $seenAt->_raw ) : () } }
            );
            $res;
        }

        method updateSeen ($seenAt) {
            $self->http->session // Carp::confess 'requires an authenticated client';
            $seenAt = At::Protocol::Timestamp->new( timestamp => $seenAt ) unless builtin::blessed $seenAt;
            my $res = $self->http->post( sprintf( '%s/xrpc/%s', $self->host(), 'app.bsky.notification.updateSeen' ),
                { content => +{ seenAt => $seenAt->_raw } } );
            $res->{success};
        }

        method registerPush ( $appId, $platform, $serviceDid, $token ) {
            $self->http->session // Carp::confess 'requires an authenticated client';
            my $res = $self->http->post( sprintf( '%s/xrpc/%s', $self->host(), 'app.bsky.notification.registerPush' ),
                { content => +{ appId => $appId, platform => $platform, serviceDid => $serviceDid, token => $token } } );
            $res->{success};
        }
    }

    #~ class At::Lexicon::Bluesky::Unspecced
    {

        method getPopularFeedGenerators ( $query //= (), $limit //= (), $cursor //= () ) {
            $self->http->session // Carp::confess 'requires an authenticated client';
            my $res = $self->http->get(
                sprintf( '%s/xrpc/%s', $self->host(), 'app.bsky.unspecced.getPopularFeedGenerators' ),
                {   content => +{
                        defined $query  ? ( query  => $query )  : (),
                        defined $limit  ? ( limit  => $limit )  : (),
                        defined $cursor ? ( cursor => $cursor ) : ()
                    }
                }
            );
            $res->{feeds} = [ map { At::Lexicon::app::bsky::feed::generatorView->new(%$_) } @{ $res->{feeds} } ] if defined $res->{feeds};
            $res;
        }

        method searchActorsSkeleton ( $query //= (), $typeahead //= (), $limit //= (), $cursor //= () ) {
            $self->http->session // Carp::confess 'requires an authenticated client';
            my $res = $self->http->get(
                sprintf( '%s/xrpc/%s', $self->host(), 'app.bsky.unspecced.searchActorsSkeleton' ),
                {   content => +{
                        defined $query     ? ( q         => $query )     : (),
                        defined $typeahead ? ( typeahead => $typeahead ) : (),
                        defined $limit     ? ( limit     => $limit )     : (),
                        defined $cursor    ? ( cursor    => $cursor )    : ()
                    }
                }
            );
            $res->{actors} = [ map { At::Lexicon::app::bsky::unspecced::skeletonSearchActor->new(%$_) } @{ $res->{actors} } ]
                if defined $res->{actors};
            $res;
        }

        method searchPostsSkeleton ( $query //= (), $limit //= (), $cursor //= () ) {
            $self->http->session // Carp::confess 'requires an authenticated client';
            my $res = $self->http->get(
                sprintf( '%s/xrpc/%s', $self->host(), 'app.bsky.unspecced.searchPostsSkeleton' ),
                {   content => +{
                        defined $query  ? ( q      => $query )  : (),
                        defined $limit  ? ( limit  => $limit )  : (),
                        defined $cursor ? ( cursor => $cursor ) : ()
                    }
                }
            );
            $res->{posts} = [ map { At::Lexicon::app::bsky::unspecced::skeletonSearchPost->new(%$_) } @{ $res->{posts} } ] if defined $res->{posts};
            $res;
        }
    }
};
1;
