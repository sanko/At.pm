use v5.42;
use feature 'class';
use experimental 'try';
no warnings 'experimental::class';
use URI;
use JSON::Tiny;
use Digest::SHA;
use MIME::Base64;
use Crypt::JWT;
use Crypt::PRNG;

class At::UserAgent {
    field $accessJwt  : param  : reader = ();
    field $refreshJwt : param  : reader = ();
    field $token_type : param  : reader = 'Bearer';
    field $dpop_key   : param  : reader = ();
    field $dpop_nonce : param  : reader : writer = ();
    field $auth       : reader : writer = undef;

    method set_tokens ( $access, $refresh, $type = 'Bearer', $key = () ) {
        $accessJwt  = $access;
        $refreshJwt = $refresh;
        $token_type = $type;
        $dpop_key   = $key;
        if ( defined $accessJwt ) {
            $self->_set_auth_header( $token_type . ' ' . $accessJwt );
        }
        else {
            $self->_set_auth_header(undef);
        }
    }

    method _generate_dpop_proof ( $url, $method ) {
        return unless $dpop_key;
        my $jwk_json = $dpop_key->export_key_jwk('public');
        my $jwk      = JSON::Tiny::decode_json($jwk_json);
        my $now      = time;
        my $htu      = URI->new($url);
        $htu->query(undef);
        $htu->fragment(undef);
        my $chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-._~';
        my $payload
            = { jti => Crypt::PRNG::random_string_from( $chars, 32 ), htm => $method, htu => $htu->as_string, iat => $now, exp => $now + 60, };
        $payload->{nonce} = $dpop_nonce if defined $dpop_nonce;

        if ($accessJwt) {
            $payload->{ath} = MIME::Base64::encode_base64url( Digest::SHA::sha256($accessJwt) );
            $payload->{ath} =~ s/=+$//;
        }
        return Crypt::JWT::encode_jwt( payload => $payload, key => $dpop_key, alg => 'ES256', extra_headers => { typ => 'dpop+jwt', jwk => $jwk } );
    }
    method _set_auth_header ($token)            { die "Abstract" }
    method get              ( $url, $req = () ) { die "Abstract" }
    method post             ( $url, $req = () ) { die "Abstract" }
    method websocket        ( $url, $cb )       { die "Abstract" }
}

class At::UserAgent::Tiny : isa(At::UserAgent) {
    use HTTP::Tiny;
    field $agent : param
        = HTTP::Tiny->new( agent => 'At.pm/Tiny', default_headers => { 'Content-Type' => 'application/json', Accept => 'application/json' } );

