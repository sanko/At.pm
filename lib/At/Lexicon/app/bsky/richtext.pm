package At::Lexicon::app::bsky::richtext 0.02 {
    use v5.38;
    no warnings 'experimental::class', 'experimental::builtin';    # Be quiet.
    use feature 'class';
    use bytes;
    our @CARP_NOT;
    #
    class At::Lexicon::app::bsky::richtext::facet {
        use experimental 'try';
        field $features : param;    # array of union, required
        field $index : param;       # ::byteSlice, required
        ADJUST {
            $index    = At::Lexicon::app::bsky::richtext::facet::byteSlice->new(%$index) if defined $index && !builtin::blessed $index;
            $features = [
                map {
                    return $_ if builtin::blessed $_;
                    if ( defined $_->{'$type'} ) {
                        my $type = delete $_->{'$type'};
                        return $_ = At::Lexicon::app::bsky::richtext::facet::mention->new(%$_) if $type eq 'app.bsky.richtext.facet#mention';
                        return $_ = At::Lexicon::app::bsky::richtext::facet::link->new(%$_)    if $type eq 'app.bsky.richtext.facet#link';
                        return $_ = At::Lexicon::app::bsky::richtext::facet::tag->new(%$_)     if $type eq 'app.bsky.richtext.facet#tag';
                    }
                    try {
                        $_ = At::Lexicon::app::bsky::richtext::facet::mention->new(%$_);
                    }
                    catch ($e) {
                        try {
                            $_ = At::Lexicon::app::bsky::richtext::facet::link->new(%$_);
                        }
                        catch ($e) {
                            try {
                                $_ = At::Lexicon::app::bsky::richtext::facet::tag->new(%$_);
                            }
                            catch ($e) {
                                Carp::croak 'malformed feature: ' . $e;
                            }
                        }
                    }
                } @$features
            ];
        }

        # perlclass does not have :reader yet
        method features {$features}
        method index    {$index}

        method _raw() {
            { features => [ map { $_->_raw } @$features ], index => $index->_raw }
        }
    }

    # A facet feature for actor mentions.
    class At::Lexicon::app::bsky::richtext::facet::mention {
        field $did : param;    # did, required
        ADJUST {
            $did = At::Protocol::DID->new( uri => $did ) unless builtin::blessed $did;
        }

        # perlclass does not have :reader yet
        method did {$did}

        method _raw() {
            { did => $did->as_string, '$type' => 'app.bsky.richtext.facet#mention' }
        }
    }

    # A facet feature for links.
    class At::Lexicon::app::bsky::richtext::facet::link {
        field $uri : param;    # uri, required
        ADJUST {
            $uri = URI->new($uri) unless builtin::blessed $uri;
        }

        # perlclass does not have :reader yet
        method uri {$uri}

        method _raw() {
            { uri => $uri->as_string, '$type' => 'app.bsky.richtext.facet#link' }
        }
    }

    # A hashtag.
    class At::Lexicon::app::bsky::richtext::facet::tag {
        field $tag : param;    # string, required, max 640 graphemes, max 64 characters
        ADJUST {
            Carp::cluck q[tag is too long; expected 64 bytes or fewer]       if bytes::length $tag > 64;
            Carp::cluck q[tag is too long; expected 640 characters or fewer] if length $tag > 640;
        }

        # perlclass does not have :reader yet
        method tag {$tag}

        method _raw() {
            { tag => $tag, '$type' => 'app.bsky.richtext.facet#tag' }
        }
    }

    # A text segment. Start is inclusive, end is exclusive. Indices are for utf8-encoded strings.
    class At::Lexicon::app::bsky::richtext::facet::byteSlice {
        field $byteEnd : param;      # int, required, minimum: 0
        field $byteStart : param;    # int, required, minimum: 0
        ADJUST {
            use Carp;
            Carp::confess 'byteEnd must be greater than 0'   if $byteEnd < 0;
            Carp::confess 'byteStart must be greater than 0' if $byteStart < 0;
        }

        # perlclass does not have :reader yet
        method byteEnd   {$byteEnd}
        method byteStart {$byteStart}

        method _raw() {
            { byteEnd => $byteEnd, byteStart => $byteStart }
        }
    }
};
1;
__END__

=encoding utf-8

=head1 NAME

At::Lexicon::app::bsky::richtext - Richtext and Facet classes

=head1 See Also

https://atproto.com/

https://en.wikipedia.org/wiki/Bluesky_(social_network)

https://en.m.wikipedia.org/wiki/Social_graph

=head1 LICENSE

Copyright (C) Sanko Robinson.

This library is free software; you can redistribute it and/or modify it under the terms found in the Artistic License
2. Other copyrights, terms, and conditions may apply to data transmitted through this module.

=head1 AUTHOR

Sanko Robinson E<lt>sanko@cpan.orgE<gt>

=cut
