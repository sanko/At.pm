use v5.42;
use lib '../lib', 'lib';
use At;
use Mojo::IOLoop;

# This demo uses the default Mojo::UserAgent (if installed)
my $at = At->new();
say 'At.pm Mojo Firehose Demo';
say "Listening for live commits on the AT Protocol network...";
my $fh = $at->firehose(
    sub ( $header, $body, $err ) {
        if ($err) {
            warn "Firehose Error: $err\n";
            return;
        }

        # Extract commit info
        if ( $header->{t} eq '#commit' ) {
            my $repo = $body->{repo};
            my $ops  = $body->{ops} // [];
            for my $op (@$ops) {
                printf "[%-15s] Repo: %s | Path: %s\n", $op->{action}, $repo, $op->{path};
            }
        }
    }
);
$fh->start();

# Start the Mojo event loop
Mojo::IOLoop->start unless Mojo::IOLoop->is_running;
