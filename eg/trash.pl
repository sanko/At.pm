use strict;
use warnings;
use Data::Dump;
use 5.38.0;
use JSON::Tiny qw[decode_json];
no warnings qw[experimental::for_list];
use File::Find;

# reassign STDOUT, STDERR
open my $log_fh, '>', './output.pm';
local *STDOUT = $log_fh;
local *STDERR = $log_fh;

#~ use experimental 'signatures';
#~ use diagnostics;
$|++;

#~ https://atproto.com/specs/lexicon
#~ https://github.com/bluesky-social/atproto/blob/main/lexicons/app/bsky/feed/post.json
my %map;
use Path::Tiny;
use File::Spec::Functions qw[rel2abs];
sub id2pkg { my $id = shift; $id =~ s[\.][::]g; return $id; }
my $obj_adj;
$obj_adj = {
    array => sub {
        my ( $name, $schema ) = @_;
        ddx $schema;

        #~ ...;
        #~ say '        $' . $name . ';';
    },
    blob => sub {    # TODO: accept filenames and slurp them?
        my ( $name, $schema ) = @_;
        ddx $schema;
        say '        Carp::cluck q[' .
            $name .
            ' is too large; max size: ' .
            $schema->{maxSize} .
            ' bytes] if length $' .
            $name . ' > ' .
            $schema->{maxSize} . ';';
    },
    'at-uri' => sub {
        my ( $name, $schema ) = @_;
        ddx $schema;
        ...;
        delete $schema->{format};
        say '        $' . $name . ' = URI->new($' . $name . ') unless builtin::blessed $' . $name . ';';
    },
    boolean => sub {
        my ( $name, $schema ) = @_;
        ddx $schema;
        say '        $' . $name . ( ' //= ' . ( $schema->{default} ? 1 : 0 ) ) . ';' if defined $schema->{default};
    },
    bytes => sub {
        my ( $name, $schema ) = @_;
        ddx $schema;
        say '        Carp::cluck q[' .
            $name .
            ' is too large; max size: ' .
            $schema->{maxLength} .
            ' bytes] if length $' .
            $name . ' > ' .
            $schema->{maxLength} . ';';
    },
    'cid-link' => sub {
        my ( $name, $schema ) = @_;

        # https://github.com/multiformats/cid
        say '        $' . $name . ' = URI->new($' . $name . ') unless builtin::blessed $' . $name . ';';
    },
    integer => sub {
        my ( $name, $schema ) = @_;
        ddx $schema;
        say '        $' . $name . ' //= ' . $schema->{default} . ';' if defined $schema->{default};
        die                                                          if defined $schema->{format};
    },
    ref => => sub {
        my ( $name, $schema ) = @_;
        ddx $schema;

        #~ ...;
        #~ say '        $' . $name . ';';
    },
    string => sub {
        my ( $name, $schema ) = @_;
        ddx $schema;

        #say '        $' . $name . ';';
        say '        $' . $name . ' //= ' . $schema->{default} . ';' if defined $schema->{default};
        if ( defined $schema->{format} ) {
            if ( $schema->{format} eq 'at-uri' ) {
                say '        $' . $name . ' = URI->new($' . $name . ') unless builtin::blessed $' . $name . ';';
            }
            elsif ( $schema->{format} eq 'datetime' ) {
                say '        $' . $name . ' = DateTime::Tiny->new( $' . $name . ' ) unless builtin::blessed $' . $name . ';';
            }
            elsif ( $schema->{format} eq 'cid' ) {

                # https://github.com/multiformats/cid
            }
            elsif ( $schema->{format} eq 'did' ) {
                say '        $' . $name . ' = At::Protocol::DID->new( uri => $' . $name . ' ) unless builtin::blessed $' . $name . ';';
            }
            elsif ( $schema->{format} eq 'handle' ) {

                # I don't think handles need any sort of structure
            }
            elsif ( $schema->{format} eq 'nsid' ) {

                # https://atproto.com/specs/nsid
            }
            elsif ( $schema->{format} eq 'uri' ) {
                say '        $' . $name . ' = URI->new($' . $name . ') unless builtin::blessed $' . $name . ';';
            }
            else {
                die $schema->{format};
            }
        }
        if ( defined $schema->{knownValues} ) {
            say '        Carp::cluck q[' .
                $name .
                ' is an unknown value] unless grep { $' .
                $name .
                ' eq $_ } qw[' .
                ( join ' ', @{ $schema->{knownValues} } ) . '];';
        }
        if ( defined $schema->{maxGraphemes} ) {
            say sprintf '        Carp::cluck q[%s is too long; expected %s characters or fewer] if bytes::length $%s > %d;', $name,
                $schema->{maxGraphemes}, $name, $schema->{maxGraphemes};
        }
        if ( defined $schema->{maxLength} ) {
            say sprintf '        Carp::cluck q[%s is too long; expected %s bytes or fewer] if length $%s > %d;', $name, $schema->{maxLength}, $name,
                $schema->{maxLength};
        }
    },
    union => sub {
        my ( $name, $schema ) = @_;
        ddx $schema;

        #...;
        say '# Todo: union        $' . $name . ';';
    },
    unknown => sub {
        my ( $name, $schema ) = @_;
        ddx $schema;

        #say '        $' . $name . ';';
    },
};

