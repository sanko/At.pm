# NAME

At - The AT Protocol for Social Networking (Bluesky)

# SYNOPSIS

```perl
use At;
my $at = At->new( host => 'bsky.social' );

# Authentication (The Modern Way)
my $auth_url = $at->oauth_start( 'user.bsky.social', 'http://localhost', 'http://127.0.0.1:8888/' );
# ... Redirect user to $auth_url, then get $code and $state from callback ...
$at->oauth_callback( $code, $state );

# Creating a Post
$at->post( 'com.atproto.repo.createRecord' => {
    repo       => $at->did,
    collection => 'app.bsky.feed.post',
    record     => {
        text      => 'Hello from Perl!',
        createdAt => At::_now->to_string
    }
});

# Streaming the Firehose
my $fh = $at->firehose(sub ( $header, $body, $err ) {
    return warn $err if $err;
    say "New event: " . $header->{t};
});
$fh->start();
# ... Start event loop (e.g. Mojo::IOLoop->start) ...
```

# DESCRIPTION

At.pm is a comprehensive toolkit for interacting with the AT Protocol (authenticated transfer protocol). It powers
decentralized social networks like Bluesky.

## Rate Limits

At.pm attempts to keep track of rate limits according to the protocol's specs. Requests are categorized (e.g., `auth`,
`repo`, `global`) and tracked per-identifier.

If you approach a limit (less than 10% remaining), a warning is issued. If you exceed a limit, a warning is issued with
the time until reset.

