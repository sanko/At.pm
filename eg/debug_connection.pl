use v5.42;
use lib '../lib';
use At;
use Data::Dumper;
$|++;
#
my $at = At->new();
say 'Testing connection to bsky.social...';

# Simple fetch
my ( $res, $headers ) = $at->http->get('https://bsky.social/xrpc/com.atproto.server.describeServer');
if ( builtin::blessed($res) && $res->isa('At::Error') ) {
    say 'Basic fetch failed: $res';
    exit 1;
}
say 'Basic fetch OK: ' . $res->{did};

# Resolve Handle
say 'Resolving handle "atproto.bsky.social"...';
my $ident = $at->resolve_handle('atproto.bsky.social');
if ( builtin::blessed($ident) && $ident->isa('At::Error') ) {
    say 'Handle resolution failed: ' . $ident;
    exit 1;
}
say 'DID: ' . $ident->{did};

# Resolve DID
say 'Resolving DID ' . $ident->{did} . '...';
my $doc = $at->resolve_did( $ident->{did} );
unless ( $doc && ref $doc eq 'HASH' ) {
    say 'DID resolution failed (or returned empty).';
    say Dumper($doc);
    exit 1;
}
say 'DID Document retrieved.';

# PDS Discovery
my $pds = $at->pds_for_did( $ident->{did} );
unless ($pds) {
    say 'PDS discovery failed.';
    exit 1;
}
say 'PDS: ' . $pds;
say 'All connection tests passed.';

=head1 NAME

debug_connection.pl - Connection & Discovery Diagnostic Tool

=head1 SYNOPSIS

    perl eg/debug_connection.pl

=head1 DESCRIPTION

This utility script runs a series of tests to verify your environment's ability
to connect to an AT Protocol network. It checks:

=over

=item * Basic HTTP connectivity to bsky.social

=item * Handle resolution (DNS/HTTP)

=item * DID resolution

=item * PDS (Personal Data Server) discovery

=back

Use this if you are encountering connection or resolution errors.

=cut
