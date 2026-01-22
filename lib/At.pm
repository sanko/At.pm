use v5.40;
use feature 'class';
no warnings 'experimental::class', 'experimental::builtin', 'experimental::for_list';
class At v1.1.0 {
    use Carp qw[];
    use experimental 'try';
    use File::ShareDir::Tiny qw[dist_dir];
    use JSON::Tiny           qw[decode_json encode_json];
    use Path::Tiny           qw[path];
    use Digest::SHA          qw[sha256];
    use MIME::Base64         qw[encode_base64url];
    use Crypt::PK::ECC;
    use Crypt::PRNG qw[random_string];
    use Time::Moment;
    use URI;
    use warnings::register;
    use At::Error;
    use At::Protocol::URI;
    use At::Protocol::Session;
    use At::UserAgent;
    field $share : reader : param //= eval { dist_dir('At') } // 'share';
    field %lexicons : reader;
    field $http //= eval { require Mojo::UserAgent } ? At::UserAgent::Mojo->new() : At::UserAgent::Tiny->new();
    method http {$http}
    field $host : param : reader //= 'bsky.social';
    method set_host ($new) { $host = $new }
    field $session = ();
    field $oauth_state;
    field $dpop_key;
    field %ratelimits : reader;
    ADJUST {
        $share = path($share)       unless builtin::blessed $share;
        $host  = 'https://' . $host unless $host =~ /^https?:/;
        $host  = URI->new($host)    unless builtin::blessed $host;
    }

    # --- OAuth Implementation ---
    method _get_dpop_key() {
        unless ($dpop_key) {
            $dpop_key = Crypt::PK::ECC->new();
            $dpop_key->generate_key('secp256r1');
        }
        return $dpop_key;
    }

    method oauth_discover ($handle) {
        my $res = $self->resolve_handle($handle);
        if ( builtin::blessed($res) && $res->isa('At::Error') ) { $res->throw; }
        return unless $res && $res->{did};
        my $pds = $self->pds_for_did( $res->{did} );
        unless ($pds) { die "Could not resolve PDS for DID: " . $res->{did}; }
        my ($protected) = $http->get("$pds/.well-known/oauth-protected-resource");
        if ( builtin::blessed($protected) && $protected->isa('At::Error') ) { $protected->throw; }
        return unless $protected && $protected->{authorization_servers};
        my $auth_server = $protected->{authorization_servers}[0];
        my ($metadata) = $http->get("$auth_server/.well-known/oauth-authorization-server");
        if ( builtin::blessed($metadata) && $metadata->isa('At::Error') ) { $metadata->throw; }
        return { pds => $pds, auth_server => $auth_server, metadata => $metadata, did => $res->{did} };
    }

    method oauth_start ( $handle, $client_id, $redirect_uri, $scope = 'atproto' ) {
        my $discovery = $self->oauth_discover($handle);
        die "Failed to discover OAuth metadata for $handle" unless $discovery;
        my $chars          = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-._~';
        my $code_verifier  = Crypt::PRNG::random_string_from( $chars, 43 );
        my $code_challenge = encode_base64url( sha256($code_verifier) );
        $code_challenge =~ s/=+$//;
        my $state = Crypt::PRNG::random_string_from( $chars, 16 );
        $oauth_state = {
            discovery     => $discovery,
            code_verifier => $code_verifier,
            state         => $state,
            redirect_uri  => $redirect_uri,
            client_id     => $client_id,
            handle        => $handle,
            scope         => $scope,
        };

        # Prepare UA for DPoP
        $http->set_tokens( undef, undef, 'DPoP', $self->_get_dpop_key() );
        my $par_endpoint = $discovery->{metadata}{pushed_authorization_request_endpoint};
        my ($par_res) = $http->post(
            $par_endpoint => {
                headers  => { DPoP => $http->_generate_dpop_proof( $par_endpoint, 'POST' ) },
                encoding => 'form',
                content  => {
                    client_id             => $client_id,
                    response_type         => 'code',
                    code_challenge        => $code_challenge,
                    code_challenge_method => 'S256',
                    redirect_uri          => $redirect_uri,
                    state                 => $state,
                    scope                 => $scope,
                    aud                   => $discovery->{pds},
                }
            }
        );
        die "PAR failed: " . ( $par_res . "" ) if builtin::blessed $par_res;
        my $auth_uri = URI->new( $discovery->{metadata}{authorization_endpoint} );
        $auth_uri->query_form( client_id => $client_id, request_uri => $par_res->{request_uri} );
        return $auth_uri->as_string;
    }

