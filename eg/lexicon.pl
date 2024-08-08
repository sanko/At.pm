use Object::Pad;
use URI;
use JSON::Tiny;

package At::Protocol::JSON::Lines {    # application/jsonl
    use JSON::Tiny;
    sub decode { JSON::Tiny::decode_json( $_[0] ) }
    sub encode { JSON::Tiny::encode_json(@_) . "\n" }
}

package At {
    use 5.040;

    sub _glength ($str)
    { # https://www.perl.com/pub/2012/05/perlunicook-string-length-in-graphemes.html/
        my $count = 0;
        while ( $str =~ /\X/g ) { $count++ }
        return $count;
    }
}

class At::Protocol::DID {    # https://atproto.com/specs/did
    field $uri : param;
    ADJUST {
        use Carp qw[carp confess];
        confess 'malformed DID URI: ' . $uri
          unless $uri =~ /^did:([a-z]+:[a-zA-Z0-9._:%-]*[a-zA-Z0-9._-])$/;
        $uri = URI->new($1) unless builtin::blessed $uri;
        my $scheme = $uri->scheme;
        carp 'unsupported method: ' . $scheme
          if $scheme ne 'plc' && $scheme ne 'web';
    };

    method _raw {
        'did:' . $uri->as_string;
    }
}

class At::Protocol::Handle {    # https://atproto.com/specs/handle
    field $id : param;
    ADJUST {
        use Carp qw[confess carp];
        confess 'malformed handle: ' . $id
          unless $id =~
/^([a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?\.)+[a-zA-Z]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?$/;
        confess 'disallowed TLD in handle: ' . $id
          if $id =~ /\.(arpa|example|internal|invalid|local|localhost|onion)$/;
        CORE::state $warned //= 0;
        if ( $id =~ /\.(test)$/ && !$warned ) {
            carp 'development or testing TLD used in handle: ' . $id;
            $warned = 1;
        }
    };
    method _raw { $id; }
}

class At::Protocol::Timestamp {    # Internal; standardize around Zulu
    field $timestamp : param;
    ADJUST {
        use Time::Moment;
        if ( !builtin::blessed $timestamp ) {
            $timestamp =
              $timestamp =~ /\D/
              ? Time::Moment->from_string($timestamp)
              : Time::Moment->from_epoch($timestamp);
        }
    };

