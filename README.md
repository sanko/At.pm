[![Actions Status](https://github.com/sanko/At.pm/actions/workflows/linux.yaml/badge.svg)](https://github.com/sanko/At.pm/actions) [![Actions Status](https://github.com/sanko/At.pm/actions/workflows/windows.yaml/badge.svg)](https://github.com/sanko/At.pm/actions) [![Actions Status](https://github.com/sanko/At.pm/actions/workflows/osx.yaml/badge.svg)](https://github.com/sanko/At.pm/actions) [![MetaCPAN Release](https://badge.fury.io/pl/At.svg)](https://metacpan.org/release/At)
# NAME

At - The AT Protocol for Social Networking

# SYNOPSIS

```perl
use At;
my $at = At->new( host => 'https://fun.example' );
$at->createSession( 'sanko', '1111-aaaa-zzzz-0000' );
$at->createRecord(
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
my $self = At->new( host => 'https://bsky.social' );
```

Expected parameters include:

- `host` - required

    Host for the account. If you're using the 'official' Bluesky, this would be 'https://bsky.social' but you'll probably
    want `At::Bluesky->new(...)` because that client comes with all the bits that aren't part of the core protocol.

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
$at->createRecord(
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

```
$at->createSession( 'sanko', '1111-2222-3333-4444' );
```

Create an authentication session.

Expected parameters include:

- `identifier` - required

    Handle or other identifier supported by the server for the authenticating user.

- `password` - required

On success, the access and refresh JSON web tokens, the account's handle, DID and (optionally) other data is returned.

## `describeServer( )`

Get a document describing the service's accounts configuration.

```
$at->describeServer( );
```

This method does not require an authenticated session.

Returns a boolean value indicating whether an invite code is required, a list of available user domains, and links to
the TOS and privacy policy.

## `listAppPasswords( )`

```
$at->listAppPasswords( );
```

List all App Passwords.

Returns a list of passwords as new `At::Lexicon::com::atproto::server::listAppPasswords::appPassword` objects.

## `getSession( )`

```
$at->getSession( );
```

Get information about the current session.

Returns the handle, DID, and (optionally) other data.

## `getAccountInviteCodes( )`

```
$at->getAccountInviteCodes( );
```

Get all invite codes for a given account.

Returns codes as a list of new `At::Lexicon::com::atproto::server::inviteCode` objects.

## `getAccountInviteCodes( [...] )`

```
$at->getAccountInviteCodes( );
```

Get all invite codes for a given account.

Expected parameters include:

- `includeUsed`

    Optional boolean flag.

- `createAvailable`

    Optional boolean flag.

Returns a list of `At::Lexicon::com::atproto::server::inviteCode` objects on success. Note that this method returns an
error if the session was authorized with an app password.

## `updateEmail( ..., [...] )`

```
$at->updateEmail( 'smith...@gmail.com' );
```

Update an account's email.

Expected parameters include:

- `email` - required
- `token`

    This method requires a token from `requestEmailUpdate( ... )` if the account's email has been confirmed.

## `requestEmailUpdate( ... )`

```
$at->requestEmailUpdate( 1 );
```

Request a token in order to update email.

Expected parameters include:

- `tokenRequired` - required

    Boolean value.

## `revokeAppPassword( ... )`

```
$at->revokeAppPassword( 'Demo App [beta]' );
```

Revoke an App Password by name.

Expected parameters include:

- `name` - required

## `resetPassword( ... )`

```
$at->resetPassword( 'fdsjlkJIofdsaf89w3jqirfu2q8docwe', '****************' );
```

Reset a user account password using a token.

Expected parameters include:

- `token` - required
- `password` - required

## `resetPassword( ... )`

```
$at->resetPassword( 'fdsjlkJIofdsaf89w3jqirfu2q8docwe', '****************' );
```

Reset a user account password using a token.

Expected parameters include:

- `token` - required
- `password` - required

## `reserveSigningKey( [...] )`

```
$at->reserveSigningKey( 'did:...' );
```

Reserve a repo signing key for account creation.

Expected parameters include:

- `did`

    The did to reserve a new did:key for.

On success, a public signing key in the form of a did:key is returned.

## `requestPasswordReset( [...] )`

```
$at->requestPasswordReset( 'smith...@gmail.com' );
```

Initiate a user account password reset via email.

Expected parameters include:

- `email` - required

## `requestEmailConfirmation( )`

```
$at->requestEmailConfirmation( );
```

Request an email with a code to confirm ownership of email.

## `requestAccountDelete( )`

```
$at->requestAccountDelete( );
```

Initiate a user account deletion via email.

## `deleteSession( )`

```
$at->deleteSession( );
```

Initiate a user account deletion via email.

## `deleteAccount( )`

```
$at->deleteAccount( );
```

Delete an actor's account with a token and password.

Expected parameters include:

- `did` - required
- `password` - required
- `token` - required

## `createInviteCodes( ..., [...] )`

```
$at->createInviteCodes( 1, 1 );
```

Create invite codes.

Expected parameters include:

- `codeCount` - required

    The number of codes to create. Default value is 1.

- `useCount` - required

    Int.

- `forAccounts`

    List of DIDs.

On success, returns a list of new `At::Lexicon::com::atproto::server::createInviteCodes::accountCodes` objects.

## `createInviteCode( ..., [...] )`

```
$at->createInviteCode( 1 );
```

Create an invite code.

Expected parameters include:

- `useCount` - required

    Int.

- `forAccounts`

    List of DIDs.

On success, a new invite code is returned.

## `createAppPassword( ..., [...] )`

```
$at->createAppPassword( 'AT Client [release]' );
```

Create an App Password.

Expected parameters include:

- `name` - required

On success, a new `At::Lexicon::com::atproto::server::createAppPassword::appPassword` object.

## `createAccount( ..., [...] )`

```
$at->createAccount( 'jsmith....', '*********' );
```

Create an account.

Expected parameters include:

- `handle` - required
- `email`
- `password`
- `inviteCode`
- `did`
- `recoveryKey`
- `plcOP`

On success, JSON web access and refresh tokens, the handle, did, and (optionally) a server defined didDoc are returned.

## `confirmEmail( ... )`

```
$at->confirmEmail( 'jsmith...@gmail.com', 'idkidkidkidkdifkasjkdfsaojfd' );
```

Confirm an email using a token from `requestEmailConfirmation( )`,

Expected parameters include:

- `email` - required
- `token` - required

# See Also

[https://atproto.com/](https://atproto.com/)

[Bluesky on Wikipedia.org](https://en.wikipedia.org/wiki/Bluesky_\(social_network\))

# LICENSE

Copyright (C) Sanko Robinson.

This library is free software; you can redistribute it and/or modify it under the terms found in the Artistic License
2\. Other copyrights, terms, and conditions may apply to data transmitted through this module.

# AUTHOR

Sanko Robinson <sanko@cpan.org>