sub get {
    my ($file) = @_;

    #~ my $parsed
    #~ = decode_json $ua->get( sprintf 'https://github.com/bluesky-social/atproto/raw/main/lexicons/%s.json', join '/', split /\./, $id )->{content};
    #~ say sprintf '# https://github.com/bluesky-social/atproto/raw/main/lexicons/%s.json', join '/', split /\./, $id;
    my $parsed    = decode_json Path::Tiny->new($file)->slurp;
    my $id        = $parsed->{id};
    my @namespace = ( 'At', 'Lexicon', split /\./, $id );
    my $method    = pop @namespace;
    my $package   = join '::', @namespace;

    #~ say 'class At::Lexicon::' . $package . ' {';
    #~ ddx $parsed;
    for my ($name)( sort keys %{ $parsed->{defs} } ) {
        my $schema = $parsed->{defs}{$name};
        next if defined $schema->{description} && $schema->{description} =~ /Deprecated/;
        warn "# $id";
        ddx $schema;
        if ( $schema->{type} eq 'procedure' || $schema->{type} eq 'query' ) {
            say q[class ] . $package . q[;];
            say q[  method ] . $method . ( defined $schema->{input} ? q[ (%args)] : '()' ) . q[{];
            say q[    use Carp qw[confess];];
            say q[    $client->http->session // confess 'creating a post requires an authenticated client';];

            #~ for my ( $pname, $pschema )( %{ $schema->{input}{schema}{properties} } ) {
            #~ say $pname . q[ => ] . q[] . $pname,;
            #~ }
            ddx $schema;
            say q[    $args{$_} // confess $_ . ' is a required parameter' for ] .
                join( ', ', map { "'" . $_ . "'" } @{ $schema->{input}{schema}{required} } ) . q[;]
                if defined $schema->{input} && defined $schema->{input}{schema}{required} && @{ $schema->{input}{schema}{required} };
            say q[    my $res = $client->http->] .
                ( $schema->{type} eq 'query' ? 'get' : 'post' ) .
                q[( sprintf( '%s/xrpc/%s', $client->host(), '] .
                $id . q[' )];
            ( defined $schema->{input}{schema} ? say q[      { content => \%args } ] : () );
            say q[    );];
            say q[    $res->{uri} = URI->new( $res->{uri} ) if defined $res->{uri};];
            say q[    $res;];
            say q[  }];

            #ddx $schema;
        }
        elsif ( $schema->{type} eq 'object' ) {

            #~ ddx $schema;
            say q[  class ] . $package . '::' . $method . '::' . $name . q[ {];
            for my ( $pname, $pschema )( %{ $schema->{properties} } ) {
                warn '# here';
                ddx $pschema;
                say sprintf q[    field $%s :param%s;], $pname, (
                    ( grep { $pname eq $_ } @{ $schema->{required} } ) ? '' : defined $pschema->{default} ? ' //= ' . $pschema->{default} : ' = ()' );
            }
            say '';
            say '    ADJUST { # TODO: handle types such as string maxlen, etc.';
            for my ( $pname, $pschema )( %{ $schema->{properties} } ) {
                $obj_adj->{ $pschema->{type} }->( $pname, $pschema );
            }

            #     visibility => { knownValues => ["show", "warn", "hide"], type => "string" },
            say '    }';
            say '';
            say '    # perlclass does not have :reader yet';
            for my ( $pname, $pschema )( %{ $schema->{properties} } ) {
                say q[    method ] . $pname . q[{ $] . $pname . q[ };];
            }
            say '    method _raw() {{';
            for my ( $pname, $pschema )( %{ $schema->{properties} } ) {
                if ( $pschema->{type} eq 'ref' ) {
                    say q[        ] . $pname . q[ => $] . $pname . q[->raw,];
                }
                elsif ( $pschema->{type} eq 'boolean' ) {
                    say q[        ] . $pname . q[ => !!$] . $pname . q[,];
                }
                elsif ( $pschema->{type} eq 'string' ) {
                    if ( $pschema->{format} // '' eq 'at-uri' ) {
                        say q[        ] . $pname . q[ => $] . $pname . q[->as_string,];
                    }
                    else {
                        say q[        ] . $pname . q[ => $] . $pname . q[,];
                    }
                }

                #~ elsif ( $pschema->{type} eq 'array' ) {
                #~ say q[        ] . $pname . q[ => !!$] . $pname . q[,];
                #~ }
                else {
                    say q[        ] . $pname . q[ => $] . $pname . q[,];
                    ddx $pschema;
                }
            }
            say q[    }}];
            say q[  }];
        }
        elsif ( $schema->{type} eq 'record' ) {

            #~ ddx $schema;
            say q[  class ] . $package . '::' . $method . q[ {];
            for my ( $pname, $pschema )( %{ $schema->{record}{properties} } ) {
                warn '# here';
                say q[    field $] . $pname . q[ :param] . ( ( grep { $pname eq $_ } @{ $schema->{record}{required} } ) ? '' : ' = ()' ) . q[;];
            }
            say '';
            say '    ADJUST{} # TODO: handle types such as string maxlen, etc.';
            say '';
            say '    # perlclass does not have :reader yet';
            for my ( $pname, $pschema )( %{ $schema->{record}{properties} } ) {
                say q[    method ] . $pname . q[{ $] . $pname . q[ };];
            }
            say '    method _raw() {{';
            for my ( $pname, $pschema )( %{ $schema->{record}{properties} } ) {
                say q[        ] . $pname . q[ => $] . $pname . q[,];
            }
            say q[    }}];
        }
        else {
            ddx $schema;
        }
    }

    #~ say '}';
    return;
    $map{ $parsed->{id} } = {
        DESCRIPTION => $parsed->{description} // '',
        CLASS       => join( '::', 'At', 'Lexicon', split /\./, $parsed->{id} ),
        VERSION     => sprintf( '%d.%02d', $parsed->{lexicon}, $parsed->{revision} // 0 ),
    };
    for my ( $k, $v )( %{ $parsed->{defs} } ) {
        warn $v->{type};
        if ( $v->{type} eq 'object' ) {    # https://atproto.com/specs/lexicon#object
            $map{ $id . '#' . $k } = { CLASS => $map{ $parsed->{id} }{CLASS} . '::' . $k, fields => $v->{properties} };
        }
        elsif ( $v->{type} eq 'procedure' || $v->{type} eq 'query' ) {
            $map{_methods}{$id} = {
                errors      => $v->{errors}      // [],
                description => $v->{description} // '',
                params      => {
                    map {
                        my $param = $_;
                        $param => {
                            %{ $v->{input}{schema}{properties}{$param} },
                            required => !!( grep { $_ eq $param } @{ $v->{input}{schema}{required} } )
                        }
                    } keys %{ $v->{input}{schema}{properties} }
                },
                return => {
                    map {
                        my $param = $_;
                        $param => {
                            %{ $v->{output}{schema}{properties}{$param} },
                            required => !!( grep { $_ eq $param } @{ $v->{input}{schema}{required} } )
                        }
                    } keys %{ $v->{output}{schema}{properties} }
                }
            };
        }
        elsif ( $v->{type} eq 'subscription' ) {
            warn $k;
            ddx $v;
            ...;
        }
        elsif ( $v->{type} eq 'record' ) {
            warn $k;
            ddx $v;
            ...;
        }
        elsif ( $v->{type} eq 'query' ) {

            #~ $map{$id}{methods}{$k} = $v;
            warn $k;
            ddx $v;

            #~ ...;
        }
        else {
            warn 'TODO: ' . $k;
            ddx $v;
        }
    }
    #
    return;
    ...;
    ddx $parsed->{defs};
    if ( $parsed->{type} eq 'query' ) {

        #~ warn $parsed->{}{};
    }
    elsif ( $parsed->{type} eq 'object' ) { }
    else {
        for my ( $name, $schema )( %{ $parsed->{defs} } ) {
            ddx $schema;
            die if defined $schema->{output};
            for my ( $property, $_schema )( %{ $schema->{properties} } ) {
                warn $property;
                ddx $_schema;
                if ( $_schema->{type} eq 'ref' ) {
                    $_schema->{_pointer} = \$map{ ( $_schema->{ref} =~ /^#/ ? $parsed->{id} : '' ) . $_schema->{ref} };
                }
            }
            $map{ $parsed->{id} . ( $name eq 'main' ? '' : '#' . $name ) } = $schema;
        }
    }
    return $map{$id};
}
-d 'atproto' ? `cd atproto; git fetch; git reset --hard HEAD; git merge '\@{u}'` :
    `git clone -v --depth 1 https://github.com/bluesky-social/atproto.git`;
my @files;
find(
    sub {
        if ( -f $_ and /\.json$/ ) {
            push @files, $File::Find::name;
        }
    },
    rel2abs 'atproto/lexicons'
);
say q[
package At 0.02 {
    use v5.38;
    no warnings 'experimental::class', 'experimental::builtin';    # Be quiet.
    use feature 'class';
    use DateTime::Tiny;
    #
    class At 1.00 {
        field $http //= Mojo::UserAgent->can('start') ? At::UserAgent::Mojo->new() :
            At::UserAgent::Tiny->new();
        method http {$http}
        #
        field $host : param = ();
        #
        field $repo : param = ();

        method repo {
            @_ ? At::Lexicon::AtProto::Repo->new( client => $self, @_ ) : $repo;
        }
        method _repo { $repo = shift; }
        field $server : param = ();

        method server {
            $server //= At::Lexicon::AtProto::Server->new( client => $self, host => $host );
            $server;
        }
        field $admin : param = ();

        method admin {
            $admin //= At::Lexicon::AtProto::Admin->new( client => $self, host => $host );
            $admin;
        }
        #
        method host {
            return $host if defined $host;
            use Carp qw[confess];
            confess 'You must provide a host or perhaps you wanted At::Bluesky';
        }
        ## Internals
        sub _timestamp {
            my @t = gmtime time;    # standardize around Zulu
            DateTime::Tiny->new(
                year   => $t[5] + 1900,
                month  => $t[4] + 1,
                day    => $t[3],
                hour   => $t[2],
                minute => $t[1],
                second => $t[0]
            );
        }

        sub _now {
            _timestamp()->as_string . 'Z';
        }
        ADJUST {
            require At::Lexicons::app::bsky::feed::post;
            require At::Lexicons::app::bsky::richtext::facet;
            #
            my $host = $self->host;
            $host = 'https://' . $host unless $host =~ /^https?:/;
            $host = URI->new($host)    unless builtin::blessed $host;
        }
    }

    class At::Lexicon::AtProto::Server {
        field $client : param;
        field $host : param;

        # https://github.com/bluesky-social/atproto/blob/main/lexicons/com/atproto/
        method createSession (%args) {
            my $session
                = $client->http->post(
                sprintf( '%s/xrpc/%s', $client->host, 'com.atproto.server.createSession' ),
                { content => \%args } );
            $client->http->session($session);
            $client->_repo(
                At::Lexicon::AtProto::Repo->new(
                    client => $client,
                    did    => $client->http->session->did->raw
                )
            );
            $session;
        }

        method describeServer {
            $client->http->get(
                sprintf( '%s/xrpc/%s', $client->host, 'com.atproto.server.describeServer' ) );
        }
    }

    class At::Lexicon::AtProto::Repo {
        field $client : param;
        field $did : param;
        method did {$did}
        ADJUST {
            $did = At::Protocol::DID->new( uri => $did ) unless builtin::blessed $did
        }

        method createRecord (%args) {    # https://atproto.com/blog/create-post
            use Carp qw[confess];
            $client->http->session // confess 'creating a post requires an authenticated client';
            my $res
                = $client->http->post(
                sprintf( '%s/xrpc/%s', $client->host(), 'com.atproto.repo.createRecord' ),
                { content => { repo => $did->raw, %args } } );
            $res->{uri} = URI->new( $res->{uri} ) if defined $res->{uri};
            $res;
        }
    }

    class At::Lexicon::AtProto::Admin {
        field $client : param;
        field $did : param;
        method did {$did}
        ADJUST {
            $did = At::Protocol::DID->new( uri => $did ) unless builtin::blessed $did
        }

        method disableAccountInvites (%args) {
            use Carp qw[confess];
            $client->http->session // confess 'creating a post requires an authenticated client';
            my $res = $client->http->post(
                sprintf( '%s/xrpc/%s', $client->host(), 'com.atproto.admin.disableAccountInvites' ),
                { content => \%args }
            );
            $res;
        }

        method disableInviteCodes (%args) {
            use Carp qw[confess];
            $client->http->session // confess 'creating a post requires an authenticated client';
            my $res
                = $client->http->post(
                sprintf( '%s/xrpc/%s', $client->host(), 'com.atproto.admin.disableInviteCodes' ),
                { content => \%args } );
            $res;
        }
    }


































    class At::Protocol::DID {    # https://atproto.com/specs/did
        field $uri : param;
        ADJUST {
            use Carp qw[carp croak];
            croak 'malformed DID URI: ' . $uri
                unless $uri =~ /^did:([a-z]+:[a-zA-Z0-9._:%-]*[a-zA-Z0-9._-])$/;
            use URI;
            $uri = URI->new($1) unless builtin::blessed $uri;
            my $scheme = $uri->scheme;
            carp 'unsupported method: ' . $scheme if $scheme ne 'plc' && $scheme ne 'web';
        };

        method raw {
            'did:' . $uri->as_string;
        }
    }

    class At::Protocol::Session {
        field $accessJwt : param;
        field $did : param;
        field $didDoc : param
            = ();    # spec says 'unknown' so I'm just gonna ignore it for now even with the dump
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
        method session ( $s = () ) { ...; }

        method get ( $url, $req = () ) {
            ...;
        }

        method post ( $url, $req = () ) {
            ...;
        }
    }

    class At::UserAgent::Tiny : isa(At::UserAgent) {

        # TODO: Error handling
        use HTTP::Tiny;
        use JSON::Tiny qw[decode_json encode_json];
        field $agent : param = HTTP::Tiny->new(
            agent           => sprintf( 'At.pm/%1.2f;Tiny ', $At::VERSION ),
            default_headers =>
                { 'Content-Type' => 'application/json', Accept => 'application/json' }
        );
        field $session : param = ();

        method session ( $s = () ) {
            $s // return $session;
            $session = At::Protocol::Session->new(%$s);
            $agent->{default_headers}{Authorization} = 'Bearer ' . $s->{accessJwt};
        }

        method get ( $url, $req = () ) {
            my $res = $agent->get( $url,
                defined $req->{content} ? { content => encode_json $req->{content} } : () );
            $res->{content} = decode_json $res->{content} if defined $res->{content};
            return $res->{content};
        }

        method post ( $url, $req = () ) {
            my $res = $agent->post( $url,
                defined $req->{content} ? { content => encode_json $req->{content} } : () );
            $res->{content} = decode_json $res->{content} if defined $res->{content};
            return $res->{content};
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
        field $session : param = ();

        method session ( $s = () ) {
            $s // return $session;
            $session = At::Protocol::Session->new(%$s);
        }

        method get ( $url, $req = () ) {
            my $res = $agent->get(
                $url,
                defined $session        ? { Authorization => 'Bearer ' . $session->accessJwt } : (),
                defined $req->{content} ? ( json => $req->{content} )                          : ()
            )->result;

            # todo: error handling
            if    ( $res->is_success )  { return $res->json }
            elsif ( $res->is_error )    { say $res->message }
            elsif ( $res->code == 301 ) { say $res->headers->location }
            else                        { say 'Whatever...' }
        }

        method post ( $url, $req = () ) {
            my $res = $agent->post(
                $url,
                defined $session        ? { Authorization => 'Bearer ' . $session->accessJwt } : (),
                defined $req->{content} ? ( json => $req->{content} )                          : ()
            )->result;

            # todo: error handling
            if    ( $res->is_success )  { return $res->json }
            elsif ( $res->is_error )    { say $res->message }
            elsif ( $res->code == 301 ) { say $res->headers->location }
            else                        { say 'Whatever...' }
        }
    }
];
ddx sort @files;
get $_ for sort @files;
say '}
__END__';
die;
get 'com.atproto.admin.disableAccountInvites';
get 'com.atproto.admin.defs';
get 'com.atproto.server.describeServer';
get 'com.atproto.server.createSession';
get 'com.atproto.server.refreshSession';
#
get 'app.bsky.actor.defs';
get 'app.bsky.actor.getPreferences';
get 'app.bsky.actor.getProfile';
get 'app.bsky.actor.getProfiles';
get 'app.bsky.actor.getSuggestions';
get 'app.bsky.actor.profile';
get 'app.bsky.actor.putPreferences';
get 'app.bsky.actor.searchActors';
get 'app.bsky.actor.searchActorsTypeahead';
#
get 'app.bsky.feed.describeFeedGenerator';
get 'app.bsky.feed.generator';
get 'app.bsky.feed.getActorFeeds';
get 'app.bsky.feed.getActorLikes';
get 'app.bsky.feed.getAuthorFeed';
get 'app.bsky.feed.getFeed';
get 'app.bsky.feed.getFeedGenerator';
get 'app.bsky.feed.getFeedGenerators';
get 'app.bsky.feed.getFeedSkeleton';
get 'app.bsky.feed.getLikes';
get 'app.bsky.feed.getListFeed';
get 'app.bsky.feed.getPostThread';
get 'app.bsky.feed.getPosts';
get 'app.bsky.feed.getRepostedBy';
get 'app.bsky.feed.getSuggestedFeeds';
get 'app.bsky.feed.getTimeline';
get 'app.bsky.feed.like';
get 'app.bsky.feed.post';
get 'app.bsky.feed.repost';
get 'app.bsky.feed.searchPosts';
get 'app.bsky.feed.threadgate';

#~ get 'app.bsky.richtext.facet';
ddx \%map;
__END__
use strict;
use warnings;
use feature 'say';
use Time::HiRes 'time';
if ( !@ARGV ) {
    say $^V;
    for my $size ( 5e5, 1e6, 5e6 ) {
        say "Array size: $size";
        for my $method ( 0, 1, 2 ) {
            for my $heat ( 0, 1 ) {
                system $^X, $0, $method, $heat, $size;
            }
        }
    }
}
else {
    my ( $method, $preheat, $size ) = @ARGV;
    my $s = join ' ', 0 .. 9;
    $s .= "\n";
    $s x= $size;
    chomp $s;
    my $t = time;
    if ($preheat) {
        my @garbage = (undef) x $size;
    }
    my @a;
    if ( $method == 0 ) {    # split
        @a = split /(?<=\n)/, $s;
    }
    elsif ( $method == 1 ) {    # global match
        @a = $s =~ /(.*?\n|.+)/gs;
    }
    elsif ( $method == 2 ) {    # IO (list context)
        open my $fh, '>', 'garbage.tmp';
        binmode $fh;
        print $fh $s;
        close $fh;
        open $fh, '<', 'garbage.tmp';
        binmode $fh;
        @a = <$fh>;
        close $fh;
    }
    printf "\t%s, %s:\t%.3f\n", (<split match io(list)>)[$method], ( $preheat ? 'pre-heat' : 'no pre-heat' ), time - $t;
}