    method oauth_callback ( $code, $state ) {
        die "OAuth state mismatch" unless $oauth_state && $state eq $oauth_state->{state};
        my $token_endpoint = $oauth_state->{discovery}{metadata}{token_endpoint};
        my $key            = $self->_get_dpop_key();
        my ($token_res)    = $http->post(
            $token_endpoint => {
                headers  => { DPoP => $http->_generate_dpop_proof( $token_endpoint, 'POST' ) },
                encoding => 'form',
                content  => {
                    grant_type    => 'authorization_code',
                    code          => $code,
                    client_id     => $oauth_state->{client_id},
                    redirect_uri  => $oauth_state->{redirect_uri},
                    code_verifier => $oauth_state->{code_verifier},
                    aud           => $oauth_state->{discovery}{pds},
                }
            }
        );
        die "Token exchange failed: " . ( $token_res . "" ) if builtin::blessed $token_res;
        $session = At::Protocol::Session->new(
            did          => $token_res->{sub},
            accessJwt    => $token_res->{access_token},
            refreshJwt   => $token_res->{refresh_token},
            handle       => $oauth_state->{handle},
            token_type   => 'DPoP',
            dpop_key_jwk => $key->export_key_jwk('private'),
            client_id    => $oauth_state->{client_id},
            scope        => $token_res->{scope},
        );
        $self->set_host( $oauth_state->{discovery}{pds} );
        return $http->set_tokens( $token_res->{access_token}, $token_res->{refresh_token}, 'DPoP', $key );
    }

    method oauth_refresh() {
        return unless $session && $session->refreshJwt && $session->token_type eq 'DPoP';
        my $discovery = $self->oauth_discover( $session->handle );
        return unless $discovery;
        my $token_endpoint = $discovery->{metadata}{token_endpoint};
        my $key            = $self->_get_dpop_key();
        my ($token_res)    = $http->post(
            $token_endpoint => {
                headers  => { DPoP => $http->_generate_dpop_proof( $token_endpoint, 'POST' ) },
                encoding => 'form',
                content  => {
                    grant_type    => 'refresh_token',
                    refresh_token => $session->refreshJwt,
                    client_id     => $session->client_id // '',
                    aud           => $discovery->{pds},
                }
            }
        );
        die "Refresh failed: " . ( $token_res . "" ) if builtin::blessed $token_res;
        $session = At::Protocol::Session->new(
            did          => $token_res->{sub},
            accessJwt    => $token_res->{access_token},
            refreshJwt   => $token_res->{refresh_token},
            handle       => $session->handle,
            token_type   => 'DPoP',
            dpop_key_jwk => $key->export_key_jwk('private'),
            client_id    => $session->client_id,
            scope        => $token_res->{scope},
        );
        return $http->set_tokens( $token_res->{access_token}, $token_res->{refresh_token}, 'DPoP', $key );
    }

    method collection_scope ( $collection, $action = 'create' ) {
        return "repo:$collection?action=$action";
    }

    # --- Legacy Auth ---
    method login( $identifier, $password ) {
        warnings::warnif( At => 'login() (com.atproto.server.createSession) is deprecated. Please use OAuth instead.' );
        my $res = $self->post( 'com.atproto.server.createSession' => { identifier => $identifier, password => $password } );
        if   ( $res && !builtin::blessed($res) ) { $session = At::Protocol::Session->new(%$res); }
        else                                     { $session = $res; }
        return $session ? $http->set_tokens( $session->accessJwt, $session->refreshJwt ) : $session;
    }

    method resume ( $accessJwt, $refreshJwt, $token_type = 'Bearer', $dpop_key_jwk = (), $client_id = () ) {
        my $access  = $self->_decode_token($accessJwt);
        my $refresh = $self->_decode_token($refreshJwt);
        my $key;
        if ( $token_type eq 'DPoP' && $dpop_key_jwk ) {
            $key = Crypt::PK::ECC->new();
            $key->import_key_jwk($dpop_key_jwk);
            $dpop_key = $key;
        }
        if ( time > $access->{exp} && time < $refresh->{exp} ) {
            if ( $token_type eq 'DPoP' ) { return $self->oauth_refresh(); }
            else {
                my $res = $self->post( 'com.atproto.server.refreshSession' => { refreshJwt => $refreshJwt } );
                if   ( $res && !builtin::blessed($res) ) { $session = At::Protocol::Session->new(%$res); }
                else                                     { $session = $res; }
                return $session ? $http->set_tokens( $session->accessJwt, $session->refreshJwt, $token_type, $key ) : $session;
            }
        }
        $session = At::Protocol::Session->new(
            did          => $access->{sub},
            accessJwt    => $accessJwt,
            refreshJwt   => $refreshJwt,
            token_type   => $token_type,
            dpop_key_jwk => $dpop_key_jwk,
            client_id    => $client_id
        );
        return $http->set_tokens( $accessJwt, $refreshJwt, $token_type, $key );
    }

