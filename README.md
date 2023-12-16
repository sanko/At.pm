[![Actions Status](https://github.com/sanko/At.pm/actions/workflows/linux.yaml/badge.svg)](https://github.com/sanko/At.pm/actions) [![Actions Status](https://github.com/sanko/At.pm/actions/workflows/windows.yaml/badge.svg)](https://github.com/sanko/At.pm/actions) [![Actions Status](https://github.com/sanko/At.pm/actions/workflows/osx.yaml/badge.svg)](https://github.com/sanko/At.pm/actions) [![MetaCPAN Release](https://badge.fury.io/pl/At.svg)](https://metacpan.org/release/At)
# NAME

At - The AT Protocol for Social Networking

# SYNOPSIS

```perl
use At;
my $at = At->new( host => 'https://fun.example' );
$at->server->createSession( identifier => 'sanko', password => '1111-aaaa-zzzz-0000' );
$at->repo->createRecord(
    collection => 'app.bsky.feed.post',
    record     => { '$type' => 'app.bsky.feed.post', text => 'Hello world! I posted this via the API.', createdAt => time }
);
```

# DESCRIPTION

The AT Protocol is a "social networking technology created to power the next generation of social applications."

At.pm uses perl's new class system which requires perl 5.38.x or better and, like the protocol itself, is still under
development.

## At::Bluesky

At::Bluesky is a subclass with the host set to `https://bluesky.social` and all the lexicon related to the social
networking site included.

## App Passwords

Taken from the AT Protocol's official documentation:

<div>
    <blockquote>
</div>

For the security of your account, when using any third-party clients, please generate an [app
password](https://atproto.com/specs/xrpc#app-passwords) at Settings > Advanced > App passwords.

App passwords have most of the same abilities as the user's account password, but they're restricted from destructive
actions such as account deletion or account migration. They are also restricted from creating additional app passwords.

<div>
    </blockquote>
</div>

Read their disclaimer here: [https://atproto.com/community/projects#disclaimer](https://atproto.com/community/projects#disclaimer).

# Methods

Honestly, to keep to the layout of the underlying protocol, almost everything is handled in members of this class.

## `new( ... )`

Creates an AT client and initiates an authentication session.

```perl
my $client = At->new( host => 'https://bsky.social' );
```

Expected parameters include:

- `host` - required

    Host for the account. If you're using the 'official' Bluesky, this would be 'https://bsky.social' but you'll probably
    want `At::Bluesky->new(...)` because that client comes with all the bits that aren't part of the core protocol.

## `repo( [...] )`

```perl
my $repo = $at->repo; # Grab default
my $repo = $at->repo( did => 'did:plc:ju7kqxvmz8a8k5bapznf1lto2gkki6miw3' ); # You have permissions?
```

Returns an AT repository. Without arguments, this returns the repository returned by AT in the session data.

## `server( )`

Returns an AT service.

## `admin( )`

# Admin methods

Administration methods require an authenticated session.

## `disableAccountInvites( ... )`

Disable an account from receiving new invite codes, but does not invalidate existing codes.

Expected parameters include:

- `account` - required

    DID of account to modify.

- `note`

    Optional reason for disabled invites.

## `disableInviteCodes( )`

Disable some set of codes and/or all codes associated with a set of users.

Expected parameters include:

- `codes`

    List of codes.

- `accounts`

    List of account DIDs.

# Repo Methods

Repo methods generally require an authorized session. The AT Protocol treats 'posts' and other data as records stored
in repositories.

## `createRecord( ... )`

Create a new record.

```perl
$at->repo->createRecord(
    collection => 'app.bsky.feed.post',
    record     => { '$type' => 'app.bsky.feed.post', text => "Hello world! I posted this via the API.", createdAt => gmtime->datetime . 'Z' }
);
```

Expected parameters include:

- `collection` - required

    The NSID of the record collection.

- `record` - required

    Depending on the type of record, this could be anything. It's undefined in the protocol itself.

# Server Methods

Server methods may require an authorized session.

## `createSession( ... )`

```perl
$at->server->createSession( identifier => 'sanko', password => '1111-2222-3333-4444' );
```

Expected parameters include:

- `identifier` - required

    Handle or other identifier supported by the server for the authenticating user.

- `password` - required

    You know this.

## `describeServer( )`

Get a document describing the service's accounts configuration.

```
$at->server->describeServer( );
```

This method does not require an authenticated session.

Returns a boolean value indicating whether an invite code is required, a list of available user domains, and links to
the TOS and privacy policy.

# See Also

[https://atproto.com/](https://atproto.com/)

[Bluesky on Wikipedia.org](https://en.wikipedia.org/wiki/Bluesky_\(social_network\))

# LICENSE

Copyright (C) Sanko Robinson.

This library is free software; you can redistribute it and/or modify it under the terms found in the Artistic License
2\. Other copyrights, terms, and conditions may apply to data transmitted through this module.

# AUTHOR

Sanko Robinson <sanko@cpan.org>
