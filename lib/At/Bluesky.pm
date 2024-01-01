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
                { content => +{ seenAt => defined $seenAt ? $seenAt->_raw : undef } }
            );
            $res;
        }

        method updateSeen ($seenAt) {
            $self->http->session // Carp::confess 'requires an authenticated client';
            $seenAt = At::Protocol::Timestamp->new( timestamp => $seenAt ) unless builtin::blessed $seenAt;
            my $res = $self->http->post( sprintf( '%s/xrpc/%s', $self->host(), 'app.bsky.notification.updateSeen' ),
                { content => +{ seenAt => $seenAt->_raw } } );
            $res;
        }

        method registerPush ( $appId, $platform, $serviceDid, $token ) {
            $self->http->session // Carp::confess 'requires an authenticated client';
            my $res = $self->http->post( sprintf( '%s/xrpc/%s', $self->host(), 'app.bsky.notification.registerPush' ),
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

    $bsky->getPreferences;

Get private preferences attached to the account.

On success, returns a new C<At::Lexicon::app::bsky::actor::preferences> object.

=head2 C<getProfile( ... )>

    $bsky->getProfile( 'sankor.bsky.social' );

Get detailed profile view of an actor.

On success, returns a new C<At::Lexicon::app::bsky::actor::profileViewDetailed> object.

=head2 C<getProfiles( ... )>

    $bsky->getProfiles( 'xkcd.com', 'marthawells.bsky.social' );

Get detailed profile views of multiple actors.

On success, returns a list of up to 25 new C<At::Lexicon::app::bsky::actor::profileViewDetailed> objects.

=head2 C<getSuggestions( [...] )>

    $bsky->getSuggestions( ); # grab 50 results

    my $res = $bsky->getSuggestions( 75 ); # limit number of results to 75

    $bsky->getSuggestions( 75, $res->{cursor} ); # look for the next group of 75 results

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

    $bsky->searchActorsTypeahead( 'joh' ); # grab 10 results

    $bsky->searchActorsTypeahead( 'joh', 30 ); # limit number of results to 30

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

    $bsky->searchActors( 'john' ); # grab 25 results

    my $res = $bsky->searchActors( 'john', 30 ); # limit number of results to 30

    $bsky->searchActors( 'john', 30, $res->{cursor} ); # next 30 results

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

    $bsky->putPreferences( { '$type' => 'app.bsky.actor#adultContentPref', enabled => false } ); # pass along a coerced adultContentPref object

Set the private preferences attached to the account. This may be an C<At::Lexicon::app::bsky::actor::adultContentPref>,
C<At::Lexicon::app::bsky::actor::contentLabelPref>, C<At::Lexicon::app::bsky::actor::savedFeedsPref>,
C<At::Lexicon::app::bsky::actor::personalDetailsPref>, C<At::Lexicon::app::bsky::actor::feedViewPref>, or
C<At::Lexicon::app::bsky::actor::threadViewPref>. They're coerced if not already objects.

On success, returns a true value.

=head1 Feed Methods

Feeds are lists or collections of content. A timeline of posts, etc.

=head2 C<getSuggestedFeeds( [...] )>

    $bsky->getSuggestedFeeds( );

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

    $bsky->getTimeline( );

    $bsky->getTimeline( 'reverse-chronological', 30 );

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

    $bsky->searchPosts( "perl" );

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

    $bsky->getAuthorFeed( "bsky.app" );

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

    $bsky->getRepostedBy( 'at://did:plc:z72i7hdynmk6r22z27h6tvur/app.bsky.feed.post/3kghpdkfnsk2i' );

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

    $bsky->getActorFeeds( 'bsky.app' );

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

    $bsky->getActorLikes( 'bsky.app' );

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

    $bsky->getPosts( 'at://did:plc:ewvi7nxzyoun6zhxrhs64oiz/app.bsky.feed.post/3kftlbujmfk24' );

Get a view of an actor's feed.

Expected parameters include:

=over

=item C<uris> - required

List of C<at://> URIs. No more than 25 at a time.

=back

On success, returns a list of posts as C<At::Lexicon::app::bsky::feed::postView> objects.

=head2 C<getPostThread( ..., [...] )>

    $bsky->getPostThread( 'at://did:plc:ewvi7nxzyoun6zhxrhs64oiz/app.bsky.feed.post/3kftlbujmfk24' );

Get posts in a thread.

Expected parameters include:

=over

=item C<uri> - required

An C<at://> URI.

=item C<depth>

Integer. Maximum value: 1000, Minimum value: 0, Default: 6.

=item C<parentHeight>

Integer. Maximum value: 1000, Minimum value: 0, Default: 80.

=back

On success, returns the thread containing replies as a new C<At::Lexicon::app::bsky::feed::threadViewPost> object.

=head2 C<getLikes( ..., [...] )>

    $bsky->getLikes( 'at://did:plc:ewvi7nxzyoun6zhxrhs64oiz/app.bsky.feed.post/3kftlbujmfk24' );

Get the list of likes.

Expected parameters include:

=over

=item C<uri> - required

=item C<cid>

=item C<limit>

The number of likes to return. Min. is 1, max is 100, 50 is the default.

=item C<cursor>

=back

On success, returns the original URI, a list of likes as C<At::Lexicon::app::bsky::feed::getLikes::like> objects and
(optionally) a cursor, and the original cid.

=head2 C<getListFeed( ..., [...] )>

    $bsky->getListFeed( 'at://did:plc:kyttpb6um57f4c2wep25lqhq/app.bsky.graph.list/3k4diugcw3k2p' );

Get a view of a recent posts from actors in a list.

Expected parameters include:

=over

=item C<list> - required

=item C<limit>

The number of results to return. Min. is 1, max is 100, 50 is the default.

=item C<cursor>

=back

On success, returns feed containing a list of C<At::Lexicon::app::bsky::feed::feedViewPost> objects and (optionally) a
cursor.

=head2 C<getFeedSkeleton( ..., [...] )>

    $bsky->getFeedSkeleton( 'at://did:plc:kyttpb6um57f4c2wep25lqhq/app.bsky.graph.list/3k4diugcw3k2p' );

Get a skeleton of a feed provided by a feed generator.

Expected parameters include:

=over

=item C<feed> - required

=item C<limit>

The number of results to return. Min. is 1, max is 100, 50 is the default.

=item C<cursor>

=back

On success, returns a feed containing a list of C<At::Lexicon::app::bsky::feed::skeletonFeedPost> objects and
(optionally) a cursor.

=head2 C<getFeedGenerator( ... )>

    $bsky->getFeedGenerator( 'at://did:plc:kyttpb6um57f4c2wep25lqhq/app.bsky.feed.generator/aaalfodybabzy' );

Get information about a feed generator.

Expected parameters include:

=over

=item C<feed> - required

=back

On success, returns a C<At::Lexicon::app::bsky::feed::generatorView> object and booleans indicating the feed's online
status and validity.

=head2 C<getFeedGenerators( ... )>

    $bsky->getFeedGenerators( 'at://did:plc:kyttpb6um57f4c2wep25lqhq/app.bsky.feed.generator/aaalfodybabzy', 'at://did:plc:eaf...' );

Get information about a list of feed generators.

Expected parameters include:

=over

=item C<feeds> - required

=back

On success, returns a list of feeds as new C<At::Lexicon::app::bsky::feed::generatorView> objects.

=head2 C<getFeed( ..., [...] )>

    $bsky->getFeed( 'at://did:plc:kyttpb6um57f4c2wep25lqhq/app.bsky.graph.list/3k4diugcw3k2p' );

Get a hydrated feed from an actor's selected feed generator.

Expected parameters include:

=over

=item C<feed> - required

=item C<cursor>

=back

On success, returns feed containing a list of C<At::Lexicon::app::bsky::feed::feedViewPost> objects and (optionally) a
cursor.




















































































































































































=head1 Graph Methods

Methods related to the Bluesky social graph.

=head2 C<getFollows( ..., [ ... ] )>

    $bsky->getFollows('sankor.bsky.social');

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

    $bsky->getFollowers('sankor.bsky.social');

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

    $bsky->getLists('sankor.bsky.social');

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

    $bsky->getList('at://did:plc:.../app.bsky.graph.list/...');

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

    $bsky->getSuggestedFollowsByActor('sankor.bsky.social');

Get suggested follows related to a given actor.

Expected parameters include:

=over

=item C<actor>

=back

On success, returns a list of C<At::Lexicon::app::bsky::actor::profileViewDetailed> objects.

=head2 C<getBlocks( [ ... ] )>

    $bsky->getBlocks( );

Get a list of who the actor is blocking.

Expected parameters include:

=over

=item C<limit> - optional

Maximum of 100, minimum of 1, and 50 is the default.

=item C<cursor> - optional

=back

On success, returns a list of C<At::Lexicon::app::bsky::actor::profileView> objects.

=head2 C<getListBlocks( [ ... ] )>

    $bsky->getListBlocks( );

Get lists that the actor is blocking.

Expected parameters include:

=over

=item C<limit> - optional

Maximum of 100, minimum of 1, and 50 is the default.

=item C<cursor> - optional

=back

On success, returns a list of C<At::Lexicon::app::bsky::graph::listView> objects and, potentially, a cursor.

=head2 C<getMutes( [ ... ] )>

    $bsky->getMutes( );

Get a list of who the actor mutes.

Expected parameters include:

=over

=item C<limit> - optional

Maximum of 100, minimum of 1, and 50 is the default.

=item C<cursor> - optional

=back

On success, returns a list of C<At::Lexicon::app::bsky::actor::profileView> objects.

=head2 C<getListMutes( [ ... ] )>

    $bsky->getListMutes( );

Get lists that the actor is muting.

Expected parameters include:

=over

=item C<limit> - optional

Maximum of 100, minimum of 1, and 50 is the default.

=item C<cursor> - optional

=back

On success, returns a list of C<At::Lexicon::app::bsky::graph::listView> objects and, potentially, a cursor.

=head2 C<muteActor( ... )>

    $bsky->muteActor( 'sankor.bsky.social' );

Mute an actor by DID or handle.

Expected parameters include:

=over

=item C<actor>

Person to mute.

=back

=head2 C<unmuteActor( ... )>

    $bsky->unmuteActor( 'sankor.bsky.social' );

Unmute an actor by DID or handle.

Expected parameters include:

=over

=item C<actor>

Person to mute.

=back

=head2 C<muteActorList( ... )>

    $bsky->muteActorList( 'at://...' );

Mute a list of actors.

Expected parameters include:

=over

=item C<list>

=back

=head2 C<unmuteActorList( ... )>

    $bsky->unmuteActorList( 'at://...' );

Unmute a list of actors.

Expected parameters include:

=over

=item C<list>

=back

=head1 Notification Methods

Notifications keep you up to date.

=head2 C<listNotifications( [...] )>

    $bsky->listNotifications( );

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

    $bsky->getUnreadCount( );

Get the count of unread notifications.

Expected parameters include:

=over

=item C<seenAt>

A timestamp.

=back

On success, returns a count of unread notifications.

=head2 C<updateSeen( ... )>

    $bsky->updateSeen( time );

Notify server that the user has seen notifications.

Expected parameters include:

=over

=item C<seenAt> - required

A timestamp.

=back

=head2 C<registerPush( [...] )>

    $bsky->registerPush(

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

Bluesky ios cid reposters reposts booleans online

=end stopwords

=cut
