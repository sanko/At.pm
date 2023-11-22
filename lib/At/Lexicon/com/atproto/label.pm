package At::Lexicon::com::atproto::label 0.02 {
    use v5.38;
    no warnings 'experimental::class', 'experimental::builtin';    # Be quiet.
    use feature 'class';

    class At::Lexicon::com::atproto::label {
        field $uri : param;
        field $cid : param = ();
        field $cts : param;
        field $neg : param = ();
        field $val : param;
        field $src : param;
        ADJUST {
            use Carp;
            $uri = URI->new($uri) unless builtin::blessed $uri;
            $cts = At::Protocol::Timestamp->new( timestamp => $cts ) if defined $cts && !builtin::blessed $cts;
            Carp::cluck q[val is too long; expected 128 bytes or fewer] if length $val > 128;
            $src = At::Protocol::DID->new( uri => $src ) unless builtin::blessed $src;
        }

        # perlclass does not have :reader yet
        method uri {$uri}
        method cid {$cid}
        method cts {$cts}
        method neg {$neg}
        method val {$val}
        method src {$src}

        method _raw() {
            {   uri => $uri->as_string,
                ( defined $cid ? ( cid => $cid->_raw ) : () ),
                cts => $cts->_raw,
                ( defined $neg ? ( neg => !!$neg ) : () ),
                val => $val,
                src => $src->_raw
            }
        }
    }

    class At::Lexicon::com::atproto::label::selfLabel {

        # The short string name of the value or type of this label.
        field $val : param;    # string, required
        ADJUST {
            Carp::cluck q[val is too long; expected 128 bytes or fewer] if length $val > 128;
        }

        # perlclass does not have :reader yet
        method val {$val}

        method _raw() {
            { val => $val }
        }
    }

    # Metadata tags on an atproto record, published by the author within the record.
    class At::Lexicon::com::atproto::label::selfLabels {
        field $values : param;    # array
        ADJUST {
            use Carp qw[croak];
            $values = [ map { $_ = At::Lexicon::com::atproto::label::selfLabel->new( val => $_ ) unless builtin::blessed $_ } @$values ];
            croak 'too many labels; max 10' if scalar @$values > 10;
        }

        # perlclass does not have :reader yet
        method values {$values}

        method _raw() {
            { values => [ map { $_->_raw } @$values ] }
        }
    }
};
1;
__END__

=encoding utf-8

=head1 NAME

At::Lexicon::com::atproto::label - Metadata tag on an atproto resource (eg, repo or record).

=head1 Properties

=over

=item C<cid> - optional

CID specifying the specific version of 'uri' resource this label applies to.

=item C<cts> - required

Timestamp when this label was created.

=item C<neg> - optional

If true, this is a negation label, overwriting a previous label.

=item C<src> - required

DID of the actor who created this label.

=item C<uri> - required

AT URI of the record, repository (account), or other resource that this label applies to.

=item C<val> - required

The short string name of the value or type of this label.

=back

=head1 See Also

https://atproto.com/

https://en.wikipedia.org/wiki/Bluesky_(social_network)

=head1 LICENSE

Copyright (C) Sanko Robinson.

This library is free software; you can redistribute it and/or modify it under the terms found in the Artistic License
2. Other copyrights, terms, and conditions may apply to data transmitted through this module.

=head1 AUTHOR

Sanko Robinson E<lt>sanko@cpan.orgE<gt>

=for stopwords atproto eg

=cut
