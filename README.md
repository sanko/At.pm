# NAME

At - The AT Protocol for Social Networking

# SYNOPSIS

```perl
use At;
my $at = At->new( host => 'https://your.atproto.service.example.com/' ); }
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

This is probably not what you're looking for.

# See Also

TODO

# LICENSE

This software is Copyright (c) 2024 by Sanko Robinson <sanko@cpan.org>.

This is free software, licensed under:

```
The Artistic License 2.0 (GPL Compatible)
```

See the `LICENSE` file for full text.

# AUTHOR

Sanko Robinson <sanko@cpan.org>
