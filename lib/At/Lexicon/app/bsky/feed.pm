package At::Lexicon::app::bsky::feed 0.02 {
    use v5.38;
    no warnings 'experimental::class', 'experimental::builtin';    # Be quiet.
    use feature 'class';
    use bytes;
    our @CARP_NOT;
    use At::Lexicon::app::bsky::richtext;
    #
    # app.bsky.feed.post at trash.pl line 204.
    # trash.pl:205: {
    #   description => "A declaration of a post.",
    #   key => "tid",
    #   record => {
    #     properties => {
    #       createdAt => { format => "datetime", type => "string" },
    #       embed     => {
    #                      refs => [
    #                                "app.bsky.embed.images",
    #                                "app.bsky.embed.external",
    #                                "app.bsky.embed.record",
    #                                "app.bsky.embed.recordWithMedia",
    #                              ],
    #                      type => "union",
    #                    },
    #       entities  => {
    #                      description => "Deprecated: replaced by app.bsky.richtext.facet.",
    #                      items => { ref => "#entity", type => "ref" },
    #                      type => "array",
    #                    },
    #       facets    => {
    #                      items => { ref => "app.bsky.richtext.facet", type => "ref" },
    #                      type  => "array",
    #                    },
    #       labels    => { refs => ["com.atproto.label.defs#selfLabels"], type => "union" },
    #       langs     => {
    #                      items => { format => "language", type => "string" },
    #                      maxLength => 3,
    #                      type => "array",
    #                    },
    #       reply     => { ref => "#replyRef", type => "ref" },
    #       tags      => {
    #                      description => "Additional non-inline tags describing this post.",
    #                      items => { maxGraphemes => 64, maxLength => 640, type => "string" },
    #                      maxLength => 8,
    #                      type => "array",
    #                    },
    #       text      => { maxGraphemes => 300, maxLength => 3000, type => "string" },
    #     },
    #     required => ["text", "createdAt"],
    #     type => "object",
    #   },
    #   type => "record",
    # }
    class At::Lexicon::app::bsky::feed::post {
        field $createdAt : param;      # timestamp, required
        field $embed : param  = ();    # union
        field $facets : param = ();    # array of app.bsky.richtext.facet
        field $labels : param = ();    # com.atproto.label.defs#selfLabels
        field $langs : param  = ();    # array of strings, 3 elements max
        field $reply : param  = ();    # #replyRef
        field $tags : param   = ();    # array of strings
        field $text : param;           # string, required, max 300 graphemes, max length 3000
        ADJUST {
            use Carp;
            use experimental 'try';
            $createdAt = At::Protocol::Timestamp->new( timestamp => $createdAt ) unless builtin::blessed $createdAt;
            $embed     = [
                map {
                    return $_ if builtin::blessed $_;
                    if ( defined $_->{'$type'} ) {
                        my $type = delete $_->{'$type'};
                        return $_ = At::Lexicon::app::bsky::embed::images->new(%$_)          if $type eq 'app.bsky.embed.images';
                        return $_ = At::Lexicon::app::bsky::embed::external->new(%$_)        if $type eq 'app.bsky.embed.external';
                        return $_ = At::Lexicon::app::bsky::embed::record->new(%$_)          if $type eq 'app.bsky.embed.record';
                        return $_ = At::Lexicon::app::bsky::embed::recordWithMedia->new(%$_) if $type eq 'app.bsky.embed.recordWithMedia';
                    }
                    try {
                        $_ = At::Lexicon::app::bsky::embed::images->new(%$_);
                    }
                    catch ($e) {
                        try {
                            $_ = At::Lexicon::app::bsky::embed::external->new(%$_);
                        }
                        catch ($e) {
                            try {
                                $_ = At::Lexicon::app::bsky::embed::record->new(%$_);
                            }
                            catch ($e) {
                                try {
                                    $_ = At::Lexicon::app::bsky::embed::recordWithMedia->new(%$_);
                                }
                                catch ($e) {
                                    Carp::croak 'malformed embed: ' . $e;
                                }
                            }
                        }
                    }
                } @$embed
                ]
                if defined $embed;
            $facets = [ map { $_ = At::Lexicon::app::bsky::richtext::facet->new(%$_)      unless builtin::blessed $_ } @$facets ] if defined $facets;
            $labels = [ map { $_ = At::Lexicon::app::atproto::label::selfLabels->new(%$_) unless builtin::blessed $_ } @$labels ] if defined $labels;
            Carp::cluck q[too many languages; 3 max] if defined $langs && scalar @$langs > 3;
            $reply = At::Lexicon::app::bsky::feed::post::replyRef->new(%$reply) if defined $reply && !builtin::blessed $reply;
            if ( defined $tags ) {
                Carp::cluck q[too many tags; expected 8 max]               if grep { length $_ > 640 } @$tags;
                Carp::cluck q[tag is too long; expected 64 characters max] if grep { length $_ > 640 } @$tags;
                Carp::cluck q[tag is too long; expected 640 bytes max]     if grep { bytes::length $_ > 640 } @$tags;
            }
            Carp::cluck q[text is too long; expected 3000 bytes or fewer]     if bytes::length $text> 3000;
            Carp::cluck q[text is too long; expected 300 characters or fewer] if length $text > 300;
        }

        # perlclass does not have :reader yet
        method createdAt {$createdAt}
        method embed     {$embed}
        method facets    {$facets}
        method labels    {$labels}
        method langs     {$langs}
        method reply     {$reply}
        method tags      {$tags}
        method text      {$text}

        method _raw() {
            {   '$type'   => 'app.bsky.feed.post',
                createdAt => $createdAt->_raw,
                defined $embed  ? ( embed  => $embed ) : (), defined $facets                       ? ( facets => [ map { $_->_raw } @$facets ] ) : (),
                defined $labels ? ( labels => [ map { $_->_raw } @$labels ] ) : (), defined $langs ? ( langs => $langs )                         : (),
                defined $reply  ? ( reply  => $reply->_raw )                  : (), defined $tags  ? ( tags  => $tags ) : (), text => $text
            }
        }
    }

    class At::Lexicon::app::bsky::feed::post::replyRef {
        field $parent : param;    # strongRef, required
        field $root : param;      # strongRef, required
        ADJUST {
            $parent = At::Lexicon::com::atproto::repo::strongRef->new(%$parent) unless builtin::blessed $parent;
            $root   = At::Lexicon::com::atproto::repo::strongRef->new(%$root)   unless builtin::blessed $root;
        }

        # perlclass does not have :reader yet
        method parent {$parent}
        method root   {$root}

        method _raw() {
            { parent => $parent->_raw, root => $root->_raw }
        }
    }
};
1;
__END__

=encoding utf-8

=head1 NAME

At::Lexicon::app::bsky::feed - Post Declarations

=head1 See Also

https://atproto.com/

https://en.wikipedia.org/wiki/Bluesky_(social_network)

=head1 LICENSE

Copyright (C) Sanko Robinson.

This library is free software; you can redistribute it and/or modify it under the terms found in the Artistic License
2. Other copyrights, terms, and conditions may apply to data transmitted through this module.

=head1 AUTHOR

Sanko Robinson E<lt>sanko@cpan.orgE<gt>

=cut