    method get ( $url, $req = () ) {
        $req->{headers}{DPoP} = $self->_generate_dpop_proof( $url, 'GET' ) if $self->token_type eq 'DPoP';
        my $res
            = $agent->get( $url . ( defined $req->{content} && keys %{ $req->{content} } ? '?' . $agent->www_form_urlencode( $req->{content} ) : '' ),
            { defined $req->{headers} ? ( headers => $req->{headers} ) : () } );
        $res->{content} = JSON::Tiny::decode_json( $res->{content} ) if $res->{content} && ( $res->{headers}{'content-type'} // '' ) =~ m[json];
        unless ( $res->{success} ) {
            my $msg = $res->{reason} // 'Unknown error';
            if ( ref $res->{content} eq 'HASH' ) {
                my $json    = $res->{content};
                my $details = $json->{error} // '';
                if ( $json->{message} && $json->{message} ne $details ) {
                    $details .= ( $details ? ': ' : '' ) . $json->{message};
                }
                $msg .= ": " . $details                    if $details;
                $msg .= " - " . $json->{error_description} if $json->{error_description};
            }
            elsif ( $res->{content} ) {
                $msg .= " ($res->{content})";
            }
            $res->{content} = At::Error->new( message => $msg, fatal => 1 );
        }
        wantarray ? ( $res->{content}, $res->{headers} ) : $res->{content};
    }

    method post ( $url, $req = () ) {
        $req->{headers}{DPoP} = $self->_generate_dpop_proof( $url, 'POST' ) if $self->token_type eq 'DPoP';
        my $content;
        if ( defined $req->{content} ) {
            if ( $req->{encoding} && $req->{encoding} eq 'form' ) {
                $content = $agent->www_form_urlencode( $req->{content} );
                $req->{headers}{'Content-Type'} = 'application/x-www-form-urlencoded';
            }
            elsif ( ref $req->{content} ) {
                $content = JSON::Tiny::encode_json( $req->{content} );
                $req->{headers}{'Content-Type'} = 'application/json';
            }
            else {
                $content = $req->{content};
            }
        }
        my $res = $agent->post( $url,
            { defined $req->{headers} ? ( headers => $req->{headers} ) : (), defined $content ? ( content => $content ) : () } );
        $res->{content} = JSON::Tiny::decode_json( $res->{content} ) if $res->{content} && ( $res->{headers}{'content-type'} // '' ) =~ m[json];
        unless ( $res->{success} ) {
            my $msg = $res->{reason} // 'Unknown error';
            if ( ref $res->{content} eq 'HASH' ) {
                my $json    = $res->{content};
                my $details = $json->{error} // '';
                if ( $json->{message} && $json->{message} ne $details ) {
                    $details .= ( $details ? ': ' : '' ) . $json->{message};
                }
                $msg .= ": " . $details                    if $details;
                $msg .= " - " . $json->{error_description} if $json->{error_description};
            }
            elsif ( $res->{content} ) {
                $msg .= " ($res->{content})";
            }
            $res->{content} = At::Error->new( message => $msg, fatal => 1 );
        }
        wantarray ? ( $res->{content}, $res->{headers} ) : $res->{content};
    }

    method websocket ( $url, $cb ) {
        die "At::UserAgent::Tiny does not support WebSockets. Please install Mojo::UserAgent.";
    }

    method _set_auth_header ($token) {
        $self->set_auth($token);
        $agent->{default_headers}{Authorization} = $token;
    }
}

class At::UserAgent::Mojo : isa(At::UserAgent) {
    field $agent;
    ADJUST {
        require Mojo::UserAgent;
        $agent = Mojo::UserAgent->new;
    }

    method get ( $url, $req = () ) {
        my $headers = { %{ $req->{headers} // {} } };
        $headers->{Authorization} = $self->auth                                if defined $self->auth;
        $headers->{DPoP}          = $self->_generate_dpop_proof( $url, 'GET' ) if $self->token_type eq 'DPoP';
        if ($At::DEBUG) { warn "DEBUG: GET $url\nHeaders: " . JSON::Tiny::encode_json($headers) . "\n"; }
        my $tx  = $agent->get( $url, $headers, defined $req->{content} ? ( form => $req->{content} ) : () );
        my $res = $tx->result;
        if ($At::DEBUG)                                        { warn "DEBUG: Response Status: " . $res->code . "\nBody: " . $res->body . "\n"; }
        if ( my $nonce = $res->headers->header('DPoP-Nonce') ) { $self->set_dpop_nonce($nonce); }

        if ( $res->code == 401 || $res->code == 400 ) {
            my $body = $res->body // '';
            if ( $body =~ /use_dpop_nonce/i ) {
                if ($At::DEBUG) { warn "DEBUG: Retrying GET with Nonce...\n"; }
                $headers->{DPoP} = $self->_generate_dpop_proof( $url, 'GET' ) if $self->token_type eq 'DPoP';
                $tx              = $agent->get( $url, $headers, defined $req->{content} ? ( form => $req->{content} ) : () );
                $res             = $tx->result;
                if ($At::DEBUG)                                        { warn "DEBUG: Retry Status: " . $res->code . "\nBody: " . $res->body . "\n"; }
                if ( my $nonce = $res->headers->header('DPoP-Nonce') ) { $self->set_dpop_nonce($nonce); }
            }
        }
        if ( $res->is_success ) {
            my $content = $res->body ? ( $res->headers->content_type // '' ) =~ m[json] ? $res->json : $res->body : ();
            return wantarray ? ( $content, $res->headers->to_hash ) : $content;
        }
        my $msg = $res->message;
        if ( my $body = $res->body ) {
            my $json;
            try { $json = JSON::Tiny::decode_json($body) }
            catch ($e) { }
            if ($json) {
                my $details = $json->{error} // '';
                if ( $json->{message} && $json->{message} ne $details ) {
                    $details .= ( $details ? ': ' : '' ) . $json->{message};
                }
                $msg .= ": " . $details                    if $details;
                $msg .= " - " . $json->{error_description} if $json->{error_description};
            }
            else {
                $msg .= " ($body)";
            }
        }
        return At::Error->new( message => $msg, fatal => 1 );
    }

    method post ( $url, $req = () ) {
        my $headers = { %{ $req->{headers} // {} } };
        $headers->{Authorization} = $self->auth                                 if defined $self->auth;
        $headers->{DPoP}          = $self->_generate_dpop_proof( $url, 'POST' ) if $self->token_type eq 'DPoP';
        my %args;
        if ( defined $req->{content} ) {
            if    ( $req->{encoding} && $req->{encoding} eq 'form' ) { $args{form}    = $req->{content}; }
            elsif ( ref $req->{content} )                            { $args{json}    = $req->{content}; }
            else                                                     { $args{content} = $req->{content}; }
        }
        if ($At::DEBUG) {
            warn "DEBUG: POST $url\nHeaders: " . JSON::Tiny::encode_json($headers) . "\nArgs: " . JSON::Tiny::encode_json( \%args ) . "\n";
        }
        my $tx  = $agent->post( $url, $headers, %args );
        my $res = $tx->result;
        if ($At::DEBUG)                                        { warn "DEBUG: Response Status: " . $res->code . "\nBody: " . $res->body . "\n"; }
        if ( my $nonce = $res->headers->header('DPoP-Nonce') ) { $self->set_dpop_nonce($nonce); }
        if ( $res->code == 401 || $res->code == 400 ) {
            my $body = $res->body // '';
            if ( $body =~ /use_dpop_nonce/i ) {
                if ($At::DEBUG) { warn "DEBUG: Retrying POST with Nonce...\n"; }
                $headers->{DPoP} = $self->_generate_dpop_proof( $url, 'POST' ) if $self->token_type eq 'DPoP';
                $tx              = $agent->post( $url, $headers, %args );
                $res             = $tx->result;
                if ($At::DEBUG)                                        { warn "DEBUG: Retry Status: " . $res->code . "\nBody: " . $res->body . "\n"; }
                if ( my $nonce = $res->headers->header('DPoP-Nonce') ) { $self->set_dpop_nonce($nonce); }
            }
        }
        if ( $res->is_success ) {
            my $content = $res->body ? ( $res->headers->content_type // '' ) =~ m[json] ? $res->json : $res->body : ();
            return wantarray ? ( $content, $res->headers->to_hash ) : $content;
        }
        my $msg = $res->message;
        if ( my $body = $res->body ) {
            my $json;
            try { $json = JSON::Tiny::decode_json($body) }
            catch ($e) { }
            if ($json) {
                my $details = $json->{error} // '';
                if ( $json->{message} && $json->{message} ne $details ) {
                    $details .= ( $details ? ': ' : '' ) . $json->{message};
                }
                $msg .= ": " . $details                    if $details;
                $msg .= " - " . $json->{error_description} if $json->{error_description};
            }
            else {
                $msg .= " ($body)";
            }
        }
        return At::Error->new( message => $msg, fatal => 1 );
    }

    method websocket ( $url, $cb ) {
        $agent->websocket(
            $url => sub ( $ua, $tx ) {
                if ( !$tx->is_websocket ) {
                    $cb->( undef, At::Error->new( message => "WebSocket handshake failed", fatal => 1 ) );
                    return;
                }
                $tx->on(
                    message => sub ( $tx, $msg ) {
                        $cb->( $msg, undef );
                    }
                );
                $tx->on(
                    finish => sub ( $tx, $code, $reason ) {

                        # Optionally handle finish
                    }
                );
            }
        );
    }
    method _set_auth_header ($token) { $self->set_auth($token); }
}

class At::UserAgent::IOAsync : isa(At::UserAgent) {
    field $loop : param //= ();
    field $http;
    ADJUST {
        require IO::Async::Loop;
        require Net::Async::HTTP;
        if ( !defined $loop ) {
            try { $loop = IO::Async::Loop->new; }
            catch ($e) { die "Failed to create IO::Async::Loop: $e"; }
        }
        $http = Net::Async::HTTP->new( user_agent => 'At.pm/IOAsync', );
        $loop->add($http);
    }

    method get ( $url, $req = () ) {
        require HTTP::Request;
        require URI;
        my $uri = URI->new($url);
        if ( defined $req->{content} ) {
            $uri->query_form( $req->{content} );
        }
        my $headers = [ %{ $req->{headers} // {} } ];
        push @$headers, 'Authorization' => $self->auth                                if defined $self->auth;
        push @$headers, 'DPoP'          => $self->_generate_dpop_proof( $url, 'GET' ) if $self->token_type eq 'DPoP';
        my $request = HTTP::Request->new( GET => $uri, $headers );
        my $future  = $http->do_request( request => $request );

        # Handle DPoP Nonce retry
        my $res = $loop->await($future);
        if ( my $nonce = $res->header('DPoP-Nonce') ) { $self->set_dpop_nonce($nonce); }
        if ( ( $res->code == 401 || $res->code == 400 ) && $res->content =~ /use_dpop_nonce/i ) {
            my $dpop = $self->_generate_dpop_proof( $url, 'GET' );
            $request->header( DPoP => $dpop );
            $res = $loop->await( $http->do_request( request => $request ) );
            if ( my $nonce = $res->header('DPoP-Nonce') ) { $self->set_dpop_nonce($nonce); }
        }
        if ( $res->is_success ) {
            my $body    = $res->content;
            my $content = $body && ( $res->content_type // '' ) =~ m[json] ? JSON::Tiny::decode_json($body) : $body;
            return wantarray ? ( $content, { map { $_ => $res->header($_) } $res->header_field_names } ) : $content;
        }
        return $self->_handle_error($res);
    }

    method post ( $url, $req = () ) {
        require HTTP::Request;
        require URI;
        my $headers = [ %{ $req->{headers} // {} } ];
        push @$headers, 'Authorization' => $self->auth                                 if defined $self->auth;
        push @$headers, 'DPoP'          => $self->_generate_dpop_proof( $url, 'POST' ) if $self->token_type eq 'DPoP';
        my $content;
        my $content_type = 'application/json';
        if ( defined $req->{content} ) {
            if ( $req->{encoding} && $req->{encoding} eq 'form' ) {
                my $uri = URI->new;
                $uri->query_form( $req->{content} );
                $content      = $uri->query;
                $content_type = 'application/x-www-form-urlencoded';
            }
            elsif ( ref $req->{content} ) {
                $content = JSON::Tiny::encode_json( $req->{content} );
            }
            else {
                $content = $req->{content};
            }
        }
        push @$headers, 'Content-Type' => $content_type;
        my $request = HTTP::Request->new( POST => $url, $headers, $content );
        my $future  = $http->do_request( request => $request );
        my $res     = $loop->await($future);
        if ( my $nonce = $res->header('DPoP-Nonce') ) { $self->set_dpop_nonce($nonce); }
        if ( ( $res->code == 401 || $res->code == 400 ) && $res->content =~ /use_dpop_nonce/i ) {
            my $dpop = $self->_generate_dpop_proof( $url, 'POST' );
            $request->header( DPoP => $dpop );
            $res = $loop->await( $http->do_request( request => $request ) );
            if ( my $nonce = $res->header('DPoP-Nonce') ) { $self->set_dpop_nonce($nonce); }
        }
        if ( $res->is_success ) {
            my $body    = $res->content;
            my $content = $body && ( $res->content_type // '' ) =~ m[json] ? JSON::Tiny::decode_json($body) : $body;
            return wantarray ? ( $content, { map { $_ => $res->header($_) } $res->header_field_names } ) : $content;
        }
        return $self->_handle_error($res);
    }

    method websocket ( $url, $cb ) {
        require Net::Async::WebSocket::Client;
        my $ws = Net::Async::WebSocket::Client->new(
            on_frame => sub ( $self, $frame ) {
                $cb->( $frame, undef );
            },
        );
        $loop->add($ws);
        $ws->connect( url => $url )->on_done(
            sub {
                # Connected
            }
        )->on_fail(
            sub ($err) {
                $cb->( undef, At::Error->new( message => "WebSocket failed: $err", fatal => 1 ) );
            }
        );
    }

    method _handle_error ($res) {
        my $msg = $res->message;
        if ( my $body = $res->content ) {
            my $json;
            try { $json = JSON::Tiny::decode_json($body) }
            catch ($e) { }
            if ($json) {
                my $details = $json->{error} // '';
                if ( $json->{message} && $json->{message} ne $details ) {
                    $details .= ( $details ? ': ' : '' ) . $json->{message};
                }
                $msg .= ": " . $details                    if $details;
                $msg .= " - " . $json->{error_description} if $json->{error_description};
            }
            else {
                $msg .= " ($body)";
            }
        }
        return At::Error->new( message => $msg, fatal => 1 );
    }
    method _set_auth_header ($token) { $self->set_auth($token); }
}
1;
__END__

=pod

=encoding utf-8

=head1 NAME

At::UserAgent - Abstract Base Class for AT Protocol User Agents

=head1 DESCRIPTION

C<At::UserAgent> defines the interface for HTTP clients used by L<At>. It handles DPoP proof generation, automatic
nonce management, and authentication headers.

=head1 SUBCLASSES

=over 4

=item L<At::UserAgent::Mojo>

Uses L<Mojo::UserAgent>. Recommended for asynchronous or high-performance applications.

=item L<At::UserAgent::IOAsync>

Uses L<Net::Async::HTTP> and L<IO::Async::Loop>. Recommended for projects already using L<IO::Async>.

=item L<At::UserAgent::Tiny>

Uses L<HTTP::Tiny>. A lightweight, zero-dependency alternative. Does not support firehose/WebSockets.

=back

=head1 ATTRIBUTES

=head2 C<accessJwt()>

The current access token.

=head2 C<token_type()>

The token type (e.g., 'DPoP' or 'Bearer').

=head2 C<dpop_key()>

The L<Crypt::PK::ECC> key used for DPoP signing.

=head1 METHODS

=head2 C<set_tokens( $access, $refresh, $type, $key )>

Sets the current authentication tokens and keys.

=head2 C<get( $url, [ \%options ] )>

Performs an HTTP GET request.

=head2 C<post( $url, [ \%options ] )>

Performs an HTTP POST request.

=head1 AUTHOR

Sanko Robinson E<lt>sanko@cpan.orgE<gt>

=head1 LICENSE

Copyright (c) 2024-2026 Sanko Robinson. License: Artistic License 2.0.

=cut