    method _decode_token ($token) {
        use MIME::Base64 qw[decode_base64];
        my ( $header, $payload, $sig ) = split /\./, $token;
        $payload =~ tr[-_][+/];
        decode_json decode_base64 $payload;
    }

    # --- XRPC & Lexicons ---
    method _locate_lexicon($fqdn) {
        unless ( defined $lexicons{$fqdn} ) {
            my $base_fqdn = $fqdn =~ s[#(.+)$][]r;
            my @namespace = split /\./, $base_fqdn;
            my @search    = (
                $share->child('lexicons'),
                defined $ENV{HOME} ? path( $ENV{HOME}, '.cache', 'atproto', 'lexicons' ) : (),
                path( 'share', 'lexicons' )
            );
            my $lex_file;
            for my $dir (@search) {
                next unless defined $dir;
                my $possible = $dir->child( @namespace[ 0 .. $#namespace - 1 ], $namespace[-1] . '.json' );
                if ( $possible->exists ) { $lex_file = $possible; last; }
            }
            if ( !$lex_file ) { $lex_file = $self->_fetch_lexicon($base_fqdn); }
            if ( $lex_file && $lex_file->exists ) {
                my $json = decode_json $lex_file->slurp_raw;
                for my $def ( keys %{ $json->{defs} } ) {
                    $lexicons{ $base_fqdn . ( $def eq 'main' ? '' : '#' . $def ) } = $json->{defs}{$def};
                    $lexicons{ $base_fqdn . '#main' } = $json->{defs}{$def} if $def eq 'main';
                }
            }
        }
        $lexicons{$fqdn};
    }

    method _fetch_lexicon($base_fqdn) {
        my @namespace = split /\./, $base_fqdn;
        my $rel_path  = join( '/', @namespace[ 0 .. $#namespace - 1 ], $namespace[-1] . '.json' );
        my $url       = "https://raw.githubusercontent.com/bluesky-social/atproto/main/lexicons/$rel_path";
        my ( $content, $headers ) = $http->get($url);
        if ( $content && !builtin::blessed($content) ) {
            my $cache_dir = defined $ENV{HOME} ? path( $ENV{HOME}, '.cache', 'atproto', 'lexicons' ) : path( '.cache', 'atproto', 'lexicons' );
            $cache_dir->mkpath;
            my $lex_file = $cache_dir->child( @namespace[ 0 .. $#namespace - 1 ], $namespace[-1] . '.json' );
            $lex_file->parent->mkpath;
            $lex_file->spew_raw( JSON::Tiny::encode_json($content) );
            return $lex_file;
        }
        return;
    }

    method get( $fqdn, $args = (), $headers = {} ) {
        my $lexicon = $self->_locate_lexicon($fqdn);
        $self->_ratecheck('global');
        my ( $content, $res_headers )
            = $http->get( sprintf( '%s/xrpc/%s', $host, $fqdn ), { defined $args ? ( content => $args ) : (), headers => $headers } );
        $self->ratelimit_( { map { $_ => $res_headers->{ 'ratelimit-' . $_ } } qw[limit remaining reset] }, 'global' );
        if ( $lexicon && !builtin::blessed $content ) {
            $content = $self->_coerce( $fqdn, $lexicon->{output}{schema}, $content );
        }
        wantarray ? ( $content, $res_headers ) : $content;
    }

    method post( $fqdn, $args = (), $headers = {} ) {
        my @namespace     = split /\./, $fqdn;
        my $lexicon       = $self->_locate_lexicon($fqdn);
        my $rate_category = $namespace[-1] =~ m[^(updateHandle|createAccount|createSession|deleteAccount|resetPassword)$] ? $namespace[-1] : 'global';
        my $_rate_meta    = $rate_category eq 'createSession' ? $args->{identifier} : $rate_category eq 'updateHandle' ? $args->{did} : ();
        $self->_ratecheck( $rate_category, $_rate_meta );
        my ( $content, $res_headers )
            = $http->post( sprintf( '%s/xrpc/%s', $host, $fqdn ), { defined $args ? ( content => $args ) : (), headers => $headers } );
        $self->ratelimit_( { map { $_ => $res_headers->{ 'ratelimit-' . $_ } } qw[limit remaining reset] }, $rate_category, $_rate_meta );
        if ( $lexicon && !builtin::blessed $content ) {
            $content = $self->_coerce( $fqdn, $lexicon->{output}{schema}, $content );
        }
        return wantarray ? ( $content, $res_headers ) : $content;
    }
    method subscribe( $id, $cb ) { $self->http->websocket( sprintf( '%s/xrpc/%s', $host, $id ), $cb ); }

    # --- Coercion Logic ---
    my %coercions = (
        array => method( $namespace, $schema, $data ) {
            [ map { $self->_coerce( $namespace, $schema->{items}, $_ ) } @$data ]
        },
        boolean => method( $namespace, $schema, $data ) { !!$data },
        bytes   => method( $namespace, $schema, $data ) {$data},
        blob    => method( $namespace, $schema, $data ) {$data},
        integer => method( $namespace, $schema, $data ) { int $data },
        object  => method( $namespace, $schema, $data ) {
            for my ( $name, $subschema )( %{ $schema->{properties} } ) {
                $data->{$name} = $self->_coerce( $namespace, $subschema, $data->{$name} );
            }
            $data;
        },
        ref => method( $namespace, $schema, $data ) {
            my $target_namespace = $self->_resolve_namespace( $namespace, $schema->{ref} );
            my $lexicon          = $self->_locate_lexicon($target_namespace);
            return $data unless $lexicon;
            $self->_coerce( $target_namespace, $lexicon, $data );
        },
        union   => method( $namespace, $schema, $data ) {$data},
        unknown => method( $namespace, $schema, $data ) {$data},
        string  => method( $namespace, $schema, $data ) {
            $data // return ();
            if ( defined $schema->{format} ) {
                if    ( $schema->{format} eq 'uri' )    { return URI->new($data); }
                elsif ( $schema->{format} eq 'at-uri' ) { return At::Protocol::URI->new($data); }
                elsif ( $schema->{format} eq 'datetime' ) {
                    return $data =~ /\D/ ? Time::Moment->from_string($data) : Time::Moment->from_epoch($data);
                }
                elsif ( $schema->{format} eq 'did' ) {
                    require At::Protocol::DID;
                    return At::Protocol::DID->new($data);
                }
                elsif ( $schema->{format} eq 'handle' ) {
                    require At::Protocol::Handle;
                    return At::Protocol::Handle->new($data);
                }
            }
            $data;
        }
    );

    method _coerce ( $namespace, $schema, $data ) {
        $data // return ();
        return $coercions{ $schema->{type} }->( $self, $namespace, $schema, $data ) if defined $coercions{ $schema->{type} };
        return $data;
    }

    method _resolve_namespace ( $l, $r ) {
        return $r      if $r =~ m[.+#];
        return $` . $r if $l =~ m[#.+];
        $l . $r;
    }

    # --- Identity & Helpers ---
    method did()                   { $session ? $session->did . "" : undef; }
    method resolve_handle($handle) { $self->get( 'com.atproto.identity.resolveHandle' => { handle => $handle } ); }

    method resolve_did ($did) {
        if ( $did =~ /^did:plc:(.+)$/ ) {
            my ($content) = $http->get("https://plc.directory/$did");
            return $content;
        }
        elsif ( $did =~ /^did:web:(.+)$/ ) {
            my $domain = $1;
            $domain =~ s/:/\//g;
            my ($content) = $http->get("https://$domain/.well-known/did.json");
            return $content;
        }
        return;
    }

    method pds_for_did ($did) {
        my $doc = $self->resolve_did($did);
        return unless $doc && ref $doc eq 'HASH' && $doc->{service};
        for my $service ( @{ $doc->{service} } ) {
            return $service->{serviceEndpoint} if $service->{type} eq 'AtprotoPersonalDataServer';
        }
        return;
    }
    method session() { $session //= $self->get('com.atproto.server.getSession'); $session; }
    sub _now         { Time::Moment->now }
    method _duration ($seconds) { $seconds || return '0 seconds'; $seconds = abs $seconds; return "$seconds seconds"; }
    method ratelimit_ ( $rate, $type, $meta //= () ) { defined $meta ? $ratelimits{$type}{$meta} = $rate : $ratelimits{$type} = $rate; }
    method _ratecheck( $type, $meta //= () ) { my $rate = defined $meta ? $ratelimits{$type}{$meta} : $ratelimits{$type}; $rate->{reset} // return; }
} 1;
