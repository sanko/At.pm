package At::Lexicon::com::atproto::repo 0.02 {
    use v5.38;
    no warnings 'experimental::class', 'experimental::builtin';    # Be quiet.
    use feature 'class';
    use URI;
    #
    class At::Lexicon::com::atproto::repo::strongRef 1 {
        field $type : param($type) //= ();    # record field
        field $uri : param;                   # at-uri
        field $cid : param;                   # cid
        ADJUST {
            $uri = URI->new($uri) unless builtin::blessed $uri;
        }
        method uri {$uri}
        method cid {$cid}

        method _raw {
            +{ defined $type ? ( '$type' => $type ) : (), uri => $uri->as_string, cid => $cid };
        }
    };
}
1;
__END__

=encoding utf-8

=head1 NAME

At::Lexicon::com::atproto::repo - Repository Related Classes

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
