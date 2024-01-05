package At 0.02 {
    use v5.38;
    no warnings 'experimental::class', 'experimental::builtin', 'experimental::for_list';    # Be quiet.
    use feature 'class';
    use experimental 'try';
    #
    use At::Lexicon::com::atproto::label;
    use At::Lexicon::com::atproto::admin;
    use At::Lexicon::com::atproto::moderation;

    #~ |---------------------------------------|
    #~ |------3-33-----------------------------|
    #~ |-5-55------4-44-5-55----353--3-33-/1~--|
    #~ |---------------------335---33----------|
    class At 1.00 {
        field $http //= Mojo::UserAgent->can('start') ? At::UserAgent::Mojo->new() : At::UserAgent::Tiny->new();
        method http {$http}
        field $host : param = ();
        field $repo : param = ();
        field $identifier : param //= ();
        field $password : param   //= ();
        #
        field $did : param = ();    # do not allow arg to new

        #
        method host {
            return $host if defined $host;
            use Carp qw[confess];
            confess 'You must provide a host or perhaps you wanted At::Bluesky';
        }
        ## Internals
        sub _now {
            At::Protocol::Timestamp->new( timestamp => time );
        }
        ADJUST {
            $host = $self->host() unless defined $host;
            if ( defined $host ) {
                $host = 'https://' . $host unless $host =~ /^https?:/;
                $host = URI->new($host)    unless builtin::blessed $host;
                if ( defined $identifier && defined $password ) {    # auto-login
                    my $session = $self->createSession( $identifier, $password );
                    $http->set_session($session);
                    $did = At::Protocol::DID->new( uri => $http->session->did->_raw );
                }
            }
        }

        #~ class At::Lexicon::AtProto::Server
        {
            use At::Lexicon::com::atproto::server;

            method createSession ( $identifier, $password ) {
                my $res = $self->http->post(
                    sprintf( '%s/xrpc/%s', $self->host, 'com.atproto.server.createSession' ),
                    { content => +{ identifier => $identifier, password => $password } }
                );
                $res->{handle}         = At::Protocol::Handle->new( id => $res->{handle} ) if defined $res->{handle};
                $res->{did}            = At::Protocol::DID->new( uri => $res->{did} )      if defined $res->{did};
                $res->{emailConfirmed} = !!$res->{emailConfirmed} if defined $res->{emailConfirmed} && builtin::blessed $res->{emailConfirmed};
                $res;
            }

            method describeServer () {    # functions without auth session
                my $res = $self->http->get( sprintf( '%s/xrpc/%s', $self->host(), 'com.atproto.server.describeServer' ) );
                $res->{links} = At::Lexicon::com::atproto::server::describeServer::links->new( %{ $res->{links} } ) if defined $res->{links};
                $res;
            }

            method listAppPasswords () {
                $self->http->session // Carp::confess 'requires an authenticated client';
                my $res = $self->http->get( sprintf( '%s/xrpc/%s', $self->host(), 'com.atproto.server.listAppPasswords' ) );
                $res->{passwords} = [ map { $_ = At::Lexicon::com::atproto::server::listAppPasswords::appPassword->new(%$_) } @{ $res->{passwords} } ]
                    if defined $res->{passwords};
                $res;
            }

            method getSession () {
                $self->http->session // Carp::confess 'requires an authenticated client';
                my $res = $self->http->get( sprintf( '%s/xrpc/%s', $self->host(), 'com.atproto.server.getSession' ) );
                $res->{handle}         = At::Protocol::Handle->new( id => $res->{handle} ) if defined $res->{handle};
                $res->{did}            = At::Protocol::DID->new( uri => $res->{did} )      if defined $res->{did};
                $res->{emailConfirmed} = !!$res->{emailConfirmed} if defined $res->{emailConfirmed} && builtin::blessed $res->{emailConfirmed};
                $res;
            }

            method getAccountInviteCodes ( $includeUsed //= (), $createAvailable //= () ) {
                $self->http->session // Carp::confess 'requires an authenticated client';
                my $res = $self->http->get(
                    sprintf( '%s/xrpc/%s', $self->host(), 'com.atproto.server.getAccountInviteCodes' ),
                    {   content => +{
                            defined $includeUsed     ? ( includeUsed     => $includeUsed )     : (),
                            defined $createAvailable ? ( createAvailable => $createAvailable ) : ()
                        }
                    }
                );
                $res->{codes} = [ map { At::Lexicon::com::atproto::server::inviteCode->new(%$_) } @{ $res->{codes} } ] if defined $res->{codes};
                $res;
            }

            method updateEmail ( $email, $token //= () ) {
                $self->http->session // Carp::confess 'requires an authenticated client';
                my $res = $self->http->post(
                    sprintf( '%s/xrpc/%s', $self->host(), 'com.atproto.server.updateEmail' ),
                    { content => +{ email => $email, defined $token ? ( token => $token ) : () } }
                );
                $res;
            }

            method requestEmailUpdate ($tokenRequired) {
                $self->http->session // Carp::confess 'requires an authenticated client';
                my $res = $self->http->post( sprintf( '%s/xrpc/%s', $self->host(), 'com.atproto.server.requestEmailUpdate' ),
                    { content => +{ tokenRequired => !!$tokenRequired } } );
                $res;
            }

            method revokeAppPassword ($name) {
                $self->http->session // Carp::confess 'requires an authenticated client';
                my $res = $self->http->post( sprintf( '%s/xrpc/%s', $self->host(), 'com.atproto.server.revokeAppPassword' ),
                    { content => +{ name => $name } } );
                $res;
            }

            method resetPassword ( $token, $password ) {
                $self->http->session // Carp::confess 'requires an authenticated client';
                my $res = $self->http->post(
                    sprintf( '%s/xrpc/%s', $self->host(), 'com.atproto.server.resetPassword' ),
                    { content => +{ token => $token, password => $password } }
                );
                $res;
            }

            method reserveSigningKey ($did) {
                $self->http->session // Carp::confess 'requires an authenticated client';
                my $res = $self->http->post( sprintf( '%s/xrpc/%s', $self->host(), 'com.atproto.server.reserveSigningKey' ),
                    { content => +{ defined $did ? ( did => $did ) : () } } );
                $res;
            }

            method requestPasswordReset ($email) {
                $self->http->session // Carp::confess 'requires an authenticated client';
                my $res = $self->http->post( sprintf( '%s/xrpc/%s', $self->host(), 'com.atproto.server.requestPasswordReset' ),
                    { content => +{ email => $email } } );
                $res;
            }

            method requestEmailConfirmation ( ) {
                $self->http->session // Carp::confess 'requires an authenticated client';
                my $res = $self->http->post( sprintf( '%s/xrpc/%s', $self->host(), 'com.atproto.server.requestEmailConfirmation' ) );
                $res;
            }

            method requestAccountDelete ( ) {
                $self->http->session // Carp::confess 'requires an authenticated client';
                my $res = $self->http->post( sprintf( '%s/xrpc/%s', $self->host(), 'com.atproto.server.requestAccountDelete' ) );
                $res;
            }

            method deleteSession ( ) {
                $self->http->session // Carp::confess 'requires an authenticated client';
                my $res = $self->http->post( sprintf( '%s/xrpc/%s', $self->host(), 'com.atproto.server.deleteSession' ) );
                $res;
            }

            method deleteAccount ( $did, $password, $token ) {
                $self->http->session // Carp::confess 'requires an authenticated client';
                my $res = $self->http->post(
                    sprintf( '%s/xrpc/%s', $self->host(), 'com.atproto.server.deleteAccount' ),
                    { content => +{ did => $did, password => $password, token => $token } }
                );
                $res;
            }

            method createInviteCodes ( $codeCount, $useCount, $forAccounts //= () ) {
                $self->http->session // Carp::confess 'requires an authenticated client';
                my $res = $self->http->post(
                    sprintf( '%s/xrpc/%s', $self->host(), 'com.atproto.server.createInviteCodes' ),
                    {   content => +{
                            codeCount => $codeCount,
                            useCount  => $useCount,
                            defined $forAccounts ? ( forAccounts => [ map { $_ = $_->_raw if builtin::blessed $_ } @$forAccounts ] ) : ()
                        }
                    }
                );
                $res->{codes} = [ map { At::Lexicon::com::atproto::server::createInviteCodes::accountCodes->new(%$_) } @{ $res->{codes} } ]
                    if defined $res->{codes};
                $res;
            }

            method createInviteCode ( $useCount, $forAccount //= () ) {
                $self->http->session // Carp::confess 'requires an authenticated client';
                my $res = $self->http->post(
                    sprintf( '%s/xrpc/%s', $self->host(), 'com.atproto.server.createInviteCode' ),
                    {   content => +{
                            useCount => $useCount,
                            defined $forAccount ? ( forAccount => builtin::blessed $forAccount? $forAccount->_raw : $forAccount ) : ()
                        }
                    }
                );
                $res;
            }

            method createAppPassword ($name) {
                $self->http->session // Carp::confess 'requires an authenticated client';
                my $res = $self->http->post( sprintf( '%s/xrpc/%s', $self->host(), 'com.atproto.server.createAppPassword' ),
                    { content => +{ name => $name } } );
                $res->{appPassword} = At::Lexicon::com::atproto::server::createAppPassword::appPassword->new( %{ $res->{appPassword} } )
                    if defined $res->{appPassword};
                $res;
            }

            method createAccount ( $handle, $email //= (), $password //= (), $inviteCode //= (), $did //= (), $recoveryKey //= (), $plcOP //= () ) {
                Carp::cluck 'likely do not want an authenticated client' if defined $self->http->session;
                my $res = $self->http->post(
                    sprintf( '%s/xrpc/%s', $self->host(), 'com.atproto.server.createAccount' ),
                    {   content => +{
                            handle => $handle,
                            defined $email       ? ( email       => $email )       : (), defined $did      ? ( did      => $did )      : (),
                            defined $inviteCode  ? ( inviteCode  => $inviteCode )  : (), defined $password ? ( password => $password ) : (),
                            defined $recoveryKey ? ( recoveryKey => $recoveryKey ) : (), defined $plcOP    ? ( plcOP    => $plcOP )    : ()
                        }
                    }
                );
                $res->{handle} = At::Protocol::Handle->new( id => $res->{handle} ) if defined $res->{handle};
                $res->{did}    = At::Protocol::DID->new( uri => $res->{did} )      if defined $res->{did};
                $res;
            }

            method confirmEmail ( $email, $token ) {
                my $res = $self->http->post( sprintf( '%s/xrpc/%s', $self->host(), 'com.atproto.server.confirmEmail' ),
                    { content => +{ email => $email, token => $token } } );
                $res;
            }
        }

        #~ class At::Lexicon::AtProto::Label
        {
            use At::Lexicon::com::atproto::label;

            method queryLabels ( $uriPatterns, $sources //= (), $limit //= (), $cursor //= () ) {
                my $res = $self->http->get(
                    sprintf( '%s/xrpc/%s', $self->host, 'com.atproto.label.queryLabels' ),
                    {   content => +{
                            uriPatterns => $uriPatterns,
                            defined $sources ? ( sources => $sources ) : (), defined $limit ? ( limit => $limit ) : (),
                            defined $cursor ? ( cursor => $cursor ) : ()
                        }
                    }
                );
                $res->{labels} = [ map { At::Lexicon::com::atproto::label->new(%$_) } @{ $res->{labels} } ] if defined $res->{labels};
                $res;
            }

            method subscribeLabels ( $cb, $cursor //= () ) {
                my $res = $self->http->websocket(
                    sprintf( 'wss://%s/xrpc/%s%s', $self->host, 'com.atproto.label.subscribeLabels', defined $cursor ? '?cursor=' . $cursor : '' ),

                    #~ sprintf( '%s/xrpc/%s', $self->host, 'com.atproto.label.subscribeLabels' ),
                    #~ { content => +{ defined $cursor ? ( cursor => $cursor ) : () } }
                    $cb
                );
                $res;
            }

            method subscribeLabels_p ( $cb, $cursor //= () ) {    # return a Mojo::Promise
                $self->http->agent->websocket_p(
                    sprintf( 'wss://%s/xrpc/%s%s', $self->host, 'com.atproto.label.subscribeLabels', defined $cursor ? '?cursor=' . $cursor : '' ), )
                    ->then(
                    sub ($tx) {
                        my $promise = Mojo::Promise->new;
                        $tx->on( finish => sub { $promise->resolve } );
                        $tx->on(
                            message => sub ( $tx, $msg ) {
                                state $decoder //= CBOR::Free::SequenceDecoder->new()->set_tag_handlers( 42 => sub { } );
                                my $head = $decoder->give($msg);
                                my $body = $decoder->get;
                                $cb->( $promise, $$body );
                            }
                        );
                        return $promise;
                    }
                )->catch(
                    sub ($err) {
                        Carp::confess "WebSocket error: $err";
                    }
                );
            }
        }

        #     class At::Lexicon::AtProto::Repo
        {
            use At::Lexicon::com::atproto::repo;

            sub _mangle ($type) {
                use Module::Load;
                my @package = ( 'At', 'Lexicon', split /\./, $type );
                my $class   = join '::', @package;
                pop @package;
                my $package = join '::', @package;
                load $package unless $package->can('new');
                return $class;
            }

            method createRecord (%args) {    # https://atproto.com/blog/create-post
                use Carp qw[confess];
                if ( !builtin::blessed $args{record} ) {
                    my $package = _mangle( $args{record}{'$type'} );
                    delete $args{record}{'$type'};
                    $args{record} = $package->new( %{ $args{record} } )->_raw;
                }
                $self->http->session // confess 'creating a post requires an authenticated client';

                #~ use Data::Dump;
                #~ ddx { content => { repo => $did->_raw, %args } };
                #~ ...;
                my $res = $self->http->post( sprintf( '%s/xrpc/%s', $self->host(), 'com.atproto.repo.createRecord' ),
                    { content => { repo => $did->_raw, %args } } );
                $res->{uri} = URI->new( $res->{uri} ) if defined $res->{uri};
                $res;
            }
        }

        #~ class At::Lexicon::AtProto::Admin
        {

            method admin_deleteAccount ($did) {
                $self->http->session // Carp::confess 'requires an authenticated client';
                my $res
                    = $self->http->post( sprintf( '%s/xrpc/%s', $self->host, 'com.atproto.admin.deleteAccount' ), { content => +{ did => $did } } );
                $res->{success};
            }

            method admin_disableAccountInvites ( $account, $note //= () ) {
                $self->http->session // Carp::confess 'requires an authenticated client';
                my $res = $self->http->post(
                    sprintf( '%s/xrpc/%s', $self->host, 'com.atproto.admin.disableAccountInvites' ),
                    { content => +{ account => $account, defined $note ? ( note => $note ) : () } }
                );
                $res->{success};
            }

            method admin_disableInviteCodes ( $codes //= (), $accounts //= () ) {
                $self->http->session // Carp::confess 'requires an authenticated client';
                my $res = $self->http->post( sprintf( '%s/xrpc/%s', $self->host, 'com.atproto.admin.disableInviteCodes' ),
                    { content => +{ defined $codes ? ( codes => $codes ) : (), defined $accounts ? ( accounts => $accounts ) : () } } );
                $res->{success};
            }

            method admin_emitModerationEvent ( $event, $subject, $createdBy, $subjectBlobCids //= () ) {
                $self->http->session // Carp::confess 'requires an authenticated client';
                $event     = At::_topkg( $event->{'$type'} )->new(%$event)     if !builtin::blessed $event   && defined $event->{'$type'};
                $subject   = At::_topkg( $subject->{'$type'} )->new(%$subject) if !builtin::blessed $subject && defined $subject->{'$type'};
                $createdBy = At::Protocol::DID->new( uri => $createdBy ) unless builtin::blessed $createdBy;
                my $res = $self->http->post(
                    sprintf( '%s/xrpc/%s', $self->host, 'com.atproto.admin.emitModerationEvent' ),
                    {   content => +{
                            event     => $event->_raw,
                            subject   => $subject->_raw,
                            createdBy => $createdBy->_raw,
                            defined $subjectBlobCids ? ( subjectBlobCids => $subjectBlobCids ) : ()
                        }
                    }
                );
                $res = At::Lexicon::com::atproto::admin::modEventView->new(%$res) if defined $res;
                $res;
            }

            method admin_enableAccountInvites ( $account, $note //= () ) {
                $self->http->session // Carp::confess 'requires an authenticated client';
                my $res = $self->http->post(
                    sprintf( '%s/xrpc/%s', $self->host, 'com.atproto.admin.enableAccountInvites' ),
                    { content => +{ account => $account, defined $note ? ( note => $note ) : (), } }
                );
                $res->{success};
            }

            method admin_getAccountInfo ($did) {
                $self->http->session // Carp::confess 'requires an authenticated client';
                my $res
                    = $self->http->get( sprintf( '%s/xrpc/%s', $self->host, 'com.atproto.admin.getAccountInfo' ), { content => +{ did => $did } } );
                $res = At::Lexicon::com::atproto::admin::accountView->new(%$res) if defined $res;
                $res;
            }

            method admin_getInviteCodes ( $sort //= (), $limit //= (), $cursor //= () ) {
                $self->http->session // Carp::confess 'requires an authenticated client';
                my $res = $self->http->get(
                    sprintf( '%s/xrpc/%s', $self->host, 'com.atproto.admin.getInviteCodes' ),
                    {   content => +{
                            defined $sort   ? ( sort   => $sort )   : (),
                            defined $limit  ? ( limit  => $limit )  : (),
                            defined $cursor ? ( cursor => $cursor ) : ()
                        }
                    }
                );
                $res->{codes} = [ map { At::Lexicon::com::atproto::server::inviteCode->new(%$_) } @{ $res->{codes} } ] if defined $res->{codes};
                $res;
            }

            method admin_getModerationEvent ($id) {
                $self->http->session // Carp::confess 'requires an authenticated client';
                my $res
                    = $self->http->get( sprintf( '%s/xrpc/%s', $self->host, 'com.atproto.admin.getModerationEvent' ), { content => +{ id => $id } } );
                $res = At::Lexicon::com::atproto::admin::modEventViewDetail->new(%$res) if defined $res;
                $res;
            }

            method admin_getRecord ( $uri, $cid //= () ) {
                $self->http->session // Carp::confess 'requires an authenticated client';
                my $res = $self->http->get(
                    sprintf( '%s/xrpc/%s', $self->host, 'com.atproto.admin.getRecord' ),
                    { content => +{ uri => $uri, defined $cid ? ( cid => $cid ) : () } }
                );
                $res = At::Lexicon::com::atproto::admin::recordViewDetail->new(%$res) if defined $res;
                $res;
            }

            method admin_getRepo ($did) {
                $self->http->session // Carp::confess 'requires an authenticated client';
                my $res = $self->http->get( sprintf( '%s/xrpc/%s', $self->host, 'com.atproto.admin.getRepo' ), { content => +{ did => $did } } );
                $res = At::Lexicon::com::atproto::admin::repoViewDetail->new(%$res) if defined $res;
                $res;
            }

            method admin_getSubjectStatus ( $did //= (), $uri //= (), $blob //= () ) {
                $self->http->session // Carp::confess 'requires an authenticated client';
                my $res = $self->http->get(
                    sprintf( '%s/xrpc/%s', $self->host, 'com.atproto.admin.getSubjectStatus' ),
                    {   content =>
                            +{ defined $did ? ( did => $did ) : (), defined $uri ? ( uri => $uri ) : (), defined $blob ? ( blob => $blob ) : () }
                    }
                );
                $res->{subject} = At::_topkg( $res->{subject}->{'$type'} )->new( %{ $res->{subject} } )
                    if defined $res->{subject} && !builtin::blessed $res->{subject} && defined $res->{subject}->{'$type'};
                $res->{takedown} = At::Lexicon::com::atproto::admin::statusAttr->new( %{ $res->{takedown} } ) if defined $res->{takedown};
                $res;
            }

            method admin_queryModerationEvents (
                $types                 //= (),
                $createdBy             //= (),
                $sortDirection         //= (),
                $subject               //= (),
                $includeUsed           //= (),
                $includeAllUserRecords //= (),
                $limit                 //= (),
                $cursor                //= ()
            ) {
                $self->http->session // Carp::confess 'requires an authenticated client';
                $createdBy = At::Protocol::DID->new( uri => $createdBy ) if defined $createdBy && !builtin::blessed $createdBy;
                $subject   = URI->new($subject)                          if defined $subject   && !builtin::blessed $subject;
                my $res = $self->http->get(
                    sprintf( '%s/xrpc/%s', $self->host, 'com.atproto.admin.queryModerationEvents' ),
                    {   content => +{
                            defined $types                 ? ( types                 => $types )                 : (),
                            defined $createdBy             ? ( createdBy             => $createdBy->_raw )       : (),
                            defined $sortDirection         ? ( sortDirection         => $sortDirection )         : (),
                            defined $subject               ? ( subject               => $subject->as_string )    : (),
                            defined $includeAllUserRecords ? ( includeAllUserRecords => $includeAllUserRecords ) : (),
                            defined $limit                 ? ( limit                 => $limit )                 : (),
                            defined $cursor                ? ( cursor                => $cursor )                : ()
                        }
                    }
                );
                $res->{events} = [ map { At::Lexicon::com::atproto::admin::modEventView->new(%$_) } @{ $res->{events} } ] if defined $res->{events};
                $res;
            }

            method admin_queryModerationStatuses (
                $subject        //= (),
                $comment        //= (),
                $reportedAfter  //= (),
                $reportedBefore //= (),
                $reviewedAfter  //= (),
                $reviewedBefore //= (),
                $includeMuted   //= (),
                $reviewState    //= (),
                $ignoreSubjects //= (),
                $lastReviewedBy //= (),
                $sortField      //= (),
                $sortDirection  //= (),
                $takendown      //= (),
                $limit          //= (),
                $cursor         //= ()
            ) {
                $self->http->session // Carp::confess 'requires an authenticated client';
                $subject       = URI->new($subject) if defined $subject && !builtin::blessed $subject;
                $reportedAfter = At::Protocol::Timestamp->new( timestamp => $reportedAfter )
                    if defined $reportedAfter && !builtin::blessed $reportedAfter;
                $reportedBefore = At::Protocol::Timestamp->new( timestamp => $reportedBefore )
                    if defined $reportedBefore && !builtin::blessed $reportedBefore;
                $reviewedAfter = At::Protocol::Timestamp->new( timestamp => $reviewedAfter )
                    if defined $reviewedAfter && !builtin::blessed $reviewedAfter;
                $reviewedBefore = At::Protocol::Timestamp->new( timestamp => $reviewedBefore )
                    if defined $reviewedBefore && !builtin::blessed $reviewedBefore;
                $ignoreSubjects = [ map { $_ = URI->new($_) unless builtin::blessed $_ } @{$ignoreSubjects} ];
                $lastReviewedBy = At::Protocol::DID->new( uri => $lastReviewedBy ) if defined $lastReviewedBy && !builtin::blessed $lastReviewedBy;
                my $res = $self->http->get(
                    sprintf( '%s/xrpc/%s', $self->host, 'com.atproto.admin.queryModerationStatuses' ),
                    {   content => +{
                            defined $subject        ? ( subject        => $subject->as_string )                        : (),
                            defined $comment        ? ( comment        => $comment )                                   : (),
                            defined $reportedAfter  ? ( reportedAfter  => $reportedAfter->_raw )                       : (),
                            defined $reportedBefore ? ( reportedBefore => $reportedBefore->_raw )                      : (),
                            defined $reviewedAfter  ? ( reviewedAfter  => $reviewedAfter->_raw )                       : (),
                            defined $reviewedBefore ? ( reviewedBefore => $reviewedBefore->_raw )                      : (),
                            defined $includeMuted   ? ( includeMuted   => \!!$includeMuted )                           : (),
                            defined $reviewState    ? ( reviewState    => $reviewState )                               : (),
                            defined $ignoreSubjects ? ( ignoreSubjects => [ map { $_->as_string } @$ignoreSubjects ] ) : (),
                            defined $lastReviewedBy ? ( lastReviewedBy => $lastReviewedBy->_raw )                      : (),
                            defined $sortField      ? ( sortField      => $sortField )                                 : (),
                            defined $sortDirection  ? ( sortDirection  => $sortDirection )                             : (),
                            defined $takendown      ? ( takendown      => \!!$takendown )                              : (),
                            defined $limit          ? ( limit          => $limit )                                     : (),
                            defined $cursor         ? ( cursor         => $cursor )                                    : ()
                        }
                    }
                );
                $res->{subjectStatuses} = [ map { At::Lexicon::com::atproto::admin::subjectStatusView->new(%$_) } @{ $res->{subjectStatuses} } ]
                    if defined $res->{subjectStatuses};
                $res;
            }

            method admin_searchRepos ( $query //= (), $limit //= (), $cursor //= () ) {
                $self->http->session // Carp::confess 'requires an authenticated client';
                my $res = $self->http->get(
                    sprintf( '%s/xrpc/%s', $self->host, 'com.atproto.admin.searchRepos' ),
                    {   content => +{
                            defined $query  ? ( q      => $query )  : (),
                            defined $limit  ? ( limit  => $limit )  : (),
                            defined $cursor ? ( cursor => $cursor ) : ()
                        }
                    }
                );
                $res->{repos} = [ map { At::Lexicon::com::atproto::admin::repoView->new(%$_) } @{ $res->{repos} } ] if defined $res->{repos};
                $res;
            }

            method admin_sendEmail ( $recipientDid, $senderDid, $content, $subject //= (), $comment //= () ) {
                $self->http->session // Carp::confess 'requires an authenticated client';
                $recipientDid = At::Protocol::DID->new( uri => $recipientDid ) unless builtin::blessed $recipientDid;
                $senderDid    = At::Protocol::DID->new( uri => $senderDid )    unless builtin::blessed $senderDid;
                my $res = $self->http->get(
                    sprintf( '%s/xrpc/%s', $self->host, 'com.atproto.admin.sendEmail' ),
                    {   content => +{
                            recipientDid => $recipientDid->_raw,
                            senderDid    => $senderDid->_raw,
                            content      => $content,
                            defined $subject ? ( subject => $subject ) : (), defined $comment ? ( comment => $comment ) : ()
                        }
                    }
                );
                $res;
            }

            method admin_updateAccountEmail ( $account, $email ) {
                $self->http->session // Carp::confess 'requires an authenticated client';
                my $res = $self->http->post( sprintf( '%s/xrpc/%s', $self->host, 'com.atproto.admin.updateAccountEmail' ),
                    { content => +{ account => $account, email => $email } } );
                $res->{success};
            }

            method admin_updateAccountHandle ( $did, $handle ) {
                $self->http->session // Carp::confess 'requires an authenticated client';
                $did = At::Protocol::DID->new( uri => $did ) if defined $did && !builtin::blessed $did;
                my $res = $self->http->post( sprintf( '%s/xrpc/%s', $self->host, 'com.atproto.admin.updateAccountHandle' ),
                    { content => +{ did => $did->_raw, handle => $handle } } );
                $res->{success};
            }

            method admin_updateSubjectStatus ( $subject, $takedown //= () ) {
                $self->http->session // Carp::confess 'requires an authenticated client';
                $subject  = At::_topkg( $subject->{'$type'} )->new(%$subject)        if !builtin::blessed $subject && defined $subject->{'$type'};
                $takedown = At::Lexicon::com::atproto::admin::statusAttr->new(%$did) if defined $takedown          && !builtin::blessed $takedown;
                my $res = $self->http->post( sprintf( '%s/xrpc/%s', $self->host, 'com.atproto.admin.updateSubjectStatus' ),
                    { content => +{ subject => $subject->_raw, defined $takedown ? ( takedown => $takedown->_raw ) : () } } );
                $res->{subject} = At::_topkg( $res->{subject}{'$type'} )->new( %{ $res->{subject} } )
                    if !builtin::blessed $res->{subject} && defined $res->{subject}{'$type'};
                $res->{takedown} = At::Lexicon::com::atproto::admin::statusAttr->new( %{ $res->{takedown} } ) if defined $res->{takedown};
                $res;
            }
        }

        #~ class At::Lexicon::AtProto::Identity
        {

            method resolveHandle ($handle) {
                my $res = $self->http->get( sprintf( '%s/xrpc/%s', $self->host, 'com.atproto.identity.resolveHandle' ),
                    { content => +{ handle => $handle } } );
                $res->{did} = At::Protocol::DID->new( uri => $res->{did} ) if defined $res->{did};
                $res;
            }

            method updateHandle ($handle) {
                $self->http->session // Carp::confess 'requires an authenticated client';
                $did = At::Protocol::DID->new( uri => $did ) if defined $did && !builtin::blessed $did;
                my $res = $self->http->post( sprintf( '%s/xrpc/%s', $self->host, 'com.atproto.identity.updateHandle' ),
                    { content => +{ handle => $handle } } );
                $res->{success};
            }
        }

        #~ class At::Lexicon::AtProto::Moderation
        {

            method createReport ( $reasonType, $subject, $reason //= () ) {
                $self->http->session // Carp::confess 'requires an authenticated client';
                $reasonType = At::Lexicon::com::atproto::moderation::reasonType->new( '$type' => $reasonType->{'$type'} )
                    if !builtin::blessed $reasonType && defined $reasonType->{'$type'};
                $subject = At::_topkg( $subject->{'$type'} )->new(%$subject) if !builtin::blessed $subject && defined $subject->{'$type'};
                my $res = $self->http->post( sprintf( '%s/xrpc/%s', $self->host, 'com.atproto.moderation.createReport' ),
                    { content => +{ reasonType => $reasonType->_raw, subject => $subject->_raw, defined $reason ? ( reason => $reason ) : () } } );
                $res->{reasonType} = At::Lexicon::com::atproto::moderation::reasonType->new( '$type' => $res->{reasonType}{'$type'} )
                    if defined $res->{reasonType} && defined $res->{reasonType}{'$type'};
                $res->{subject} = At::_topkg( $res->{subject}{'$type'} )->new( %{ $res->{subject} } )
                    if defined $res->{subject} && defined $res->{subject}{'$type'};
                $res->{reportedBy} = At::Protocol::DID->new( uri => $res->{reportedBy} )            if defined $res->{reportedBy};
                $res->{createdAt}  = At::Protocol::Timestamp->new( timestamp => $res->{createdAt} ) if defined $res->{createdAt};
                $res;
            }
        }

        #~ class At::Lexicon::AtProto::Sync
        {
            use At::Lexicon::com::atproto::sync;

            method getBlocks ( $did, $cids ) {
                my $res = $self->http->get( sprintf( '%s/xrpc/%s', $self->host, 'com.atproto.sync.getBlocks' ),
                    { content => +{ did => $did, cids => $cids } } );
                $res;
            }

            method getLatestCommit ( $did, $cids ) {
                my $res
                    = $self->http->get( sprintf( '%s/xrpc/%s', $self->host, 'com.atproto.sync.getLatestCommit' ), { content => +{ did => $did } } );
                $res;
            }

            method getRecord ( $did, $collection, $rkey, $commit //= () ) {
                my $res = $self->http->get( sprintf( '%s/xrpc/%s', $self->host, 'com.atproto.sync.getRecord' ),
                    { content => +{ did => $did, collection => $collection, rkey => $rkey, defined $commit ? ( commit => $commit ) : () } } );
                $res;
            }

            method getRepo ( $did, $since //= () ) {
                my $res = $self->http->get(
                    sprintf( '%s/xrpc/%s', $self->host, 'com.atproto.sync.getRepo' ),
                    { content => +{ did => $did, defined $since ? ( since => $since ) : () } }
                );
                $res;
            }

            method listBlobs ( $did, $since //= (), $limit //= (), $cursor //= () ) {
                my $res = $self->http->get(
                    sprintf( '%s/xrpc/%s', $self->host, 'com.atproto.sync.listBlobs' ),
                    {   content => +{
                            did => $did,
                            defined $since ? ( since => $since ) : (), defined $limit ? ( limit => $limit ) : (),
                            defined $cursor ? ( cursor => $cursor ) : ()
                        }
                    }
                );
                $res;
            }

            method listRepos ( $limit //= (), $cursor //= () ) {
                my $res = $self->http->get( sprintf( '%s/xrpc/%s', $self->host, 'com.atproto.sync.listRepos' ),
                    { content => +{ defined $limit ? ( limit => $limit ) : (), defined $cursor ? ( cursor => $cursor ) : () } } );
                $res->{repos} = [ map { At::Lexicon::com::atproto::sync::repo->new(%$_) } @{ $res->{repos} } ] if defined $res->{repos};
                $res;
            }

            method notifyOfUpdate ($hostname) {
                my $res = $self->http->post( sprintf( '%s/xrpc/%s', $self->host, 'com.atproto.sync.notifyOfUpdate' ),
                    { content => +{ hostname => $hostname } } );
                $res->{success};
            }

            method requestCrawl ($hostname) {
                my $res = $self->http->post( sprintf( '%s/xrpc/%s', $self->host, 'com.atproto.sync.requestCrawl' ),
                    { content => +{ hostname => $hostname } } );
                $res->{success};
            }

            method getBlob ( $did, $cid ) {
                my $res = $self->http->get( sprintf( '%s/xrpc/%s', $self->host, 'com.atproto.sync.getBlob' ),
                    { content => +{ did => $did, cid => $cid } } );
                $res;
            }

            # TODO: wrap the proper objects returned by the websocket. See com.atproto.sync.subscribeRepos
            method subscribeRepos ( $cb, $cursor //= () ) {
                my $res = $self->http->websocket(
                    sprintf( 'wss://%s/xrpc/%s%s', $self->host, 'com.atproto.sync.subscribeRepos', defined $cursor ? '?cursor=' . $cursor : '' ),

                    #~ sprintf( '%s/xrpc/%s', $self->host, 'com.atproto.label.subscribeLabels' ),
                    #~ { content => +{ defined $cursor ? ( cursor => $cursor ) : () } }
                    $cb
                );
                $res;
            }

            method subscribeRepos_p ( $cb, $cursor //= () ) {    # return a Mojo::Promise
                $self->http->agent->websocket_p(
                    sprintf( 'wss://%s/xrpc/%s%s', $self->host, 'com.atproto.sync.subscribeRepos', defined $cursor ? '?cursor=' . $cursor : '' ), )
                    ->then(
                    sub ($tx) {
                        my $promise = Mojo::Promise->new;
                        $tx->on( finish => sub { $promise->resolve } );
                        $tx->on(
                            message => sub ( $tx, $msg ) {
                                state $decoder //= CBOR::Free::SequenceDecoder->new()->set_tag_handlers( 42 => sub { } );
                                my $head = $decoder->give($msg);
                                my $body = $decoder->get;
                                $cb->( $promise, $$body );
                            }
                        );
                        return $promise;
                    }
                )->catch(
                    sub ($err) {
                        Carp::confess "WebSocket error: $err";
                    }
                );
            }
        }

        #~ class At::Lexicon::AtProto::Temp
        {

            method fetchLables ( $since //= (), $limit //= () ) {
                my $res = $self->http->get( sprintf( '%s/xrpc/%s', $self->host, 'com.atproto.temp.fetchLabels' ),
                    { content => +{ defined $since ? ( since => $since ) : (), defined $limit ? ( limit => $limit ) : () } } );
                $res->{labels} = [ map { At::Lexicon::com::atproto::label->new(%$_) } @{ $res->{labels} } ] if defined $res->{labels};
                $res;
            }

            method pushBlob ($did) {
                my $res = $self->http->post( sprintf( '%s/xrpc/%s', $self->host, 'com.atproto.temp.pushBlob' ), { content => +{ did => $did } } );
                $res;
            }

            method transferAccount ( $handle, $did, $plcOp ) {
                my $res = $self->http->post(
                    sprintf( '%s/xrpc/%s', $self->host, 'com.atproto.temp.transferAccount' ),
                    { content => +{ handle => $handle, did => $did, plcOp => $plcOp } }
                );

                # TODO: Is this a fully fleshed session object?
                $res;
            }

            method importRepo ($did) {
                my $res = $self->http->post( sprintf( '%s/xrpc/%s', $self->host, 'com.atproto.temp.importRepo' ), { content => +{ did => $did } } );
                $res->{success};
            }
        }

        class At::Protocol::DID {    # https://atproto.com/specs/did
            field $uri : param;
            ADJUST {
                use Carp qw[carp croak];
                croak 'malformed DID URI: ' . $uri unless $uri =~ /^did:([a-z]+:[a-zA-Z0-9._:%-]*[a-zA-Z0-9._-])$/;
                use URI;
                $uri = URI->new($1) unless builtin::blessed $uri;
                my $scheme = $uri->scheme;
                carp 'unsupported method: ' . $scheme if $scheme ne 'plc' && $scheme ne 'web';
            };

            method _raw {
                'did:' . $uri->as_string;
            }
        }

        class At::Protocol::Timestamp {    # Internal; standardize around Zulu
            field $timestamp : param;
            ADJUST {
                $timestamp // Carp::croak 'missing timestamp';
                use Time::Moment;
                return if builtin::blessed $timestamp;
                $timestamp = $timestamp =~ /\D/ ? Time::Moment->from_string($timestamp) : Time::Moment->from_epoch($timestamp);
            };

            method _raw {
                $timestamp->to_string;
            }
        }

        class At::Protocol::Handle {    # https://atproto.com/specs/handle
            field $id : param;
            ADJUST {
                use Carp qw[croak carp];
                croak 'malformed handle: ' . $id
                    unless $id =~ /^([a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?\.)+[a-zA-Z]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?$/;
                croak 'disallowed TLD in handle: ' . $id if $id =~ /\.(arpa|example|internal|invalid|local|localhost|onion)$/;
                CORE::state $warned //= 0;
                if ( $id =~ /\.(test)$/ && !$warned ) {
                    carp 'development or testing TLD used in handle: ' . $id;
                    $warned = 1;
                }
            };
            method _raw { $id; }
        }

        class At::Protocol::Session {
            field $accessJwt : param;
            field $did : param;
            field $didDoc : param         = ();    # spec says 'unknown' so I'm just gonna ignore it for now even with the dump
            field $email : param          = ();
            field $emailConfirmed : param = ();
            field $handle : param;
            field $refreshJwt : param;

            # waiting for perlclass to implement accessors with :reader
            method accessJwt {$accessJwt}
            method did       {$did}
            #
            ADJUST {
                $did            = At::Protocol::DID->new( uri => $did ) unless builtin::blessed $did;
                $emailConfirmed = !!$emailConfirmed if defined $emailConfirmed;
            }
        }

        class At::UserAgent {
            field $session : param = ();
            method session ( ) { $session; }

            method set_session ($s) {
                $session = builtin::blessed $s ? $s : At::Protocol::Session->new(%$s);
                $self->_set_bearer_token( 'Bearer ' . $s->{accessJwt} );
            }
            method get       ( $url, $req = () ) {...}
            method post      ( $url, $req = () ) {...}
            method websocket ( $url, $req = () ) {...}
            method _set_bearer_token ($token) {...}
        }

        class At::UserAgent::Tiny : isa(At::UserAgent) {

            # TODO: Error handling
            use HTTP::Tiny;
            use JSON::Tiny qw[decode_json encode_json];
            field $agent : param = HTTP::Tiny->new(
                agent           => sprintf( 'At.pm/%1.2f;Tiny ', $At::VERSION ),
                default_headers => { 'Content-Type' => 'application/json', Accept => 'application/json' }
            );

            sub _url_encode {
                my $rv = shift;
                $rv =~ s/([^a-z\d\Q.-_~ \E])/sprintf("%%%2.2X", ord($1))/geix;
                $rv =~ tr/ /+/;
                return $rv;
            }

            sub _build_query_string {
                my $params = shift;
                my @query;
                for my ( $key, $value )(%$params) {
                    next if !defined $value;
                    push @query, $key . '=' . _url_encode($_) for ( builtin::reftype($value) // '' eq 'ARRAY' ? @$value : $value );
                }
                return join '&', @query;
            }

            method get ( $url, $req = () ) {
                my $res = $agent->get(
                    $url . ( defined $req->{content} && keys %{ $req->{content} } ? '?' . _build_query_string( $req->{content} ) : '' ) );

                #~ use Data::Dump;
                #~ warn $url . ( defined $req->{content} && keys %{ $req->{content} } ? '?' . _build_query_string( $req->{content} ) : '' );
                #~ ddx $res;
                return $res->{content} = decode_json $res->{content} if $res->{content};
                return $res;
            }

            method post ( $url, $req = () ) {
                my $res = $agent->post( $url, defined $req->{content} ? { content => encode_json $req->{content} } : () );

                #~ use Data::Dump;
                #~ warn
                #~ $url . ( defined $req->{content} && keys %{ $req->{content}}
                #~ ? '?' . _build_query_string( $req->{content} ) : '' ) ;
                #~ ddx $res;
                return $res->{content} = decode_json $res->{content} if $res->{content};
                return $res;
            }
            method websocket ( $url, $req = () ) {...}

            method _set_bearer_token ($token) {
                $agent->{default_headers}{Authorization} = $token;
            }
        }

        class At::UserAgent::Mojo : isa(At::UserAgent) {

            # TODO - Required for websocket based Event Streams
            #~ https://atproto.com/specs/event-stream
            # TODO: Error handling
            field $agent : param = sub {
                my $ua = Mojo::UserAgent->new;
                $ua->transactor->name( sprintf( 'At.pm/%1.2f;Mojo ', $At::VERSION ) );
                $ua;
                }
                ->();
            method agent {$agent}
            field $auth : param //= ();

            method get ( $url, $req = () ) {
                my $res = $agent->get( $url, defined $auth ? { Authorization => $auth } : (),
                    defined $req->{content} ? ( form => $req->{content} ) : () );
                $res = $res->result;

                # todo: error handling
                if    ( $res->is_success )  { return $res->content ? $res->json : () }
                elsif ( $res->is_error )    { say $res->message }
                elsif ( $res->code == 301 ) { say $res->headers->location }
                else                        { say 'Whatever...' }
            }

            method post ( $url, $req = () ) {

                #~ warn $url;
                my $res = $agent->post( $url, defined $auth ? { Authorization => $auth } : (),
                    defined $req->{content} ? ( json => $req->{content} ) : () )->result;

                # todo: error handling
                if    ( $res->is_success )  { return $res->content ? $res->json : () }
                elsif ( $res->is_error )    { say $res->message }
                elsif ( $res->code == 301 ) { say $res->headers->location }
                else                        { say 'Whatever...' }
            }

            method websocket ( $url, $cb, $req = () ) {
                require CBOR::Free::SequenceDecoder;
                $agent->websocket(
                    $url => { 'Sec-WebSocket-Extensions' => 'permessage-deflate' } => sub ( $ua, $tx ) {

                        #~ use Data::Dump;
                        #~ ddx $tx;
                        say 'WebSocket handshake failed!' and return unless $tx->is_websocket;

                        #~ say 'Subprotocol negotiation failed!' and return unless $tx->protocol;
                        #~ $tx->send({json => {test => [1, 2, 3]}});
                        $tx->on(
                            finish => sub ( $tx, $code, $reason ) {
                                say "WebSocket closed with status $code.";
                            }
                        );
                        state $decoder //= CBOR::Free::SequenceDecoder->new()->set_tag_handlers( 42 => sub { } );

                        #~ $tx->on(json => sub ($ws, $hash) { say "Message: $hash->{msg}" });
                        $tx->on(
                            message => sub ( $tx, $msg ) {
                                my $head = $decoder->give($msg);
                                my $body = $decoder->get;

                                #~ ddx $$head;
                                $$body->{blocks} = length $$body->{blocks} if defined $$body->{blocks};

                                #~ use Data::Dumper;
                                #~ say Dumper $$body;
                                $cb->($$body);

                                #~ say "WebSocket message: $msg";
                                #~ $tx->finish;
                            }
                        );

                        #~ $tx->on(
                        #~ frame => sub ( $ws, $frame ) {
                        #~ ddx $frame;
                        #~ }
                        #~ );
                        #~ $tx->on(
                        #~ text => sub ( $ws, $bytes ) {
                        #~ ddx $bytes;
                        #~ }
                        #~ );
                        #~ $tx->send('Hi!');
                    }
                );
            }

            method _set_bearer_token ($token) {
                $auth = $token;
            }
        }
    }

    sub _glength ($str) {    # https://www.perl.com/pub/2012/05/perlunicook-string-length-in-graphemes.html/
        my $count = 0;
        while ( $str =~ /\X/g ) { $count++ }
        return $count;
    }

    sub _topkg ($name) {     # maps CID to our packages (I hope)
        $name =~ s/[\.\#]/::/g;
        $name =~ s[::defs::][::];

        #~ $name =~ s/^(.+::)(.*?)#(.*)$/$1$3/;
        return 'At::Lexicon::' . $name;
    }
}
<<'EOF';
# ABSTRACT: The AT Protocol for Social Networking
=head1 AUTHOR

Sanko Robinson E<lt>sanko@cpan.orgE<gt>
EOF