See also: [https://docs.bsky.app/docs/advanced-guides/rate-limits](https://docs.bsky.app/docs/advanced-guides/rate-limits)

# GETTING STARTED

If you are new to the AT Protocol, the first thing to understand is that it is decentralized. Your data lives on a
Personal Data Server (PDS), but your identity is portable.

## Identity (Handles and DIDs)

- **Handle**: A human-readable name like `alice.bsky.social`.
- **DID**: A persistent, machine-readable identifier like `did:plc:z72i7...`.

# AUTHENTICATION

There are two ways to authenticate: the modern OAuth system and the legacy password system. Once  authenticated, all
other methods (like `get`, `post`, and `subscribe`) work the same way.

Developers of new code should be aware that the AT protocol is transitioning to OAuth and this library strongly
encourages its use.

## The OAuth System (Recommended)

OAuth is the secure, modern way to authenticate. It uses DPoP (Demonstrating Proof-of-Possession) to ensure tokens
cannot be stolen and reused.

**1. Start the flow:**

```perl
my $auth_url = $at->oauth_start(
    'user.bsky.social',
    'http://localhost',                  # Client ID
    'http://127.0.0.1:8888/callback',    # Redirect URI
    'atproto transition:generic'         # Scopes
);
```

**2. Redirect the user:** Open `$auth_url` in a browser. After they approve, they will be redirected to your callback
URL with `code` and `state` parameters.

**3. Complete the callback:**

```
$at->oauth_callback( $code, $state );
```

**Note for Local Scripts:** When using `http://localhost` as a Client ID, you should declare your required scopes and
redirect URI in the query string of the Client ID if you need more than the basic `atproto` scope:

```perl
use URI;
my $client_id = URI->new('http://localhost');
$client_id->query_param(scope => 'atproto transition:generic');
$client_id->query_param(redirect_uri => 'http://127.0.0.1:8888/');

my $url = $at->oauth_start($handle, $client_id->as_string, ...);
```

## The Legacy System (App Passwords)

Legacy authentication is simpler but less secure. It uses a single call to `login`.  **Never use your main password;
always use an App Password.**

```
$at->login( 'user.bsky.social', 'your-app-password' );
```

# ACCOUNT MANAGEMENT

## Creating an Account

You can create a new account using `com.atproto.server.createAccount`. Note that most PDS instances (like Bluesky's)
require an invite code.

```perl
my $res = $at->post( 'com.atproto.server.createAccount' => {
    handle      => 'newuser.bsky.social',
    email       => 'user@example.com',
    password    => 'secure-password',
    inviteCode  => 'bsky-social-abcde'
});
```

# WORKING WITH DATA (REPOSITORIES)

Data in the AT Protocol is stored in "repositories" as "records". Each record belongs to a "collection" (defined by a
Lexicon).

## Creating a Post

Posts are records in the `app.bsky.feed.post` collection.

```perl
$at->post( 'com.atproto.repo.createRecord' => {
    repo       => $at->did,
    collection => 'app.bsky.feed.post',
    record     => {
        '$type'   => 'app.bsky.feed.post',
        text      => 'Content of the post',
        createdAt => At::_now->to_string,
    }
});
```

## Listing Records

To see what's in a collection:

```perl
my $res = $at->get( 'com.atproto.repo.listRecords' => {
    repo       => $at->did,
    collection => 'app.bsky.feed.post',
    limit      => 10
});

for my $record (@{$res->{records}}) {
    say $record->{value}{text};
}
```

# FIREHOSE (REAL-TIME STREAMING)

The Firehose is a real-time stream of all events happening on the network (or a specific PDS). This includes new posts,
likes, handle changes, and more.

## Subscribing to the Firehose

**Note:** The Firehose requires [CBOR::Free](https://metacpan.org/pod/CBOR%3A%3AFree) and [Mojo::UserAgent](https://metacpan.org/pod/Mojo%3A%3AUserAgent) to be installed.

```perl
my $fh = $at->firehose(sub ( $header, $body, $err ) {
    if ($err) {
        warn "Firehose error: $err";
        return;
    }

    if ($header->{t} eq '#commit') {
        say "New commit in repo: " . $body->{repo};
    }
});

$fh->start();
```

**Note:** The Firehose requires an event loop to keep the connection alive. Since this library prefers
[Mojo::UserAgent](https://metacpan.org/pod/Mojo%3A%3AUserAgent), you should usually use [Mojo::IOLoop](https://metacpan.org/pod/Mojo%3A%3AIOLoop):

```perl
use Mojo::IOLoop;
# ... setup firehose ...
Mojo::IOLoop->start unless Mojo::IOLoop->is_running;
```

# METHODS

## `new( [ host =` ..., share => ... \] )>

Constructor.

Expected parameters include:

- `host`

    Host for the service. Defaults to `bsky.social`.

- `share`

    Location of lexicons. Defaults to the `share` directory under the distribution.

## `get( $method, [ \%params ] )`

Calls an XRPC query (GET). Returns the decoded JSON response.

## `post( $method, [ \%data ] )`

Calls an XRPC procedure (POST). Returns the decoded JSON response.

## `subscribe( $method, $callback )`

Connects to a WebSocket stream (Firehose).

## `firehose( $callback, [ $url ] )`

Returns a new [At::Protocol::Firehose](https://metacpan.org/pod/At%3A%3AProtocol%3A%3AFirehose) client. `$url` defaults to the Bluesky relay firehose.

## `resolve_handle( $handle )`

Resolves a handle to a DID.

## `collection_scope( $collection, [ $action ] )`

Helper to generate granular OAuth scopes (e.g., `repo:app.bsky.feed.post?action=create`).

# ERROR HANDLING

Exception handling is carried out by returning [At::Error](https://metacpan.org/pod/At%3A%3AError) objects which have untrue boolean values.

# SEE ALSO

[Bluesky](https://metacpan.org/pod/Bluesky) - Bluesky client library

[https://docs.bsky.app/docs/api/](https://docs.bsky.app/docs/api/)

# AUTHOR

Sanko Robinson <sanko@cpan.org>

# LICENSE

Copyright (c) 2024-2026 Sanko Robinson. License: Artistic License 2.0. Other copyrights, terms, and conditions may
apply to data transmitted through this module.
