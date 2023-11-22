package At::Lexicon::com::atproto::repo::strongRef 0.02 {
    use v5.38;
    no warnings 'experimental::class', 'experimental::builtin';    # Be quiet.
    use feature 'class';
    use URI;
    #
    class At::Lexicon::com::atproto::repo::strongRef 1 {
        field $uri : param;    # at-uri
        field $cid : param;    # cid
        ADJUST {
            $uri = URI->new($uri) unless builtin::blessed $uri;
        }
    };
}
1;
__END__

=encoding utf-8

=head1 NAME

At::Lexicon::com::atproto::admin::strongRef - A URI with a content-hash fingerprint

=head1 See Also

L<https://atproto.com/>

L<https://github.com/bluesky-social/atproto/blob/main/lexicons/com/atproto/repo/strongRef.json>

=head1 LICENSE

Copyright (C) Sanko Robinson.

This library is free software; you can redistribute it and/or modify it under the terms found in the Artistic License
2. Other copyrights, terms, and conditions may apply to data transmitted through this module.

=head1 AUTHOR

Sanko Robinson E<lt>sanko@cpan.orgE<gt>

=cut
