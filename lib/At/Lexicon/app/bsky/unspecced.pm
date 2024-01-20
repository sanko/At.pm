package At::Lexicon::app::bsky::unspecced 0.07 {
    use v5.38;
    no warnings 'experimental::class', 'experimental::builtin';    # Be quiet.
    use feature 'class';
    use bytes;
    our @CARP_NOT;
    #
    # from app.bsky.unspecced.defs
    class At::Lexicon::app::bsky::unspecced::skeletonSearchPost {
        field $uri : param;    # at-url, required
        ADJUST {
            $uri = URI->new($uri) unless builtin::blessed $uri;
        }

        # perlclass does not have :reader yet
        method uri {$uri}

        method _raw() {
            +{ uri => $uri->as_string };
        }
    }

    class At::Lexicon::app::bsky::unspecced::skeletonSearchActor {
        field $did : param;    # did, required
        ADJUST {
            $did = At::Protocol::DID->new( uri => $did ) unless builtin::blessed $did;
        }

        # perlclass does not have :reader yet
        method did {$did}

        method _raw() {
            +{ uri => $did->_raw };
        }
    }
};
1;
__END__

=encoding utf-8

=head1 NAME

At::Lexicon::app::bsky::unspecced - Unsorted

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
