use v5.42;
use lib '../lib', 'lib';
use At;
use Mojolicious::Lite;

use URI;
$|++;
# Configuration
my $handle = 'atperl.bsky.social';
my $scope  = 'atproto transition:generic';
my $port   = 8888;
my $redir  = "http://127.0.0.1:$port/callback";

# 1. Initialize client with Mojo UA
my $ua = At::UserAgent::Mojo->new;
my $at = At->new( http => $ua );

# 2. Build the magic localhost Client ID
my $client_id = URI->new('http://localhost');
$client_id->query_param( scope        => $scope );
$client_id->query_param( redirect_uri => $redir );

say 'At.pm OAuth Demo (Mojo)';
say "1. Starting OAuth flow for $handle...";

my $auth_url = $at->oauth_start( $handle, $client_id->as_string, $redir, $scope );

say "2. Please open this URL in your browser:";
say "\n   $auth_url\n";
say "3. Waiting for redirect to $redir ...";

# 3. Setup Mojo App to listen for the redirect
get '/callback' => sub ($c) {
    my $code = $c->param('code');
    my $state = $c->param('state');

    unless ($code && $state) {
        return $c->render(text => "Error: Missing code or state parameters.", status => 400);
    }

    say "4. Exchanging code for tokens...";

    eval {
        $at->oauth_callback( $code, $state );
    };
    if ($@) {
        $c->app->log->error("OAuth Callback failed: $@");
        return $c->render(text => "OAuth Callback failed: $@", status => 500);
    }

    say "   Authenticated as: " . $at->did;
    say "5. Fetching your profile...";

    my $profile;
    eval {
        $profile = $at->get( 'app.bsky.actor.getProfile', { actor => $at->did } );
    };
    if ($@) {
         $c->app->log->error("Failed to fetch profile: $@");
         return $c->render(text => "Authenticated, but failed to fetch profile: $@", status => 500);
    }

    say "   Display Name: " . $profile->{displayName};
    say "   Description:  " . ( $profile->{description} // '[no description]' );

    $c->render(text => "<h1>Success!</h1><p>You are authenticated as <b>" . $profile->{displayName} . "</b>.</p><p>You can close this window and check the console.</p>");

    # Gracefully stop the server
    Mojo::IOLoop->timer(1 => sub { exit 0 });
};

app->start('daemon', '-l', "http://127.0.0.1:$port");
