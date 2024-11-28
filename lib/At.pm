package At v1.0.0 {
    use v5.40;
    use Carp qw[];
    no warnings 'experimental::class', 'experimental::builtin', 'experimental::for_list';    # Be quiet.
    use feature 'class';
    use experimental 'try';
    use File::ShareDir::Tiny qw[dist_dir module_dir];
    use JSON::Tiny           qw[decode_json];
    use Path::Tiny           qw[path];
    use Time::Moment;                                                                        # Internal; standardize around Zulu
    use warnings::register;
    #
    use At::Error;
    use At::Protocol::URI;
    #
    class At {
        field $share : reader : param //= dist_dir(__CLASS__);
        field %lexicons : reader;
        use URI;

        sub _decode_token ($token) {
            use MIME::Base64 qw[decode_base64];
            use JSON::Tiny   qw[decode_json];
            my ( $header, $payload, $sig ) = split /\./, $token;
            $payload =~ tr[-_][+/];    # Replace Base64-URL characters with standard Base64
            decode_json decode_base64 $payload;
        }
        field $http //= Mojo::UserAgent->can('start') ? At::UserAgent::Mojo->new() : At::UserAgent::Tiny->new();
        method http {$http}
        field $host : param : reader;
        #
        field $session = ();
        #
        field %ratelimits : reader;    # https://docs.bsky.app/docs/advanced-guides/rate-limits

        #~ global        => {},
        #~ updateHandle  => {},    # per DID
        #~ updateHandle  => {},    # per DID
        #~ createSession => {},    # per handle
        #~ deleteAccount => {},    # by IP
        #~ resetPassword => {}     # by IP
        #
        ADJUST {
            $share = path($share)       unless builtin::blessed $share;
            $host  = 'https://' . $host unless $host =~ /^https?:/;
            $host  = URI->new($host)    unless builtin::blessed $host;
        }

        method login( $identifier, $password ) {
            $session = $self->post( 'com.atproto.server.createSession' => { identifier => $identifier, password => $password } );
            return $session ? $http->set_tokens( $session->{accessJwt}, $session->{refreshJwt} ) : $session;
        }

        method resume ( $accessJwt, $refreshJwt ) {
            my $access  = _decode_token $accessJwt;
            my $refresh = _decode_token $refreshJwt;
            if ( time > $access->{exp} && time < $refresh->{exp} ) {

                # Attempt to use refresh token which has a 90 day life span as of Jan. 2024
                $session = $self->post( 'com.atproto.server.refreshSession' => { refreshJwt => $refreshJwt } );
                return $session ? $http->set_tokens( $session->accessJwt, $session->refreshJwt ) : $session;
            }

            #~ $session = $self->post( 'com.atproto.server.refreshSession' => { refreshJwt => $refreshJwt } );
            $http->set_tokens( $accessJwt, $refreshJwt );
        }

        method did() {
            $self->session->{did};
        }

        method session() {
            $session //= $self->get('com.atproto.server.getSession');
            $session;
        }
        ## Internals
        sub _now                            { Time::Moment->now }
        sub _percent ( $limit, $remaining ) { $remaining && $limit ? ( ( $limit / $remaining ) * 100 ) : 0 }
        sub _plural( $count, $word )        { $count ? sprintf '%d %s%s', $count, $word, $count == 1 ? '' : 's' : () }

        sub _duration ($seconds) {
            $seconds || return '0 seconds';
            $seconds = abs $seconds;                                                                        # just in case
            my ( $time, @times ) = reverse grep {defined} _plural( int( $seconds / 31536000 ), 'year' ),    # assume 365 days and no leap seconds
                _plural( int( ( $seconds % 31536000 ) / 604800 ), 'week' ), _plural( int( ( $seconds % 604800 ) / 86400 ), 'day' ),
                _plural( int( ( $seconds % 86400 ) / 3600 ),      'hour' ), _plural( int( ( $seconds % 3600 ) / 60 ),      'minute' ),
                _plural( $seconds % 60,                           'second' );
            join ' and ', @times ? join( ', ', reverse @times ) : (), $time;
        }

        method _locate_lexicon($fqdn) {
            unless ( defined $lexicons{$fqdn} ) {
                my $fqdn      = $fqdn;
                my ($tag)     = $fqdn =~ s[#(.+)$][];
                my @namespace = split /\./, $fqdn;
                my $lex       = $share->child( 'lexicons', @namespace[ 0 .. $#namespace - 1 ], $namespace[-1] . '.json' );
                $lex->exists || return;
                my $json = decode_json $lex->slurp_raw;    # Hope for the best
                for my $def ( keys %{ $json->{defs} } ) {
                    $lexicons{ $fqdn . ( $def eq 'main' ? '' : '#' . $def ) } = $json->{defs}{$def};
                }
            }
            $lexicons{$fqdn};
        }

        method get( $fqdn, $args = () ) {
            my @namespace = split /\./, $fqdn;
            my $lexicon   = $self->_locate_lexicon($fqdn);

            #~ use Data::Dump;
            #~ ddx $lexicon;
            $self->_ratecheck('global');

            # ddx $schema;
            my ( $content, $headers ) = $http->get( sprintf( '%s/xrpc/%s', $self->host, $fqdn ), defined $args ? { content => $args } : () );

            #~ use Data::Dump;
            #~ ddx $content;
            #~ https://docs.bsky.app/docs/advanced-guides/rate-limits
            $self->ratelimit_( { map { $_ => $headers->{ 'ratelimit-' . $_ } } qw[limit remaining reset] }, 'global' );
            $self->_ratecheck('global');
            if ( $lexicon && !builtin::blessed $content ) {
                $content = $self->_coerce( $fqdn, $lexicon->{output}{schema}, $content );
            }
            wantarray ? ( $content, $headers ) : $content;
        }

        method post( $fqdn, $args = () ) {
            my @namespace = split /\./, $fqdn;
            my $lexicon   = $self->_locate_lexicon($fqdn);
            my $rate_category
                = $namespace[-1] =~ m[^(updateHandle|createAccount|createSession|deleteAccount|resetPassword)$] ? $namespace[-1] : 'global';
            my $_rate_meta = $rate_category eq 'createSession' ? $args->{identifier} : $rate_category eq 'updateHandle' ? $args->{did} : ();
            $self->_ratecheck( $rate_category, $_rate_meta );
            my ( $content, $headers ) = $http->post( sprintf( '%s/xrpc/%s', $self->host, $fqdn ), defined $args ? { content => $args } : () );

            #~ use Data::Dump;
            #~ ddx $headers;
            #~ ddx $content;
            #~ https://docs.bsky.app/docs/advanced-guides/rate-limits
            $self->ratelimit_( { map { $_ => $headers->{ 'ratelimit-' . $_ } } qw[limit remaining reset] }, $rate_category, $_rate_meta );
            $self->_ratecheck( $rate_category, $_rate_meta );
            if ( $lexicon && !builtin::blessed $content ) {
                $content = $self->_coerce( $fqdn, $lexicon->{output}{schema}, $content );
            }
            return wantarray ? ( $content, $headers ) : $content;
        }

        method subscribe( $id, $args = () ) {
            ...;
        }
        #
        method ratelimit_ ( $rate, $type, $meta //= () ) {    #~ https://docs.bsky.app/docs/advanced-guides/rate-limits
            defined $meta ? $ratelimits{$type}{$meta} = $rate : $ratelimits{$type} = $rate;
        }

        method _ratecheck( $type, $meta //= () ) {
            my $rate = defined $meta ? $ratelimits{$type}{$meta} : $ratelimits{$type};
            $rate->{reset} // return;
            return warnings::warnif( At => sprintf 'Exceeded %s rate limit. Try again in %s', $type, _duration( $rate->{reset} - time ) )
                if defined $rate->{reset} && $rate->{remaining} == 0 && $rate->{reset} > time;
            my $percent = _percent( $rate->{remaining}, $rate->{limit} );
            warnings::warnif(
                At => sprintf '%.2f%% of %s rate limit remaining (%d of %d). Slow down or try again in %s',
                $percent, $type, $rate->{remaining}, $rate->{limit}, _duration( $rate->{reset} - time )
            ) if $percent <= 5;
        }

        # Init
        {
            our %capture;

            sub namespace2package ($fqdn) {
                my $namespace = $fqdn =~ s[[#\.]][::]gr;
                'At::Lexicon::' . $namespace;
            }

            sub _set_capture ( $namespace, $schema ) {
                my @path_components = split( /\./, $namespace );
                my $current_ref     = \%capture;
                $current_ref = $current_ref->{$_} //= {} for @path_components[ 0 .. $#path_components - 1 ];
                $current_ref->{ $path_components[-1] } = $schema;
                {
                    no strict 'refs';
                    *{ namespace2package($namespace) . '::new' } = sub ( $class, %args ) {
                        my @missing = sort grep { !defined $args{$_} } @{ $schema->{required} };
                        Carp::croak sprintf 'missing required field%s in %s->new(...): %s', ( scalar @missing == 1 ? '' : 's' ), $class, join ', ',
                            @missing
                            if @missing;
                        for my $property ( keys %{ $schema->{properties} } ) {
                            $args{$property} = _coerce( $namespace, $schema->{properties}{$property}, $args{$property} ) if defined $args{$property};
                        }
                        bless \%args, $class;
                    };
                    for my $property ( keys %{ $schema->{properties} } ) {
                        *{ namespace2package($namespace) . '::' . $property } = sub ( $s, $new //= () ) {
                            $s->{$property} = _coerce( $namespace, $schema->{properties}{$property}, $new ) if defined $new;
                            $s->{$property};
                        }
                    }
                    *{ namespace2package($namespace) . '::_schema' } = sub ($s) {
                        $schema;
                    };
                    *{ namespace2package($namespace) . '::_namespace' } = sub ($s) {
                        $namespace;
                    };
                    *{ namespace2package($namespace) . '::verify' } = sub ($s) {

                        # TODO: verify that data fills schema requirements
                        #~ ddx $schema;
                        #~ ddx $s;
                        for my $property ( keys %{ $schema->{properties} } ) {

                            #~ ddx $property;
                            #~ ddx $schema->{properties}{$property};
                        }
                        return 0;    # This doesn't work yet.

                        #~ exit;
                    };
                    *{ namespace2package($namespace) . '::_raw' } = sub ($s) {
                        my %ret;

                        # TODO: verify that data fills schema requirements
                        #~ ddx $schema;
                        #~ use Data::Dump;
                        #~ ddx $s;
                        for my $property ( keys %{ $schema->{properties} } ) {
                            $ret{$property}
                                = ref $s->{$property} eq 'HASH'     ? { map { $_ => $s->{$property}{$_}->_raw } keys %{ $s->{$property} } } :
                                ref $s->{$property} eq 'ARRAY'      ? [ map { $_->_raw } @{ $s->{$property} } ] :
                                builtin::blessed( $s->{$property} ) ? ( $s->{$property}->can('_raw') ? $s->{$property}->_raw() :
                                    $s->{$property}->can('as_string') ? $s->{$property}->as_string() :
                                    $s->{$property} ) :
                                $s->{$property};
                        }
                        %ret;
                    };
                }
            }

            sub load_lexicon (%imports) {
                use Path::Tiny;
                my $lexicon;    # Allow user to define where lexicon snapshots are to be found
                try {
                    $lexicon = delete $imports{'-lexicons'} // dist_dir(__PACKAGE__);
                }
                catch ($error) {
                    $lexicon = './share'
                }
                finally {
                    $lexicon = path($lexicon) unless builtin::blessed $lexicon;
                    $lexicon = $lexicon->child('lexicons')->realpath
                }
                warn $lexicon;
                #
                my $iter = $lexicon->iterator( { recurse => 1 } );
                while ( my $next = $iter->() ) {
                    if ( $next->is_file ) {
                        warn $next->absolute;
                        my $raw = decode_json $next->slurp_utf8;
                        for my ( $name, $schema )( %{ $raw->{defs} } ) {
                            my $fqdn = $raw->{id} . ( $name eq 'main' ? '' : '#' . $name );    # RDN
                            if ( $schema->{type} eq 'array' ) {
                                _set_capture( $fqdn, $schema );
                            }
                            elsif ( $schema->{type} eq 'object' ) {
                                _set_capture( $fqdn, $schema );
                            }
                            elsif ( $schema->{type} eq 'procedure' ) {
                            }
                            elsif ( $schema->{type} eq 'query' ) {
                            }
                            elsif ( $schema->{type} eq 'record' ) {
                                _set_capture( join( '.', $raw->{id}, ( $name eq 'main' ? () : $name ) ), $schema );
                            }
                            elsif ( $schema->{type} eq 'string' ) { _set_capture( $fqdn, $schema ); }
                            elsif ( $schema->{type} eq 'subscription' ) {

                                #~ use Data::Dump;
                                #~ ddx $schema;
                            }
                            elsif ( $schema->{type} eq 'token' ) {    # Generally just a string
                                my $namespace = $fqdn =~ s[[#\.]][::]gr;
                                my $package   = namespace2package($fqdn);
                                no strict 'refs';

                                #~ *{ $package . "::(\"\"" } = sub ( $s, $u, $q ) { $fqdn };
                                #~ *{ $package . "::((" }  = sub {$fqdn};
                                *{$package} = sub ( ) { $fqdn; };
                            }
                            else {
                                ...;
                            }
                        }

                        # $lexicon{ $raw->{id} } = $raw;
                    }
                }
            }

            sub _namespace ( $l, $r ) {

                #~ Carp::carp( sprintf 'l: %s, r: %s', $l, $r );
                return $r if $r =~ m[.+#] || $r !~ m[^#];
                return $` . $r if $l =~ m[#.+];
                $l . $r;
            }
            my %coercions = (
                array => method( $namespace, $schema, $data ) {
                    [ map { $self->_coerce( $namespace, $schema->{items}, $_ ) } @$data ]
                },
                boolean => method( $namespace, $schema, $data ) { !!$data },
                bytes   => method( $namespace, $schema, $data ) {$data},
                blob    => method( $namespace, $schema, $data ) {$data},
                integer => method( $namespace, $schema, $data ) { int $data },
                object  => method( $namespace, $schema, $data ) {

                    # TODO: warn about missing properties first
                    for my ( $name, $subschema )( %{ $schema->{properties} } ) {
                        $data->{$name} = $self->_coerce( $namespace, $subschema, $data->{$name} );
                    }

                    #~ namespace2package($namespace)->new(%$data);
                    $data;
                },
                ref => method( $namespace, $schema, $data ) {
                    $namespace = _namespace( $namespace, $schema->{ref} );
                    my $lexicon = $self->_locate_lexicon($namespace);
                    $lexicon // Carp::carp( 'Unknown type: ' . $namespace ) && return $data;
                    $self->_coerce( $namespace, $lexicon, $data );
                },
                union => method( $namespace, $schema, $data ) {
                    my @namespaces = map { _namespace( $namespace, $_ ) } @{ $schema->{refs} };
                    Carp::cluck 'Incorrect union type: ' . $data->{'$type'} unless grep { $data->{'$type'} eq $_ } @namespaces;
                    bless $self->_coerce( $data->{'$type'}, $self->_locate_lexicon( $data->{'$type'} ), $data ),
                        namespace2package( $data->{'$type'} );
                },
                unknown => method( $namespace, $schema, $data ) {$data},
                string  => method( $namespace, $schema, $data ) {
                    $data // return ();
                    if ( defined $schema->{format} ) {
                        if    ( $schema->{format} eq 'uri' )    { return URI->new($data); }
                        elsif ( $schema->{format} eq 'at-uri' ) { return At::Protocol::URI->new($data); }
                        elsif ( $schema->{format} eq 'cid' )    { return $data; }                           # TODO
                        elsif ( $schema->{format} eq 'datetime' ) {
                            return $data =~ /\D/ ? Time::Moment->from_string($data) : Time::Moment->from_epoch($data);
                        }
                        elsif ( $schema->{format} eq 'did' ) {
                            return At::Protocol::DID->new($data);
                        }
                        elsif ( $schema->{format} eq 'handle' ) {
                            return At::Protocol::Handle->new($data);
                        }
                        elsif ( $schema->{format} eq 'language' ) {
                            return $data;
                        }
                        warn $data;

                        #~ ddx $schema;
                        #~ ...;
                    }
                    $data;
                }
            );

            method _coerce ( $namespace, $schema, $data ) {
                $data // return ();
                return $coercions{ $schema->{type} }->( $self, $namespace, $schema, $data ) if defined $coercions{ $schema->{type} };

                #~ use Data::Dump;
                #~ ddx $schema;
                die 'Unknown coercion: ' . $schema->{type};
            }
        }
    };

    class At::Protocol::Session {
        field $accessJwt : param : reader //= ();    # only found on createSession, not getSession
        field $did : param : reader;
        field $didDoc : param          = ();          # spec says 'unknown' so I'm just gonna ignore it for now even with the dump
        field $email : param           = ();
        field $emailConfirmed : param  = ();
        field $handle : param : reader = ();
        field $refreshJwt : param : reader //= ();    # only found on createSession, not getSession
        field $active : param = ();                   # bool
        field $emailAuthFactor : param //= ();        # bool
        field $status : param          //= ();
        #
        ADJUST {
            # warn "ADJUST";
            $did            = At::Protocol::DID->new($did) unless builtin::blessed $did;
            $handle         = At::Protocol::Handle->new($handle) if defined $handle && !builtin::blessed $handle;
            $emailConfirmed = !!$emailConfirmed                  if defined $emailConfirmed;
        }

        # This could be used as part of a session resume system
        method _raw {
            +{  accessJwt => $accessJwt,
                did       => $did->_raw,
                defined $didDoc ? ( didDoc => $didDoc ) : (), defined $email ? ( email => $email ) : (),
                defined $emailConfirmed ? ( emailConfirmed => \!!$emailConfirmed ) : (),
                refreshJwt => $refreshJwt,
                defined $handle ? ( handle => $handle->_raw ) : (),
                active          => \!!$active,
                emailAuthFactor => \!!$emailAuthFactor
            };
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

    class At::UserAgent {
        field $accessJwt : param : reader  = ();
        field $refreshJwt : param : reader = ();

        method set_tokens ( $access, $refresh ) {
            $accessJwt  = $access;
            $refreshJwt = $refresh;
            $self->_set_bearer_token( 'Bearer ' . $accessJwt );
        }
        method get       ( $url, $req = () ) {...}
        method post      ( $url, $req = () ) {...}
        method websocket ( $url, $req = () ) {...}
        method _set_bearer_token ($token) {...}
    };

    class At::UserAgent::Tiny : isa(At::UserAgent) {

        # TODO: Error handling
        use HTTP::Tiny;
        use JSON::Tiny qw[decode_json encode_json];
        field $agent : param = HTTP::Tiny->new(
            agent           => sprintf( 'At.pm/%1.2f;Tiny ', $At::VERSION ),
            default_headers => { 'Content-Type' => 'application/json', Accept => 'application/json' }
        );

        method get ( $url, $req = () ) {
            my $res
                = $agent->get(
                $url . ( defined $req->{content} && keys %{ $req->{content} } ? '?' . $agent->www_form_urlencode( $req->{content} ) : '' ),
                { defined $req->{headers} ? ( headers => $req->{headers} ) : () } );

            #~ use Data::Dump;
            #~ warn $url . ( defined $req->{content} && keys %{ $req->{content} } ? '?' . _build_query_string( $req->{content} ) : '' );
            #~ ddx $res;
            $res->{content} = decode_json $res->{content} if $res->{content} && $res->{headers}{'content-type'} =~ m[application/json];
            $res->{content} = At::Error->new( message => $res->{content}{message}, fatal => 1 ) unless $res->{success};
            wantarray ? ( $res->{content}, $res->{headers} ) : $res->{content};
        }

        method post ( $url, $req = () ) {

            #~ use Data::Dump;
            #~ warn $url;
            #~ ddx $req;
            #~ ddx encode_json $req->{content} if defined $req->{content} && ref $req->{content};
            my $res = $agent->post(
                $url,
                {   defined $req->{headers} ? ( headers => $req->{headers} )                                                     : (),
                    defined $req->{content} ? ( content => ref $req->{content} ? encode_json $req->{content} : $req->{content} ) : ()
                }
            );
            $res->{content} = decode_json $res->{content} if $res->{content} && $res->{headers}{'content-type'} =~ m[application/json];
            $res->{content} = At::Error->new( message => $res->{content}{message}, fatal => 1 ) unless $res->{success};
            wantarray ? ( $res->{content}, $res->{headers} ) : $res->{content};
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
            $ua->transactor->name( sprintf( 'At.pm/%1.2f;Mojo', $At::VERSION ) );
            $ua;
            }
            ->();
        method agent {$agent}
        field $auth : param //= ();

        method get ( $url, $req = () ) {
            my $res = $agent->get(
                $url,
                defined $auth           ? { Authorization => $auth, defined $req->{headers} ? %{ $req->{headers} } : () } : (),
                defined $req->{content} ? ( form => $req->{content} )                                                     : ()
            );
            $res = $res->result;

            # todo: error handling
            if ( $res->is_success ) {
                return $res->content ? $res->headers->content_type =~ m[application/json] ? $res->json : $res->content : ();
            }
            elsif ( $res->is_error )    { CORE::say $res->message }
            elsif ( $res->code == 301 ) { CORE::say $res->headers->location }
            else                        { CORE::say 'Whatever...' }
        }

        method post ( $url, $req = () ) {

            #~ warn $url;
            my $res = $agent->post(
                $url,
                defined $auth ? { Authorization => $auth, defined $req->{headers} ? %{ $req->{headers} } : () } : (),
                defined $req->{content} ? ref $req->{content} ? ( json => $req->{content} ) : $req->{content} : ()
            )->result;

            # todo: error handling
            if ( $res->is_success ) {
                return $res->content ? $res->headers->content_type =~ m[application/json] ? $res->json : $res->content : ();
            }
            elsif ( $res->is_error )    { CORE::say $res->message }
            elsif ( $res->code == 301 ) { CORE::say $res->headers->location }
            else                        { CORE::say 'Whatever...' }
        }

        method websocket ( $url, $cb, $req = () ) {
            require CBOR::Free::SequenceDecoder;
            $agent->websocket(
                $url => { 'Sec-WebSocket-Extensions' => 'permessage-deflate' } => sub ( $ua, $tx ) {

                    #~ use Data::Dump;
                    #~ ddx $tx;
                    CORE::say 'WebSocket handshake failed!' and return unless $tx->is_websocket;

                    #~ CORE::say 'Subprotocol negotiation failed!' and return unless $tx->protocol;
                    #~ $tx->send({json => {test => [1, 2, 3]}});
                    $tx->on(
                        finish => sub ( $tx, $code, $reason ) {
                            CORE::say "WebSocket closed with status $code.";
                        }
                    );
                    CORE::state $decoder //= CBOR::Free::SequenceDecoder->new()->set_tag_handlers( 42 => sub { } );

                    #~ $tx->on(json => sub ($ws, $hash) { CORE::say "Message: $hash->{msg}" });
                    $tx->on(
                        message => sub ( $tx, $msg ) {
                            my $head = $decoder->give($msg);
                            my $body = $decoder->get;

                            #~ ddx $$head;
                            $$body->{blocks} = length $$body->{blocks} if defined $$body->{blocks};

                            #~ use Data::Dumper;
                            #~ CORE::say Dumper $$body;
                            $cb->($$body);

                            #~ CORE::say "WebSocket message: $msg";
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
};
1;
__END__
=encoding utf-8

=head1 NAME

At - The AT Protocol for Social Networking

=head1 SYNOPSIS

    use At;
    ...;

=head1 DESCRIPTION



=head1 See Also

TODO

=head1 LICENSE

This software is Copyright (c) 2024 by Sanko Robinson E<lt>sanko@cpan.orgE<gt>.

This is free software, licensed under:

  The Artistic License 2.0 (GPL Compatible)

See the F<LICENSE> file for full text.

=head1 AUTHOR

Sanko Robinson <sanko@cpan.org>

=begin stopwords


=end stopwords

=cut
