# NAME

At - The AT Protocol for Social Networking

# SYNOPSIS

```perl
use At;
my $at = At->new( service => 'https://your.atproto.service.example.com/' ); }
$at->login( 'your.identifier.here', 'hunter2' );
$at->post(
    'com.atproto.repo.createRecord' => {
        repo       => $at->did,
        collection => 'app.bsky.feed.post',
        record     => { '$type' => 'app.bsky.feed.post', text => 'Hello world! I posted this via the API.', createdAt => $at->now->as_string }
    }
);
```

# DESCRIPTION

Unless you're designing a new client arount the AT Protocol, this is probably not what you're looking for.

Try [Bluesky](https://metacpan.org/pod/Bluesky.pm).

## Session Management

You'll need an authenticated session for most API calls. There are two ways to manage sessions:

- 1. Username/password based (deprecated)
- 2. OAuth based (still being rolled out)

Developers of new code should be aware that the AT protocol will be [transitioning to OAuth in over the next year or
so (2024-2025)](https://github.com/bluesky-social/atproto/discussions/2656) and this distribution will comply with this
change.

# Methods

This module is based on perl's new (as of writing) class system which means it's (obviously) object oriented.

## `new( ... )`

```perl
my $at = At->new( service => ... );
```

Create a new At object. Easy.

Expected parameters include:

- `service` - required

    Host for the service.

- `lexicon`

    Location of lexicons. This allows new [AT Protocol Lexicons](https://atproto.com/specs/lexicon) to be referenced without installing a new version of this module.

    Defaults to the dist's share directory.

A new object is returned on success.

## `login( ... )`

Create an app password backed authentication session.

```perl
my $session = $bsky->login(
    identifier => 'john@example.com',
    password   => '1111-2222-3333-4444'
);
```

Expected parameters include:

- `identifier` - required

    Handle or other identifier supported by the server for the authenticating user.

- `password` - required

    This is the app password not the account's password. App passwords are generated at
    [https://bsky.app/settings/app-passwords](https://bsky.app/settings/app-passwords).

- `authFactorToken`

Returns an authorized session on success.

### `resume( ... )`

Resumes an app password based session.

```
$bsky->resume( '...', '...' );
```

Expected parameters include:

- `accessJwt` - required
- `refreshJwt` - required

If the `accessJwt` token has expired, we attempt to use the `refreshJwt` to continue the session with a new token. If
that also fails, well, that's kinda it.

The new session is returned on success.

## `did( )`

Gather the [DID](https://atproto.com/specs/did) (Decentralized Identifiers) of the current user. Returns `undef` on failure or if the client is not authenticated.

## `session( )`

Gather the current AT Protocol session info. You should store the accessJwt and refreshJwt tokens securely.

# Error Handling

Exception handling is carried out by returning objects with untrue boolean values.

# See Also

[Bluesky](https://metacpan.org/pod/Bluesky) - Bluesky client library

[App::bsky](https://metacpan.org/pod/App%3A%3Absky) - Bluesky client on the command line

[https://docs.bsky.app/docs/api/](https://docs.bsky.app/docs/api/)

# LICENSE

Copyright (C) Sanko Robinson.

This library is free software; you can redistribute it and/or modify it under the terms found in the Artistic License
2\. Other copyrights, terms, and conditions may apply to data transmitted through this module.

# AUTHOR

Sanko Robinson <sanko@cpan.org>