    method _raw {
        $timestamp->to_string;
    }
}

package At::Lexicon::Parser 1.0 {
    use 5.40.0;
    no warnings 'experimental::builtin';
    use builtin qw[is_bool nan];
    use Carp    qw[cluck carp croak];
    our @CARP_NOT;
    #
    use Object::Pad qw[:experimental(mop)];
    #
    $|++;
    #
    use Data::Printer;
    #
    sub type($type) {
    }

    sub lexicon($raw) {
        return unless $raw;
        my %lexicon;
        $lexicon{version} = delete $raw->{lexicon};
        $lexicon{name}    = $lexicon{package} = delete $raw->{id};
        $lexicon{package} =~ s[\.defs$][];
        $lexicon{package} =~ s[[#\.]+][::]gm;
        for my ( $key, $value )( %{ $raw->{defs} } ) {
            $key =~ s[[#\.]+][::]gm;
            $key = () if $key eq 'main';
            my $package = join '::', grep {defined} 'At::Lexicon' , $lexicon{package}, $key;

            # warn $package;
            my $metaclass =
              Object::Pad::MOP::Class->begin_class( $package, () );
            if ( $value->{type} eq 'object' ) {
                for my ( $prop_key, $prop_value )( %{ $value->{properties} } ) {

                    # warn '    ' . $prop_key;
                    use Data::Dump;

                    # warn np $prop_value;
                    my $metafield = $metaclass->add_field(
                        '$'
                          . $prop_key => (
                            defined $prop_value->{default}
                            ? ( default => $prop_value->{type} eq 'boolean'
                                ? !!$prop_value->{default}
                                : $prop_value->{default} )
                            : ( grep { $prop_key eq $_ }
                                  @{ $value->{required} // [] } )
                            ? ()
                            : ( default => undef ),
                            param    => $prop_key,
                            accessor => $prop_key
                          )
                    );
                    if ( $prop_value->{type} eq 'boolean' ) {
                        $metaclass->add_BUILD(
                            sub ( $self, %args ) {
                                $args{$prop_key} = !!$args{$prop_key}
                                  unless is_bool( $args{$prop_key} );
                            }
                        );
                    }
                    elsif ( $prop_value->{type} eq 'integer' ) {
                        $metaclass->add_BUILD(
                            sub ( $self, %args ) {
                                return if !defined $args{$prop_key};
                                Carp::confess(
                                    sprintf
q['%s' with value of %d is below the minimum value of %d],
                                    $prop_key, $args{$prop_key},
                                    $prop_value->{minimum} )
                                  if $args{$prop_key} < $prop_value->{minimum};
                            }
                        ) if defined $prop_value->{minimum};
                    }
                    elsif ( $prop_value->{type} eq 'string' ) {
                        $metaclass->add_BUILD(
                            sub ( $self, %args ) {
                                return if !defined $args{$prop_key};
                                my $len = At::_glength( $args{$prop_key} );
                                Carp::confess(
                                    sprintf
q['%s' is too long (%d vs %d max graphemes)],
                                    $prop_key,
                                    $len,
                                    $prop_value->{maxGraphemes}
                                ) if $len > $prop_value->{maxGraphemes};
                            }
                        ) if defined $prop_value->{maxGraphemes};
                        $metaclass->add_BUILD(
                            sub ( $self, %args ) {
                                return if !defined $args{$prop_key};
                                my $len = length( $args{$prop_key} );
                                Carp::confess(
                                    sprintf
q[%s' is too long (%d vs %d max characters)],
                                    $prop_key, $len, $prop_value->{maxLength} )
                                  if $len > $prop_value->{maxLength};
                            }
                        ) if defined $prop_value->{maxLength};
                        $metaclass->add_BUILD(
                            sub ( $self, %args ) {
                                if ( defined $prop_value->{knownValues}
                                    && !grep { $_ eq $args{$prop_key} }
                                    @{ $prop_value->{knownValues} } )
                                {
                                    state $list //= sub {
                                        my @list = map { "'$_'" } @_;
                                        return join ' or ', @list if @list <= 2;
                                        my $last = pop @list;
                                        return
                                          join( ', ', @list ) . " or $last";
                                    };
                                    croak sprintf q[Field '%s' should be %s],
                                      $prop_key,
                                      $list->(
                                        @{ $prop_value->{knownValues} } );
                                }
                                state $format //= {
                                    did => sub ($str) {
                                        At::Protocol::DID->new( uri => $str )
                                          if defined $str;
                                    },
                                    handle => sub ($str) {
                                        At::Protocol::Handle->new( id => $str )
                                          if defined $str;
                                    },
                                    datetime => sub ($str) {
                                        At::Protocol::Timestamp->new(
                                            timestamp => $str )
                                          if defined $str;
                                    },
                                    uri => sub ($str) {
                                        URI->new($str) if defined $str;
                                    }
                                };
                                if ( defined $prop_value->{format} ) {
                                    if (
                                        defined
                                        $format->{ $prop_value->{format} } )
                                    {
                                        $args{$prop_key} =
                                          $format->{ $prop_value->{format} }
                                          ->( $args{$prop_key} );
                                    }
                                    else {
                                        croak 'Unknown string format: '
                                          . $prop_value->{format};
                                    }
                                }

                                # warn 'wow';
                                # my $metafield =
                                #   $metaclass->get_field( '$' . $prop_key );
                                # warn '$' . $prop_key;
                                # use Data::Dump;
                                # ddx $metafield;
                                # # ddx $args{$prop_key};
                                # ddx \%args;
                            }
                        );
                    }
                    elsif ( $prop_value->{type} eq 'array' ) {

                        # warn np $prop_value;
                        $metaclass->add_BUILD(
                            sub ( $self, %args ) {
                                return if !defined $args{$prop_key};
                                croak $prop_key. ' should be an array'
                                  unless ref $args{$prop_key} eq 'ARRAY';
                            }
                        );
                        $metaclass->add_BUILD(
                            sub ( $self, %args ) {
                                return if !defined $args{$prop_key};
                                croak $prop_key
                                  . ' should be an array of '
                                  . $prop_value->{maxLength}
                                  . ' or fewer elements'
                                  if scalar @{ $args{$prop_key} } >
                                  $prop_value->{maxLength};
                            }
                        ) if defined $prop_value->{maxLength};
                        $metaclass->add_BUILD(
                            sub ( $self, %args ) {
                                return if !defined $args{$prop_key};
                                croak $prop_key
                                  . ' should be an array of '
                                  . $prop_value->{minLength}
                                  . ' or more elements'
                                  if scalar @{ $args{$prop_key} } <
                                  $prop_value->{minLength};
                            }
                        ) if defined $prop_value->{minLength};
                        if ( $prop_value->{items}{type} eq 'ref' ) {
                            my $ref = $prop_value->{items}{ref};
                            $ref =~ s[\.defs#][::]g;
                            $ref =~ s[^#][$lexicon{package}]eg;
                            $ref =~ s[\.][::]g;
                            $metaclass->add_BUILD(
                                sub ( $self, %args ) {
                                    return if !defined $args{$prop_key};
                                    $args{$prop_key} = [ map { $ref->new(%$_); }
                                          @{ $args{$prop_key} } ]

                                 # return if blessed $args{$prop_key};
                                 # $args{$prop_key} = ( 'At::Lexicon::' . $ref )
                                 #   ->new( %{ $args{$prop_key} } );
                                }
                            );
                        }
                        elsif ( $prop_value->{items}{type} eq 'cid-link' ) {
                            $metaclass->add_BUILD(
                                sub ( $self, %args ) {
                                    return if !defined $args{$prop_key};
                                    $args{$prop_key} = [
                                        map {
                                            require CBOR::Free;
                                            CBOR::Free::decode($_)
                                              unless blessed $_;
                                        } @{ $args{$prop_key} }
                                    ];
                                }
                            );
                        }
                        elsif ( $prop_value->{items}{type} eq 'ref' ) {
                            my $ref = $prop_value->{items}{ref};
                            $ref =~ s[\.defs#][::]g;
                            $ref =~ s[^#][$lexicon{package}]eg;
                            $ref =~ s[\.][::]g;
                            $metaclass->add_BUILD(
                                sub ( $self, %args ) {
                                    return if !defined $args{$prop_key};
                                    $args{$prop_key} = [
                                        map {
                                            blessed $_ ? $_ : $ref->new(%$_);
                                        } @{ $args{$prop_key} }
                                    ];
                                }
                            );
                        }
                        elsif ( $prop_value->{items}{type} eq 'string' ) {
                            if ( !defined $prop_value->{items}{format} )
                            {    # Don't do anything.
                                $metaclass->add_BUILD(
                                    sub ( $self, %args ) {
                                        return if !defined $args{$prop_key};
                                        Carp::confess(
                                            sprintf
q[element in array '%s' is too long (%d max graphemes)],
                                            $prop_key,
                                            $prop_value->{items}{maxGraphemes}
                                          )
                                          if grep {
                                            At::_glength($_) >
                                              $prop_value->{items}{maxGraphemes}
                                          } @{ $args{$prop_key} };
                                    }
                                  )
                                  if defined $prop_value->{items}{maxGraphemes};
                                $metaclass->add_BUILD(
                                    sub ( $self, %args ) {
                                        return if !defined $args{$prop_key};
                                        Carp::confess(
                                            sprintf
q[element in array '%s' is too long (%d max length)],
                                            $prop_key,
                                            $prop_value->{items}{maxLength}
                                          )
                                          if grep {
                                            length($_) >
                                              $prop_value->{items}{maxLength}
                                          } @{ $args{$prop_key} };
                                    }
                                ) if defined $prop_value->{items}{maxLength};
                            }
                            elsif ( $prop_value->{items}{format} eq 'cid' ) {
                                $metaclass->add_BUILD(
                                    sub ( $self, %args ) {
                                        require CBOR::Free;
                                        return if !defined $args{$prop_key};
                                        $args{$prop_key} = [
                                            map {
                                                blessed $_
                                                  ? $_
                                                  : CBOR::Free::decode(%$_);
                                            } @{ $args{$prop_key} }
                                        ];
                                    }
                                );
                            }
                            elsif ( $prop_value->{items}{format} eq 'at-uri' ) {
                                $metaclass->add_BUILD(
                                    sub ( $self, %args ) {
                                        require URI;
                                        return if !defined $args{$prop_key};
                                        $args{$prop_key} = [
                                            map {
                                                blessed $_ ? $_ : URI->new($_);
                                            } @{ $args{$prop_key} }
                                        ];
                                    }
                                );
                            }
                            else {
                                warn np $prop_value;

                                # Don't do anything.
                            }
                        }
                        elsif ( $prop_value->{items}{type} eq 'union' ) {
                            my @types;
                            for my $ref ( @{ $prop_value->{items}{refs} } ) {
                                $ref =~ s[\.defs#][::]g;
                                $ref =~ s[^#][$lexicon{package}]eg;
                                $ref =~ s[\.][::]g;
                                push @types, 'At::Lexicon::' . $ref;
                            }
                            $metaclass->add_BUILD(
                                sub ( $self, %args ) {
                                    return if !defined $args{$prop_key};
                                    $args{$prop_key} = [
                                        map {
                                            my $current = $_;
                                            for my $type (@types) {
                                                try {
                                                    $current =
                                                      $type->new(%$current);
                                                }
                                                catch ($e) { next; }
                                            }
                                            $current;
                                        } @{ $args{$prop_key} }
                                    ];
                                }
                            );
                        }
                        elsif ( $prop_value->{items}{type} eq 'unknown' ) {

                            # Don't do anything.
                        }
                        else {
                            carp np $prop_value;
                            die;
                        }
                    }
                    elsif ( $prop_value->{type} eq 'ref' ) {
                        my $ref = $prop_value->{ref};
                        $ref =~ s[\.defs#][::]g;
                        $ref =~ s[^#][$lexicon{package}]eg;
                        $ref =~ s[\.][::]g;
                        $metaclass->add_BUILD(
                            sub ( $self, %args ) {
                                return if !defined $args{$prop_key};
                                return if blessed $args{$prop_key};
                                $args{$prop_key} = ( 'At::Lexicon::' . $ref )
                                  ->new( %{ $args{$prop_key} } );
                            }
                        );
                    }
                    elsif ( $prop_value->{type} eq 'union' ) {
                        my @types;
                        for my $ref ( @{ $prop_value->{refs} } ) {
                            $ref =~ s[\.defs#][::]g;
                            $ref =~ s[^#][$lexicon{package}]eg;
                            $ref =~ s[\.][::]g;
                            push @types, 'At::Lexicon::' . $ref;
                        }
                        $metaclass->add_BUILD(
                            sub ( $self, %args ) {
                                return if !defined $args{$prop_key};
                                for my $type (@types) {
                                    try {
                                        $args{$prop_key} =
                                          $type->new( %{ $args{$prop_key} } )
                                          unless blessed $args{$prop_key};
                                    }
                                    catch ($e) { next; }
                                }
                            }
                        );
                    }
                    elsif ( $prop_value->{type} eq 'bytes' ) {
                        $metaclass->add_BUILD(
                            sub ( $self, %args ) {
                                return if !defined $args{$prop_key};
                                my $len = length( $args{$prop_key} );
                                Carp::confess(
                                    sprintf
                                      q[%s' is too long (%d vs %d max bytes)],
                                    $prop_key,
                                    $len,
                                    $prop_value->{maxLength}
                                ) if $len > $prop_value->{maxLength};
                            }
                        ) if defined $prop_value->{maxLength};

                        # die;
                    }
                    elsif ( $prop_value->{type} eq 'cid-link' ) {
                        $metaclass->add_BUILD(
                            sub ( $self, %args ) {
                                return if !defined $args{$prop_key};
                                require CBOR::Free;
                                $args{$prop_key} =
                                  CBOR::Free::decode( $args{$prop_key} );
                            }
                        );
                    }
                    elsif ( $prop_value->{type} eq 'unknown' ) {

                        # Don't do anything.
                    }
                    elsif ( $prop_value->{type} eq 'blob' ) {

                        # carp np $prop_value;
                        $metaclass->add_BUILD(
                            sub ( $self, %args ) {
                                return if !defined $args{$prop_key};
                                my $len = length( $args{$prop_key} );
                                Carp::confess(
                                    sprintf
                                      q[%s' is too large (%d vs %d max bytes)],
                                    $prop_key, $len, $prop_value->{maxSize} )
                                  if $len > $prop_value->{maxSize};
                            }
                        ) if defined $prop_value->{maxSize};

                        # croak 'TODO: ' . $prop_value->{type};
                    }
                    else {
                        carp np $prop_value;
                        croak 'Unhandled type: ' . $prop_value->{type};
                    }
                }
            }
            elsif ( $value->{type} eq 'query' ) {
                warn $package;
                warn np $value;
                # ...;
            }
            elsif ( $value->{type} eq 'procedure' ) {

                # warn np $value;
            }

            elsif ( $value->{type} eq 'record' ) {

                # warn np $value;
            }

            elsif ( $value->{type} eq 'string' ) {

                # warn np $value;
            }

            elsif ( $value->{type} eq 'subscription' ) {

                # warn np $value;
            }

            elsif ( $value->{type} eq 'token' ) {

                # warn np $value;
            }
            elsif ( $value->{type} eq 'array' ) {

                # warn np $value;
            }
            else {
                warn np $value;
                die 'Skipping '
                  . $key
                  . ' because it is of type '
                  . $value->{type};
            }
            $metaclass->seal;

            # p %$def;
            # ...;
        }
        \%lexicon;
    }
};
use 5.40.0;
use HTTP::Tiny;
use Data::Printer;
use JSON::Tiny qw[decode_json];
use Path::Tiny qw[path];
if (0) {
    my $response = HTTP::Tiny->new->get(
'https://github.com/bluesky-social/atproto/raw/main/lexicons/app/bsky/actor/defs.json'
    );
    die "Failed!\n" unless $response->{success};
    print "$response->{status} $response->{reason}\n";
    while ( my ( $k, $v ) = each %{ $response->{headers} } ) {
        for ( ref $v eq 'ARRAY' ? @$v : $v ) {
            print "$k: $_\n";
        }
    }
    At::Lexicon::Parser::lexicon( decode_json $response->{content} );
}
else {
    my $cache = path('share/atproto/lexicons')->realpath;
    my $iter  = $cache->iterator( { recurse => 1 } );
    while ( my $next = $iter->() ) {
        At::Lexicon::Parser::lexicon( decode_json $next->slurp_utf8 )
          if $next->is_file;
    }
}
use Data::Dump;
ddx At::Lexicon::app::bsky::actor::profileViewBasic->new(
    did    => 'did:plc:z72i7hdynmk6r22z27h6tvur',
    handle => 'jay.bsky.social'
);
exit;
ddx At::Lexicon::app::bsky::actor::adultContentPref->new( enabledd => 1 );
ddx At::Lexicon::app::bsky::actor::contentLabelPref->new(
    label      => 'todo',
    visibility => 'show'
);
warn 'exit';
__END__
        
