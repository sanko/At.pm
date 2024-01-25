package Bluesky 0.11 {
    use v5.38;
    no warnings 'experimental::class', 'experimental::builtin';    # Be quiet.
    use feature 'class';
    use At::Bluesky;
    use Carp;

    class Bluesky : isa(At::Bluesky) {

        method block ($actor) {
            my $profile = $self->actor_getProfile($actor);
            builtin::blessed $profile or return;
            $self->repo_createRecord(
                repo       => $self->session->{did},
                collection => 'app.bsky.graph.block',
                record     => At::Lexicon::app::bsky::graph::block->new( createdAt => time, subject => $profile->did )
            ) ? $self->actor_getProfile($actor) : ();
        }

        method unblock ($actor) {
            my $profile = $self->actor_getProfile($actor);
            builtin::blessed $profile or return;
            return unless $profile->viewer->blocking;
            my ($rkey) = $profile->viewer->blocking =~ m[app.bsky.graph.block/(.*)$];
            $self->repo_deleteRecord( repo => $self->session->{did}, collection => 'app.bsky.graph.block', rkey => $rkey ) ?
                $self->actor_getProfile($actor) :
                ();
        }

        method post (%args) {
            $args{createdAt} //= At::_now();
            my $repo = delete $args{repo} // $self->session->{did};
            Carp::confess 'text must be fewer than 300 characters' if length $args{text} > 300 || bytes::length $args{text} > 300;
            my $record = At::Lexicon::app::bsky::feed::post->new( '$type' => 'app.bsky.feed.post', %args );
            $self->repo_createRecord( repo => $repo, collection => 'app.bsky.feed.post', record => $record );
        }

        method delete ( $rkey, $repo //= () ) {
            $rkey = $1 if $rkey =~ m[app.bsky.feed.post/(.*)$];
            $self->repo_deleteRecord( repo => $repo // $self->session->{did}, collection => 'app.bsky.feed.post', rkey => $rkey );
        }
    }
}
1;
__END__
=encoding utf-8

=head1 NAME

Bluesky - Extra Sweet Bluesky Client Library in Perl

=head1 SYNOPSIS

    use Bluesky;
    my $bsky = Bluesky->new( identifier => 'sanko', password => '1111-2222-3333-4444');
    $bsky->block( 'sankor.bsky.social' );
    $bsky->unblock( 'sankor.bsky.social' );
    # To be continued...

=head1 DESCRIPTION

You shouldn't need to know the AT protocol in order to get things done so I'm including this sugary wrapper so that
L<At> and L<At::Bluesky> can remain mostly technical.

=head1 Methods

As a subclass of At::Bluesky, see that module for inherited methods. If you'd like to use those inherited methods
directly, go ahead.

=head2 C<new( ... )>

    Bluesky->new( identifier => 'sanko', password => '1111-2222-3333-4444' );

Expected parameters include:

=over

=item C<identifier> - required

Handle or other identifier supported by the server for the authenticating user.

=item C<password> - required

This is the app password not the account's password. App passwords are generated at
L<https://bsky.app/settings/app-passwords>.

=back

=head2 C<block( ... )>

    $bsky->block( 'sankor.bsky.social' );

Blocks a user.

Expected parameters include:

=over

=item C<identifier> - required

Handle or DID of the person you'd like to block.

=back

Returns a true value on success.

=head2 C<unblock( ... )>

    $bsky->unblock( 'sankor.bsky.social' );

Unblocks a user.

Expected parameters include:

=over

=item C<identifier> - required

Handle or DID of the person you'd like to block.

=back

Returns a true value on success.

=head2 C<post( ... )>

    $bsky->post( text => 'Hello, world!' );

Create a new post.

Expected parameters include:

=over

=item C<text> - required

Text content of the post. Must be 300 characters or fewer.

=back

Note: This method will grow to support more features in the future.

Returns the CID and AT-URI values on success.

=head2 C<delete( ... )>

    $bsky->delete( 'at://...' );

Delete a post.

Expected parameters include:

=over

=item C<url> - required

The AT-URI of the post.

=back

Returns a true value on success.

=head1 LICENSE

Copyright (C) Sanko Robinson.

This library is free software; you can redistribute it and/or modify it under the terms found in the Artistic License
2. Other copyrights, terms, and conditions may apply to data transmitted through this module.

=head1 AUTHOR

Sanko Robinson E<lt>sanko@cpan.orgE<gt>

=begin stopwords

Bluesky

=end stopwords

=cut
