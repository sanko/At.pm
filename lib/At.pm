package At 0.02 {
    use v5.38;
    no warnings 'experimental::class', 'experimental::builtin', 'experimental::for_list';    # Be quiet.
    use feature 'class';
    use experimental 'try';
    #
    use At::Lexicon::com::atproto::label;

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
            #~ field $self : param;
            #~ field $did : param;
            #~ method did {$did}
            #~ ADJUST {
            #~ $did = At::Protocol::DID->new( uri => $did ) unless builtin::blessed $did
            #~ }
            method disableAccountInvites (%args) {
                use Carp qw[confess];
                $self->http->session // confess 'creating a post requires an authenticated client';
                my $res
                    = $self->http->post( sprintf( '%s/xrpc/%s', $self->host(), 'com.atproto.admin.disableAccountInvites' ), { content => \%args } );
                $res;
            }

            method disableInviteCodes (%args) {
                use Carp qw[confess];
                $self->http->session // confess 'creating a post requires an authenticated client';
                my $res = $self->http->post( sprintf( '%s/xrpc/%s', $self->host(), 'com.atproto.admin.disableInviteCodes' ), { content => \%args } );
                $res;
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
                #~ warn
                #~ $url . ( defined $req->{content} && keys %{ $req->{content}}
                #~ ? '?' . _build_query_string( $req->{content} ) : '' ) ;
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
                        $tx->on( finish => sub ( $tx, $code, $reason ) { say "WebSocket closed with status $code." } );
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
1;
__END__

=encoding utf-8

=head1 NAME

At - The AT Protocol for Social Networking

=head1 SYNOPSIS

    use At;
    my $at = At->new( host => 'https://fun.example' );
    $at->createSession( 'sanko', '1111-aaaa-zzzz-0000' );
    $at->createRecord(
        collection => 'app.bsky.feed.post',
        record     => { '$type' => 'app.bsky.feed.post', text => 'Hello world! I posted this via the API.', createdAt => time }
    );

=head1 DESCRIPTION

The AT Protocol is a "social networking technology created to power the next generation of social applications."

At.pm uses perl's new class system which requires perl 5.38.x or better and, like the protocol itself, is still under
development.

=head2 At::Bluesky

At::Bluesky is a subclass with the host set to C<https://bluesky.social> and all the lexicon related to the social
networking site included.

=head2 App Passwords

Taken from the AT Protocol's official documentation:

=for html <blockquote>

For the security of your account, when using any third-party clients, please generate an L<app
password|https://atproto.com/specs/xrpc#app-passwords> at Settings > Advanced > App passwords.

App passwords have most of the same abilities as the user's account password, but they're restricted from destructive
actions such as account deletion or account migration. They are also restricted from creating additional app passwords.

=for html </blockquote>

Read their disclaimer here: L<https://atproto.com/community/projects#disclaimer>.

=head1 Methods

Honestly, to keep to the layout of the underlying protocol, almost everything is handled in members of this class.

=head2 C<new( ... )>

Creates an AT client and initiates an authentication session.

    my $self = At->new( host => 'https://bsky.social' );

Expected parameters include:

=over

=item C<host> - required

Host for the account. If you're using the 'official' Bluesky, this would be 'https://bsky.social' but you'll probably
want C<At::Bluesky-E<gt>new(...)> because that client comes with all the bits that aren't part of the core protocol.

=back

=head2 C<disableAccountInvites( ... )>

Disable an account from receiving new invite codes, but does not invalidate existing codes.

Expected parameters include:

=over

=item C<account> - required

DID of account to modify.

=item C<note>

Optional reason for disabled invites.

=back

=head2 C<disableInviteCodes( )>

Disable some set of codes and/or all codes associated with a set of users.

Expected parameters include:

=over

=item C<codes>

List of codes.

=item C<accounts>

List of account DIDs.

=back























=head1 Repo Methods

Repo methods generally require an authorized session. The AT Protocol treats 'posts' and other data as records stored
in repositories.

=head2 C<createRecord( ... )>

Create a new record.

    $at->createRecord(
        collection => 'app.bsky.feed.post',
        record     => { '$type' => 'app.bsky.feed.post', text => "Hello world! I posted this via the API.", createdAt => gmtime->datetime . 'Z' }
    );

Expected parameters include:

=over

=item C<collection> - required

The NSID of the record collection.

=item C<record> - required

Depending on the type of record, this could be anything. It's undefined in the protocol itself.

=back

=head1 Server Methods

Server methods may require an authorized session.

=head2 C<createSession( ... )>

    $at->createSession( 'sanko', '1111-2222-3333-4444' );

Create an authentication session.

Expected parameters include:

=over

=item C<identifier> - required

Handle or other identifier supported by the server for the authenticating user.

=item C<password> - required

=back

On success, the access and refresh JSON web tokens, the account's handle, DID and (optionally) other data is returned.

=head2 C<describeServer( )>

Get a document describing the service's accounts configuration.

    $at->describeServer( );

This method does not require an authenticated session.

Returns a boolean value indicating whether an invite code is required, a list of available user domains, and links to
the TOS and privacy policy.

=head2 C<listAppPasswords( )>

    $at->listAppPasswords( );

List all App Passwords.

Returns a list of passwords as new C<At::Lexicon::com::atproto::server::listAppPasswords::appPassword> objects.

=head2 C<getSession( )>

    $at->getSession( );

Get information about the current session.

Returns the handle, DID, and (optionally) other data.

=head2 C<getAccountInviteCodes( )>

    $at->getAccountInviteCodes( );

Get all invite codes for a given account.

Returns codes as a list of new C<At::Lexicon::com::atproto::server::inviteCode> objects.

=head2 C<getAccountInviteCodes( [...] )>

    $at->getAccountInviteCodes( );

Get all invite codes for a given account.

Expected parameters include:

=over

=item C<includeUsed>

Optional boolean flag.

=item C<createAvailable>

Optional boolean flag.

=back

Returns a list of C<At::Lexicon::com::atproto::server::inviteCode> objects on success. Note that this method returns an
error if the session was authorized with an app password.

=head2 C<updateEmail( ..., [...] )>

    $at->updateEmail( 'smith...@gmail.com' );

Update an account's email.

Expected parameters include:

=over

=item C<email> - required

=item C<token>

This method requires a token from C<requestEmailUpdate( ... )> if the account's email has been confirmed.

=back

=head2 C<requestEmailUpdate( ... )>

    $at->requestEmailUpdate( 1 );

Request a token in order to update email.

Expected parameters include:

=over

=item C<tokenRequired> - required

Boolean value.

=back

=head2 C<revokeAppPassword( ... )>

    $at->revokeAppPassword( 'Demo App [beta]' );

Revoke an App Password by name.

Expected parameters include:

=over

=item C<name> - required

=back

=head2 C<resetPassword( ... )>

    $at->resetPassword( 'fdsjlkJIofdsaf89w3jqirfu2q8docwe', '****************' );

Reset a user account password using a token.

Expected parameters include:

=over

=item C<token> - required

=item C<password> - required

=back

=head2 C<resetPassword( ... )>

    $at->resetPassword( 'fdsjlkJIofdsaf89w3jqirfu2q8docwe', '****************' );

Reset a user account password using a token.

Expected parameters include:

=over

=item C<token> - required

=item C<password> - required

=back

=head2 C<reserveSigningKey( [...] )>

    $at->reserveSigningKey( 'did:...' );

Reserve a repo signing key for account creation.

Expected parameters include:

=over

=item C<did>

The did to reserve a new did:key for.

=back

On success, a public signing key in the form of a did:key is returned.

=head2 C<requestPasswordReset( [...] )>

    $at->requestPasswordReset( 'smith...@gmail.com' );

Initiate a user account password reset via email.

Expected parameters include:

=over

=item C<email> - required

=back

=head2 C<requestEmailConfirmation( )>

    $at->requestEmailConfirmation( );

Request an email with a code to confirm ownership of email.

=head2 C<requestAccountDelete( )>

    $at->requestAccountDelete( );

Initiate a user account deletion via email.

=head2 C<deleteSession( )>

    $at->deleteSession( );

Initiate a user account deletion via email.

=head2 C<deleteAccount( )>

    $at->deleteAccount( );

Delete an actor's account with a token and password.

Expected parameters include:

=over

=item C<did> - required

=item C<password> - required

=item C<token> - required

=back

=head2 C<createInviteCodes( ..., [...] )>

    $at->createInviteCodes( 1, 1 );

Create invite codes.

Expected parameters include:

=over

=item C<codeCount> - required

The number of codes to create. Default value is 1.

=item C<useCount> - required

Int.

=item C<forAccounts>

List of DIDs.

=back

On success, returns a list of new C<At::Lexicon::com::atproto::server::createInviteCodes::accountCodes> objects.

=head2 C<createInviteCode( ..., [...] )>

    $at->createInviteCode( 1 );

Create an invite code.

Expected parameters include:

=over

=item C<useCount> - required

Int.

=item C<forAccounts>

List of DIDs.

=back

On success, a new invite code is returned.

=head2 C<createAppPassword( ..., [...] )>

    $at->createAppPassword( 'AT Client [release]' );

Create an App Password.

Expected parameters include:

=over

=item C<name> - required

=back

On success, a new C<At::Lexicon::com::atproto::server::createAppPassword::appPassword> object.

=head2 C<createAccount( ..., [...] )>

    $at->createAccount( 'jsmith....', '*********' );

Create an account.

Expected parameters include:

=over

=item C<handle> - required

=item C<email>

=item C<password>

=item C<inviteCode>

=item C<did>

=item C<recoveryKey>

=item C<plcOP>

=back

On success, JSON web access and refresh tokens, the handle, did, and (optionally) a server defined didDoc are returned.

=head2 C<confirmEmail( ... )>

    $at->confirmEmail( 'jsmith...@gmail.com', 'idkidkidkidkdifkasjkdfsaojfd' );

Confirm an email using a token from C<requestEmailConfirmation( )>,

Expected parameters include:

=over

=item C<email> - required

=item C<token> - required

=back

=begin todo

=head1 Label Methods

Lables are metadata tags on an atproto resource (eg, repo or record).

=head2 C<queryLabels( ... )>

    $at->queryLabels( '' );

Find labels relevant to the provided URI patterns.

Expected parameters include:

=over

=item C<uriPatterns> - required

List of AT URI patterns to match (boolean 'OR'). Each may be a prefix (ending with '*'; will match inclusive of the
string leading to '*'), or a full URI.

=item C<sources>

Optional list of label sources (DIDs) to filter on.

=item C<limit>

Number of results to return. 250 max. Default is 50.

=item C<cursor>

=back

On success, labels are returned as a list of new C<At::Lexicon::com::atproto::label> objects.

=head2 C<subscribeLabels( ..., [...] )>

    $at->subscribeLabels( sub { ... } );

Subscribe to label updates.

Expected parameters include:

=over

=item C<callback> - required

Code reference triggered with every event.

=item C<cursor>

The last known event to backfill from.

=back

On success, a websocket is initiated. Events we recieve include
C<At::Lexicon::com::atproto::label::subscribeLables::labels> and
C<At::Lexicon::com::atproto::label::subscribeLables::info> objects.

=head2 C<subscribeLabels_p( ..., [...] )>

    $at->subscribeLabels_p( sub { ... } );

Subscribe to label updates.

Expected parameters include:

=over

=item C<callback> - required

Code reference triggered with every event.

=item C<cursor>

The last known event to backfill from.

=back

On success, a websocket is initiated and a promise is returned. Events we recieve include
C<At::Lexicon::com::atproto::label::subscribeLables::labels> and
C<At::Lexicon::com::atproto::label::subscribeLables::info> objects.

=head1 Services

Currently, there are 3 sandbox At Protocol services:

=over

=item PLC

    my $at = At->new( host => 'plc.bsky-sandbox.dev' );

This is the default DID provider for the network. DIDs are the root of your identity in the network. Sandbox PLC
functions exactly the same as production PLC, but it is run as a separate service with a separate dataset. The DID
resolution client in the self-hosted PDS package is set up to talk the correct PLC service.

=item BGS

    my $at = At->new( host => 'bgs.bsky-sandbox.dev' );

BGS (Big Graph Service) is the firehose for the entire network. It collates data from PDSs & rebroadcasts them out on
one giant websocket.

BGS has to find out about your server somehow, so when we do any sort of write, we ping BGS with
com.atproto.sync.requestCrawl to notify it of new data. This is done automatically in the self-hosted PDS package.

If you’re familiar with the Bluesky production firehose, you can subscribe to the BGS firehose in the exact same
manner, the interface & data should be identical

=item BlueSky Sandbox

    my $at = At->new( host => 'api.bsky-sandbox.dev' );

The Bluesky App View aggregates data from across the network to service the Bluesky microblogging application. It
consumes the firehose from the BGS, processing it into serviceable views of the network such as feeds, post threads,
and user profiles. It functions as a fairly traditional web service.

When you request a Bluesky-related view from your PDS (getProfile for instance), your PDS will actually proxy the
request up to App View.

Feel free to experiment with running your own App View if you like!

=back

You may also configure your own personal data server (PDS).

    my $at = At->new( host => 'your.own.com' );

PDS (Personal Data Server) is where users host their social data such as posts, profiles, likes, and follows. The goal
of the sandbox is to federate many PDS together, so we hope you’ll run your own.

We’re not actually running a Bluesky PDS in sandbox. You might see Bluesky team members' accounts in the sandbox
environment, but those are self-hosted too.

The PDS that you’ll be running is much of the same code that is running on the Bluesky production PDS. Notably, all
of the in-pds-appview code has been torn out. You can see the actual PDS code that you’re running on the
atproto/simplify-pds branch.

=end todo

=head1 See Also

L<https://atproto.com/>

L<Bluesky on Wikipedia.org|https://en.wikipedia.org/wiki/Bluesky_(social_network)>

=head1 LICENSE

Copyright (C) Sanko Robinson.

This library is free software; you can redistribute it and/or modify it under the terms found in the Artistic License
2. Other copyrights, terms, and conditions may apply to data transmitted through this module.

=head1 AUTHOR

Sanko Robinson E<lt>sanko@cpan.orgE<gt>

=begin stopwords

didDoc

=end stopwords

=cut
