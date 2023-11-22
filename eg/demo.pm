# /home/s/Desktop/Projects/At.pm/eg/atproto/lexicons/app/bsky/actor/defs.json
use v5.38;
no warnings 'experimental::class', 'experimental::builtin';    # Be quiet.
use feature 'class';
use URI;

class At::Lexicon::app::bsky::actor::defs::adultContentPref {
    field $enabled : param;
    ADJUST { }                                                 # TODO: handle types such as string maxlen, etc.

    # perlclass does not have :reader yet
    method enabled {$enabled}

    method _raw() {
        { enabled => $enabled, }
    }
}

class At::Lexicon::app::bsky::actor::defs::threadViewPref {
    field $sort : param                    = ();
    field $prioritizeFollowedUsers : param = ();
    ADJUST { }    # TODO: handle types such as string maxlen, etc.

    # perlclass does not have :reader yet
    method sort                    {$sort}
    method prioritizeFollowedUsers {$prioritizeFollowedUsers}

    method _raw() {
        { sort => $sort, prioritizeFollowedUsers => $prioritizeFollowedUsers, }
    }
}

# trash.pl:109: {
#   items => {
#              refs => [
#                        "#adultContentPref",
#                        "#contentLabelPref",
#                        "#savedFeedsPref",
#                        "#personalDetailsPref",
#                        "#feedViewPref",
#                        "#threadViewPref",
#                      ],
#              type => "union",
#            },
#   type  => "array",
# }
class At::Lexicon::app::bsky::actor::defs::contentLabelPref {
    field $visibility : param;
    field $label : param;
    ADJUST { }    # TODO: handle types such as string maxlen, etc.

    # perlclass does not have :reader yet
    method visibility {$visibility}
    method label      {$label}

    method _raw() {
        { visibility => $visibility, label => $label, }
    }
}

class At::Lexicon::app::bsky::actor::defs::viewerState {
    field $followedBy : param     = ();
    field $blockingByList : param = ();
    field $mutedByList : param    = ();
    field $blockedBy : param      = ();
    field $muted : param          = ();
    field $blocking : param       = ();
    field $following : param      = ();
    ADJUST { }    # TODO: handle types such as string maxlen, etc.

    # perlclass does not have :reader yet
    method followedBy     {$followedBy}
    method blockingByList {$blockingByList}
    method mutedByList    {$mutedByList}
    method blockedBy      {$blockedBy}
    method muted          {$muted}
    method blocking       {$blocking}
    method following      {$following}

    method _raw() {
        {   followedBy     => $followedBy,
            blockingByList => $blockingByList,
            mutedByList    => $mutedByList,
            blockedBy      => $blockedBy,
            muted          => $muted,
            blocking       => $blocking,
            following      => $following,
        }
    }
}

class At::Lexicon::app::bsky::actor::defs::personalDetailsPref {
    field $birthDate : param = ();
    ADJUST { }    # TODO: handle types such as string maxlen, etc.

    # perlclass does not have :reader yet
    method birthDate {$birthDate}

    method _raw() {
        { birthDate => $birthDate, }
    }
}

class At::Lexicon::app::bsky::actor::defs::profileView {
    field $viewer : param      = ();
    field $displayName : param = ();
    field $labels : param      = ();
    field $handle : param;
    field $indexedAt : param   = ();
    field $avatar : param      = ();
    field $description : param = ();
    field $did : param;
    ADJUST { }    # TODO: handle types such as string maxlen, etc.

    # perlclass does not have :reader yet
    method viewer      {$viewer}
    method displayName {$displayName}
    method labels      {$labels}
    method handle      {$handle}
    method indexedAt   {$indexedAt}
    method avatar      {$avatar}
    method description {$description}
    method did         {$did}

    method _raw() {
        {   viewer      => $viewer,
            displayName => $displayName,
            labels      => $labels,
            handle      => $handle,
            indexedAt   => $indexedAt,
            avatar      => $avatar,
            description => $description,
            did         => $did,
        }
    }
}

class At::Lexicon::app::bsky::actor::defs::feedViewPref {
    field $hideReposts : param             = ();
    field $hideRepliesByUnfollowed : param = ();
    field $hideQuotePosts : param          = ();
    field $feed : param;
    field $hideRepliesByLikeCount : param = ();
    field $hideReplies : param            = ();
    ADJUST { }    # TODO: handle types such as string maxlen, etc.

    # perlclass does not have :reader yet
    method hideReposts             {$hideReposts}
    method hideRepliesByUnfollowed {$hideRepliesByUnfollowed}
    method hideQuotePosts          {$hideQuotePosts}
    method feed                    {$feed}
    method hideRepliesByLikeCount  {$hideRepliesByLikeCount}
    method hideReplies             {$hideReplies}

    method _raw() {
        {   hideReposts             => $hideReposts,
            hideRepliesByUnfollowed => $hideRepliesByUnfollowed,
            hideQuotePosts          => $hideQuotePosts,
            feed                    => $feed,
            hideRepliesByLikeCount  => $hideRepliesByLikeCount,
            hideReplies             => $hideReplies,
        }
    }
}

class At::Lexicon::app::bsky::actor::defs::savedFeedsPref {
    field $saved : param;
    field $pinned : param;
    ADJUST { }    # TODO: handle types such as string maxlen, etc.

    # perlclass does not have :reader yet
    method saved  {$saved}
    method pinned {$pinned}

    method _raw() {
        { saved => $saved, pinned => $pinned, }
    }
}

class At::Lexicon::app::bsky::actor::defs::profileViewDetailed {
    field $viewer : param       = ();
    field $labels : param       = ();
    field $indexedAt : param    = ();
    field $banner : param       = ();
    field $followsCount : param = ();
    field $did : param;
    field $postsCount : param  = ();
    field $displayName : param = ();
    field $handle : param;
    field $followersCount : param = ();
    field $avatar : param         = ();
    field $description : param    = ();
    ADJUST { }    # TODO: handle types such as string maxlen, etc.

    # perlclass does not have :reader yet
    method viewer         {$viewer}
    method labels         {$labels}
    method indexedAt      {$indexedAt}
    method banner         {$banner}
    method followsCount   {$followsCount}
    method did            {$did}
    method postsCount     {$postsCount}
    method displayName    {$displayName}
    method handle         {$handle}
    method followersCount {$followersCount}
    method avatar         {$avatar}
    method description    {$description}

    method _raw() {
        {   viewer         => $viewer,
            labels         => $labels,
            indexedAt      => $indexedAt,
            banner         => $banner,
            followsCount   => $followsCount,
            did            => $did,
            postsCount     => $postsCount,
            displayName    => $displayName,
            handle         => $handle,
            followersCount => $followersCount,
            avatar         => $avatar,
            description    => $description,
        }
    }
}

class At::Lexicon::app::bsky::actor::defs::profileViewBasic {
    field $viewer : param      = ();
    field $labels : param      = ();
    field $displayName : param = ();
    field $handle : param;
    field $did : param;
    field $avatar : param = ();
    ADJUST { }    # TODO: handle types such as string maxlen, etc.

    # perlclass does not have :reader yet
    method viewer      {$viewer}
    method labels      {$labels}
    method displayName {$displayName}
    method handle      {$handle}
    method did         {$did}
    method avatar      {$avatar}

    method _raw() {
        { viewer => $viewer, labels => $labels, displayName => $displayName, handle => $handle, did => $did, avatar => $avatar, }
    }
}
  __END__
# /home/s/Desktop/Projects/At.pm/eg/atproto/lexicons/app/bsky/actor/getPreferences.json

   use v5.38;
    no warnings 'experimental::class', 'experimental::builtin';    # Be quiet.
    use feature 'class';
    use URI;

# trash.pl:109: {
#   description => "Get private preferences attached to the account.",
#   output => {
#     encoding => "application/json",
#     schema   => {
#                   properties => {
#                     preferences => { ref => "app.bsky.actor.defs#preferences", type => "ref" },
#                   },
#                   required => ["preferences"],
#                   type => "object",
#                 },
#   },
#   parameters => { properties => {}, type => "params" },
#   type => "query",
# }
# /home/s/Desktop/Projects/At.pm/eg/atproto/lexicons/app/bsky/actor/getProfile.json

   use v5.38;
    no warnings 'experimental::class', 'experimental::builtin';    # Be quiet.
    use feature 'class';
    use URI;

# trash.pl:109: {
#   description => "Get detailed profile view of an actor.",
#   output => {
#     encoding => "application/json",
#     schema   => { ref => "app.bsky.actor.defs#profileViewDetailed", type => "ref" },
#   },
#   parameters => {
#     properties => { actor => { format => "at-identifier", type => "string" } },
#     required => ["actor"],
#     type => "params",
#   },
#   type => "query",
# }
# /home/s/Desktop/Projects/At.pm/eg/atproto/lexicons/app/bsky/actor/getProfiles.json

   use v5.38;
    no warnings 'experimental::class', 'experimental::builtin';    # Be quiet.
    use feature 'class';
    use URI;

# trash.pl:109: {
#   description => "Get detailed profile views of multiple actors.",
#   output => {
#     encoding => "application/json",
#     schema   => {
#                   properties => {
#                     profiles => {
#                       items => { ref => "app.bsky.actor.defs#profileViewDetailed", type => "ref" },
#                       type  => "array",
#                     },
#                   },
#                   required => ["profiles"],
#                   type => "object",
#                 },
#   },
#   parameters => {
#     properties => {
#       actors => {
#         items => { format => "at-identifier", type => "string" },
#         maxLength => 25,
#         type => "array",
#       },
#     },
#     required => ["actors"],
#     type => "params",
#   },
#   type => "query",
# }
# /home/s/Desktop/Projects/At.pm/eg/atproto/lexicons/app/bsky/actor/getSuggestions.json

   use v5.38;
    no warnings 'experimental::class', 'experimental::builtin';    # Be quiet.
    use feature 'class';
    use URI;

# trash.pl:109: {
#   description => "Get a list of suggested actors, used for discovery.",
#   output => {
#     encoding => "application/json",
#     schema   => {
#                   properties => {
#                     actors => {
#                                 items => { ref => "app.bsky.actor.defs#profileView", type => "ref" },
#                                 type  => "array",
#                               },
#                     cursor => { type => "string" },
#                   },
#                   required => ["actors"],
#                   type => "object",
#                 },
#   },
#   parameters => {
#     properties => {
#       cursor => { type => "string" },
#       limit  => { default => 50, maximum => 100, minimum => 1, type => "integer" },
#     },
#     type => "params",
#   },
#   type => "query",
# }
# /home/s/Desktop/Projects/At.pm/eg/atproto/lexicons/app/bsky/actor/profile.json

   use v5.38;
    no warnings 'experimental::class', 'experimental::builtin';    # Be quiet.
    use feature 'class';
    use URI;

  class At::Lexicon::app::bsky::actor::profile {
    field $avatar :param = ();
    field $banner :param = ();
    field $description :param = ();
    field $displayName :param = ();
    field $labels :param = ();

    ADJUST{} # TODO: handle types such as string maxlen, etc.

    # perlclass does not have :reader yet
    method avatar{ $avatar };
    method banner{ $banner };
    method description{ $description };
    method displayName{ $displayName };
    method labels{ $labels };

    method _raw() {{
        avatar => $avatar,
        banner => $banner,
        description => $description,
        displayName => $displayName,
        labels => $labels,
    }}
# /home/s/Desktop/Projects/At.pm/eg/atproto/lexicons/app/bsky/actor/putPreferences.json

   use v5.38;
    no warnings 'experimental::class', 'experimental::builtin';    # Be quiet.
    use feature 'class';
    use URI;

  method putPreferences (%args){
    use Carp qw[confess];
    $client->http->session // confess 'creating a post requires an authenticated client';
# trash.pl:52: {
#   description => "Set the private preferences attached to the account.",
#   input => {
#     encoding => "application/json",
#     schema   => {
#                   properties => {
#                     preferences => { ref => "app.bsky.actor.defs#preferences", type => "ref" },
#                   },
#                   required => ["preferences"],
#                   type => "object",
#                 },
#   },
#   type => "procedure",
# }
    confess $_ . ' is a required parameter' for 'preferences';
    my $res = $client->http->post( sprintf( '%s/xrpc/%s', $client->host(), 'app.bsky.actor.putPreferences' )
      { content => \%args }
    );
    $res->{uri} = URI->new( $res->{uri} ) if defined $res->{uri};
    $res;
  }
# /home/s/Desktop/Projects/At.pm/eg/atproto/lexicons/app/bsky/actor/searchActors.json

   use v5.38;
    no warnings 'experimental::class', 'experimental::builtin';    # Be quiet.
    use feature 'class';
    use URI;

# trash.pl:109: {
#   description => "Find actors (profiles) matching search criteria.",
#   output => {
#     encoding => "application/json",
#     schema   => {
#                   properties => {
#                     actors => {
#                                 items => { ref => "app.bsky.actor.defs#profileView", type => "ref" },
#                                 type  => "array",
#                               },
#                     cursor => { type => "string" },
#                   },
#                   required => ["actors"],
#                   type => "object",
#                 },
#   },
#   parameters => {
#     properties => {
#       cursor => { type => "string" },
#       limit => { default => 25, maximum => 100, minimum => 1, type => "integer" },
#       q => {
#         description => "Search query string. Syntax, phrase, boolean, and faceting is unspecified, but Lucene query syntax is recommended.",
#         type => "string",
#       },
#       term => { description => "DEPRECATED: use 'q' instead.", type => "string" },
#     },
#     type => "params",
#   },
#   type => "query",
# }
# /home/s/Desktop/Projects/At.pm/eg/atproto/lexicons/app/bsky/actor/searchActorsTypeahead.json

   use v5.38;
    no warnings 'experimental::class', 'experimental::builtin';    # Be quiet.
    use feature 'class';
    use URI;

# trash.pl:109: {
#   description => "Find actor suggestions for a prefix search term.",
#   output => {
#     encoding => "application/json",
#     schema   => {
#                   properties => {
#                     actors => {
#                       items => { ref => "app.bsky.actor.defs#profileViewBasic", type => "ref" },
#                       type  => "array",
#                     },
#                   },
#                   required => ["actors"],
#                   type => "object",
#                 },
#   },
#   parameters => {
#     properties => {
#       limit => { default => 10, maximum => 100, minimum => 1, type => "integer" },
#       q => {
#         description => "Search query prefix; not a full query string.",
#         type => "string",
#       },
#       term => { description => "DEPRECATED: use 'q' instead.", type => "string" },
#     },
#     type => "params",
#   },
#   type => "query",
# }
# /home/s/Desktop/Projects/At.pm/eg/atproto/lexicons/app/bsky/embed/external.json

   use v5.38;
    no warnings 'experimental::class', 'experimental::builtin';    # Be quiet.
    use feature 'class';
    use URI;

  class At::Lexicon::app::bsky::embed::external::main {
    field $external :param;

    ADJUST{} # TODO: handle types such as string maxlen, etc.

    # perlclass does not have :reader yet
    method external{ $external };

    method _raw() {{
        external => $external,
    }}
  }
  class At::Lexicon::app::bsky::embed::external::viewExternal {
    field $title :param;
    field $description :param;
    field $uri :param;
    field $thumb :param = ();

    ADJUST{} # TODO: handle types such as string maxlen, etc.

    # perlclass does not have :reader yet
    method title{ $title };
    method description{ $description };
    method uri{ $uri };
    method thumb{ $thumb };

    method _raw() {{
        title => $title,
        description => $description,
        uri => $uri,
        thumb => $thumb,
    }}
  }
  class At::Lexicon::app::bsky::embed::external::external {
    field $description :param;
    field $title :param;
    field $thumb :param = ();
    field $uri :param;

    ADJUST{} # TODO: handle types such as string maxlen, etc.

    # perlclass does not have :reader yet
    method description{ $description };
    method title{ $title };
    method thumb{ $thumb };
    method uri{ $uri };

    method _raw() {{
        description => $description,
        title => $title,
        thumb => $thumb,
        uri => $uri,
    }}
  }
  class At::Lexicon::app::bsky::embed::external::view {
    field $external :param;

    ADJUST{} # TODO: handle types such as string maxlen, etc.

    # perlclass does not have :reader yet
    method external{ $external };

    method _raw() {{
        external => $external,
    }}
  }
# /home/s/Desktop/Projects/At.pm/eg/atproto/lexicons/app/bsky/embed/images.json

   use v5.38;
    no warnings 'experimental::class', 'experimental::builtin';    # Be quiet.
    use feature 'class';
    use URI;

  class At::Lexicon::app::bsky::embed::images::viewImage {
    field $fullsize :param;
    field $aspectRatio :param = ();
    field $alt :param;
    field $thumb :param;

    ADJUST{} # TODO: handle types such as string maxlen, etc.

    # perlclass does not have :reader yet
    method fullsize{ $fullsize };
    method aspectRatio{ $aspectRatio };
    method alt{ $alt };
    method thumb{ $thumb };

    method _raw() {{
        fullsize => $fullsize,
        aspectRatio => $aspectRatio,
        alt => $alt,
        thumb => $thumb,
    }}
  }
  class At::Lexicon::app::bsky::embed::images::image {
    field $alt :param;
    field $aspectRatio :param = ();
    field $image :param;

    ADJUST{} # TODO: handle types such as string maxlen, etc.

    # perlclass does not have :reader yet
    method alt{ $alt };
    method aspectRatio{ $aspectRatio };
    method image{ $image };

    method _raw() {{
        alt => $alt,
        aspectRatio => $aspectRatio,
        image => $image,
    }}
  }
  class At::Lexicon::app::bsky::embed::images::main {
    field $images :param;

    ADJUST{} # TODO: handle types such as string maxlen, etc.

    # perlclass does not have :reader yet
    method images{ $images };

    method _raw() {{
        images => $images,
    }}
  }
  class At::Lexicon::app::bsky::embed::images::aspectRatio {
    field $width :param;
    field $height :param;

    ADJUST{} # TODO: handle types such as string maxlen, etc.

    # perlclass does not have :reader yet
    method width{ $width };
    method height{ $height };

    method _raw() {{
        width => $width,
        height => $height,
    }}
  }
  class At::Lexicon::app::bsky::embed::images::view {
    field $images :param;

    ADJUST{} # TODO: handle types such as string maxlen, etc.

    # perlclass does not have :reader yet
    method images{ $images };

    method _raw() {{
        images => $images,
    }}
  }
# /home/s/Desktop/Projects/At.pm/eg/atproto/lexicons/app/bsky/embed/record.json

   use v5.38;
    no warnings 'experimental::class', 'experimental::builtin';    # Be quiet.
    use feature 'class';
    use URI;

  class At::Lexicon::app::bsky::embed::record::viewNotFound {
    field $notFound :param;
    field $uri :param;

    ADJUST{} # TODO: handle types such as string maxlen, etc.

    # perlclass does not have :reader yet
    method notFound{ $notFound };
    method uri{ $uri };

    method _raw() {{
        notFound => $notFound,
        uri => $uri,
    }}
  }
  class At::Lexicon::app::bsky::embed::record::main {
    field $record :param;

    ADJUST{} # TODO: handle types such as string maxlen, etc.

    # perlclass does not have :reader yet
    method record{ $record };

    method _raw() {{
        record => $record,
    }}
  }

  __END__
  class At::Lexicon::app::bsky::embed::record::viewRecord {
    field $value :param;
    field $indexedAt :param;
    field $uri :param;
    field $labels :param = ();
    field $author :param;
    field $embeds :param = ();
    field $cid :param;

    ADJUST{} # TODO: handle types such as string maxlen, etc.

    # perlclass does not have :reader yet
    method value{ $value };
    method indexedAt{ $indexedAt };
    method uri{ $uri };
    method labels{ $labels };
    method author{ $author };
    method embeds{ $embeds };
    method cid{ $cid };

    method _raw() {{
        value => $value,
        indexedAt => $indexedAt,
        uri => $uri,
        labels => $labels,
        author => $author,
        embeds => $embeds,
        cid => $cid,
    }}
  }
  class At::Lexicon::app::bsky::embed::record::view {
    field $record :param;

    ADJUST{} # TODO: handle types such as string maxlen, etc.

    # perlclass does not have :reader yet
    method record{ $record };

    method _raw() {{
        record => $record,
    }}
  }
  class At::Lexicon::app::bsky::embed::record::viewBlocked {
    field $author :param;
    field $uri :param;
    field $blocked :param;

    ADJUST{} # TODO: handle types such as string maxlen, etc.

    # perlclass does not have :reader yet
    method author{ $author };
    method uri{ $uri };
    method blocked{ $blocked };

    method _raw() {{
        author => $author,
        uri => $uri,
        blocked => $blocked,
    }}
  }
# /home/s/Desktop/Projects/At.pm/eg/atproto/lexicons/app/bsky/embed/recordWithMedia.json

   use v5.38;
    no warnings 'experimental::class', 'experimental::builtin';    # Be quiet.
    use feature 'class';
    use URI;

  class At::Lexicon::app::bsky::embed::recordWithMedia::main {
    field $media :param;
    field $record :param;

    ADJUST{} # TODO: handle types such as string maxlen, etc.

    # perlclass does not have :reader yet
    method media{ $media };
    method record{ $record };

    method _raw() {{
        media => $media,
        record => $record,
    }}
  }
  class At::Lexicon::app::bsky::embed::recordWithMedia::view {
    field $media :param;
    field $record :param;

    ADJUST{} # TODO: handle types such as string maxlen, etc.

    # perlclass does not have :reader yet
    method media{ $media };
    method record{ $record };

    method _raw() {{
        media => $media,
        record => $record,
    }}
  }
# /home/s/Desktop/Projects/At.pm/eg/atproto/lexicons/app/bsky/feed/defs.json

   use v5.38;
    no warnings 'experimental::class', 'experimental::builtin';    # Be quiet.
    use feature 'class';
    use URI;

  class At::Lexicon::app::bsky::feed::defs::postView {
    field $uri :param;
    field $labels :param = ();
    field $replyCount :param = ();
    field $author :param;
    field $viewer :param = ();
    field $threadgate :param = ();
    field $embed :param = ();
    field $record :param;
    field $indexedAt :param;
    field $cid :param;
    field $likeCount :param = ();
    field $repostCount :param = ();

    ADJUST{} # TODO: handle types such as string maxlen, etc.

    # perlclass does not have :reader yet
    method uri{ $uri };
    method labels{ $labels };
    method replyCount{ $replyCount };
    method author{ $author };
    method viewer{ $viewer };
    method threadgate{ $threadgate };
    method embed{ $embed };
    method record{ $record };
    method indexedAt{ $indexedAt };
    method cid{ $cid };
    method likeCount{ $likeCount };
    method repostCount{ $repostCount };

    method _raw() {{
        uri => $uri,
        labels => $labels,
        replyCount => $replyCount,
        author => $author,
        viewer => $viewer,
        threadgate => $threadgate,
        embed => $embed,
        record => $record,
        indexedAt => $indexedAt,
        cid => $cid,
        likeCount => $likeCount,
        repostCount => $repostCount,
    }}
  }
  class At::Lexicon::app::bsky::feed::defs::viewerState {
    field $repost :param = ();
    field $like :param = ();

    ADJUST{} # TODO: handle types such as string maxlen, etc.

    # perlclass does not have :reader yet
    method repost{ $repost };
    method like{ $like };

    method _raw() {{
        repost => $repost,
        like => $like,
    }}
  }
  class At::Lexicon::app::bsky::feed::defs::viewerThreadState {
    field $canReply :param = ();

    ADJUST{} # TODO: handle types such as string maxlen, etc.

    # perlclass does not have :reader yet
    method canReply{ $canReply };

    method _raw() {{
        canReply => $canReply,
    }}
  }
  class At::Lexicon::app::bsky::feed::defs::feedViewPost {
    field $reply :param = ();
    field $reason :param = ();
    field $post :param;

    ADJUST{} # TODO: handle types such as string maxlen, etc.

    # perlclass does not have :reader yet
    method reply{ $reply };
    method reason{ $reason };
    method post{ $post };

    method _raw() {{
        reply => $reply,
        reason => $reason,
        post => $post,
    }}
  }
  class At::Lexicon::app::bsky::feed::defs::blockedAuthor {
    field $viewer :param = ();
    field $did :param;

    ADJUST{} # TODO: handle types such as string maxlen, etc.

    # perlclass does not have :reader yet
    method viewer{ $viewer };
    method did{ $did };

    method _raw() {{
        viewer => $viewer,
        did => $did,
    }}
  }
  class At::Lexicon::app::bsky::feed::defs::blockedPost {
    field $blocked :param;
    field $author :param;
    field $uri :param;

    ADJUST{} # TODO: handle types such as string maxlen, etc.

    # perlclass does not have :reader yet
    method blocked{ $blocked };
    method author{ $author };
    method uri{ $uri };

    method _raw() {{
        blocked => $blocked,
        author => $author,
        uri => $uri,
    }}
  }
  class At::Lexicon::app::bsky::feed::defs::replyRef {
    field $root :param;
    field $parent :param;

    ADJUST{} # TODO: handle types such as string maxlen, etc.

    # perlclass does not have :reader yet
    method root{ $root };
    method parent{ $parent };

    method _raw() {{
        root => $root,
        parent => $parent,
    }}
  }
  class At::Lexicon::app::bsky::feed::defs::notFoundPost {
    field $notFound :param;
    field $uri :param;

    ADJUST{} # TODO: handle types such as string maxlen, etc.

    # perlclass does not have :reader yet
    method notFound{ $notFound };
    method uri{ $uri };

    method _raw() {{
        notFound => $notFound,
        uri => $uri,
    }}
  }
  class At::Lexicon::app::bsky::feed::defs::reasonRepost {
    field $indexedAt :param;
    field $by :param;

    ADJUST{} # TODO: handle types such as string maxlen, etc.

    # perlclass does not have :reader yet
    method indexedAt{ $indexedAt };
    method by{ $by };

    method _raw() {{
        indexedAt => $indexedAt,
        by => $by,
    }}
  }
  class At::Lexicon::app::bsky::feed::defs::skeletonFeedPost {
    field $reason :param = ();
    field $post :param;

    ADJUST{} # TODO: handle types such as string maxlen, etc.

    # perlclass does not have :reader yet
    method reason{ $reason };
    method post{ $post };

    method _raw() {{
        reason => $reason,
        post => $post,
    }}
  }
  class At::Lexicon::app::bsky::feed::defs::generatorViewerState {
    field $like :param = ();

    ADJUST{} # TODO: handle types such as string maxlen, etc.

    # perlclass does not have :reader yet
    method like{ $like };

    method _raw() {{
        like => $like,
    }}
  }
  class At::Lexicon::app::bsky::feed::defs::generatorView {
    field $cid :param;
    field $displayName :param;
    field $descriptionFacets :param = ();
    field $description :param = ();
    field $avatar :param = ();
    field $likeCount :param = ();
    field $creator :param;
    field $uri :param;
    field $viewer :param = ();
    field $did :param;
    field $indexedAt :param;

    ADJUST{} # TODO: handle types such as string maxlen, etc.

    # perlclass does not have :reader yet
    method cid{ $cid };
    method displayName{ $displayName };
    method descriptionFacets{ $descriptionFacets };
    method description{ $description };
    method avatar{ $avatar };
    method likeCount{ $likeCount };
    method creator{ $creator };
    method uri{ $uri };
    method viewer{ $viewer };
    method did{ $did };
    method indexedAt{ $indexedAt };

    method _raw() {{
        cid => $cid,
        displayName => $displayName,
        descriptionFacets => $descriptionFacets,
        description => $description,
        avatar => $avatar,
        likeCount => $likeCount,
        creator => $creator,
        uri => $uri,
        viewer => $viewer,
        did => $did,
        indexedAt => $indexedAt,
    }}
  }
  class At::Lexicon::app::bsky::feed::defs::threadViewPost {
    field $parent :param = ();
    field $post :param;
    field $replies :param = ();
    field $viewer :param = ();

    ADJUST{} # TODO: handle types such as string maxlen, etc.

    # perlclass does not have :reader yet
    method parent{ $parent };
    method post{ $post };
    method replies{ $replies };
    method viewer{ $viewer };

    method _raw() {{
        parent => $parent,
        post => $post,
        replies => $replies,
        viewer => $viewer,
    }}
  }
  class At::Lexicon::app::bsky::feed::defs::skeletonReasonRepost {
    field $repost :param;

    ADJUST{} # TODO: handle types such as string maxlen, etc.

    # perlclass does not have :reader yet
    method repost{ $repost };

    method _raw() {{
        repost => $repost,
    }}
  }
  class At::Lexicon::app::bsky::feed::defs::threadgateView {
    field $uri :param = ();
    field $cid :param = ();
    field $lists :param = ();
    field $record :param = ();

    ADJUST{} # TODO: handle types such as string maxlen, etc.

    # perlclass does not have :reader yet
    method uri{ $uri };
    method cid{ $cid };
    method lists{ $lists };
    method record{ $record };

    method _raw() {{
        uri => $uri,
        cid => $cid,
        lists => $lists,
        record => $record,
    }}
  }
# /home/s/Desktop/Projects/At.pm/eg/atproto/lexicons/app/bsky/feed/describeFeedGenerator.json

   use v5.38;
    no warnings 'experimental::class', 'experimental::builtin';    # Be quiet.
    use feature 'class';
    use URI;

# trash.pl:109: {
#   description => "Get information about a feed generator, including policies and offered feed URIs.",
#   output => {
#     encoding => "application/json",
#     schema   => {
#                   properties => {
#                     did   => { format => "did", type => "string" },
#                     feeds => { items => { ref => "#feed", type => "ref" }, type => "array" },
#                     links => { ref => "#links", type => "ref" },
#                   },
#                   required => ["did", "feeds"],
#                   type => "object",
#                 },
#   },
#   type => "query",
# }
  class At::Lexicon::app::bsky::feed::describeFeedGenerator::links {
    field $termsOfService :param = ();
    field $privacyPolicy :param = ();

    ADJUST{} # TODO: handle types such as string maxlen, etc.

    # perlclass does not have :reader yet
    method termsOfService{ $termsOfService };
    method privacyPolicy{ $privacyPolicy };

    method _raw() {{
        termsOfService => $termsOfService,
        privacyPolicy => $privacyPolicy,
    }}
  }
  class At::Lexicon::app::bsky::feed::describeFeedGenerator::feed {
    field $uri :param;

    ADJUST{} # TODO: handle types such as string maxlen, etc.

    # perlclass does not have :reader yet
    method uri{ $uri };

    method _raw() {{
        uri => $uri,
    }}
  }
# /home/s/Desktop/Projects/At.pm/eg/atproto/lexicons/app/bsky/feed/generator.json

   use v5.38;
    no warnings 'experimental::class', 'experimental::builtin';    # Be quiet.
    use feature 'class';
    use URI;

  class At::Lexicon::app::bsky::feed::generator {
    field $description :param = ();
    field $createdAt :param;
    field $avatar :param = ();
    field $descriptionFacets :param = ();
    field $displayName :param;
    field $did :param;
    field $labels :param = ();

    ADJUST{} # TODO: handle types such as string maxlen, etc.

    # perlclass does not have :reader yet
    method description{ $description };
    method createdAt{ $createdAt };
    method avatar{ $avatar };
    method descriptionFacets{ $descriptionFacets };
    method displayName{ $displayName };
    method did{ $did };
    method labels{ $labels };

    method _raw() {{
        description => $description,
        createdAt => $createdAt,
        avatar => $avatar,
        descriptionFacets => $descriptionFacets,
        displayName => $displayName,
        did => $did,
        labels => $labels,
    }}
# /home/s/Desktop/Projects/At.pm/eg/atproto/lexicons/app/bsky/feed/getActorFeeds.json

   use v5.38;
    no warnings 'experimental::class', 'experimental::builtin';    # Be quiet.
    use feature 'class';
    use URI;

# trash.pl:109: {
#   description => "Get a list of feeds created by the actor.",
#   output => {
#     encoding => "application/json",
#     schema   => {
#                   properties => {
#                     cursor => { type => "string" },
#                     feeds  => {
#                                 items => { ref => "app.bsky.feed.defs#generatorView", type => "ref" },
#                                 type  => "array",
#                               },
#                   },
#                   required => ["feeds"],
#                   type => "object",
#                 },
#   },
#   parameters => {
#     properties => {
#       actor  => { format => "at-identifier", type => "string" },
#       cursor => { type => "string" },
#       limit  => { default => 50, maximum => 100, minimum => 1, type => "integer" },
#     },
#     required => ["actor"],
#     type => "params",
#   },
#   type => "query",
# }
# /home/s/Desktop/Projects/At.pm/eg/atproto/lexicons/app/bsky/feed/getActorLikes.json

   use v5.38;
    no warnings 'experimental::class', 'experimental::builtin';    # Be quiet.
    use feature 'class';
    use URI;

# trash.pl:109: {
#   description => "Get a list of posts liked by an actor.",
#   errors => [{ name => "BlockedActor" }, { name => "BlockedByActor" }],
#   output => {
#     encoding => "application/json",
#     schema   => {
#                   properties => {
#                     cursor => { type => "string" },
#                     feed   => {
#                                 items => { ref => "app.bsky.feed.defs#feedViewPost", type => "ref" },
#                                 type  => "array",
#                               },
#                   },
#                   required => ["feed"],
#                   type => "object",
#                 },
#   },
#   parameters => {
#     properties => {
#       actor  => { format => "at-identifier", type => "string" },
#       cursor => { type => "string" },
#       limit  => { default => 50, maximum => 100, minimum => 1, type => "integer" },
#     },
#     required => ["actor"],
#     type => "params",
#   },
#   type => "query",
# }
# /home/s/Desktop/Projects/At.pm/eg/atproto/lexicons/app/bsky/feed/getAuthorFeed.json

   use v5.38;
    no warnings 'experimental::class', 'experimental::builtin';    # Be quiet.
    use feature 'class';
    use URI;

# trash.pl:109: {
#   description => "Get a view of an actor's feed.",
#   errors => [{ name => "BlockedActor" }, { name => "BlockedByActor" }],
#   output => {
#     encoding => "application/json",
#     schema   => {
#                   properties => {
#                     cursor => { type => "string" },
#                     feed   => {
#                                 items => { ref => "app.bsky.feed.defs#feedViewPost", type => "ref" },
#                                 type  => "array",
#                               },
#                   },
#                   required => ["feed"],
#                   type => "object",
#                 },
#   },
#   parameters => {
#     properties => {
#       actor  => { format => "at-identifier", type => "string" },
#       cursor => { type => "string" },
#       filter => {
#                   default => "posts_with_replies",
#                   knownValues => ["posts_with_replies", "posts_no_replies", "posts_with_media"],
#                   type => "string",
#                 },
#       limit  => { default => 50, maximum => 100, minimum => 1, type => "integer" },
#     },
#     required => ["actor"],
#     type => "params",
#   },
#   type => "query",
# }
# /home/s/Desktop/Projects/At.pm/eg/atproto/lexicons/app/bsky/feed/getFeed.json

   use v5.38;
    no warnings 'experimental::class', 'experimental::builtin';    # Be quiet.
    use feature 'class';
    use URI;

# trash.pl:109: {
#   description => "Get a hydrated feed from an actor's selected feed generator.",
#   errors => [{ name => "UnknownFeed" }],
#   output => {
#     encoding => "application/json",
#     schema   => {
#                   properties => {
#                     cursor => { type => "string" },
#                     feed   => {
#                                 items => { ref => "app.bsky.feed.defs#feedViewPost", type => "ref" },
#                                 type  => "array",
#                               },
#                   },
#                   required => ["feed"],
#                   type => "object",
#                 },
#   },
#   parameters => {
#     properties => {
#       cursor => { type => "string" },
#       feed   => { format => "at-uri", type => "string" },
#       limit  => { default => 50, maximum => 100, minimum => 1, type => "integer" },
#     },
#     required => ["feed"],
#     type => "params",
#   },
#   type => "query",
# }
# /home/s/Desktop/Projects/At.pm/eg/atproto/lexicons/app/bsky/feed/getFeedGenerator.json

   use v5.38;
    no warnings 'experimental::class', 'experimental::builtin';    # Be quiet.
    use feature 'class';
    use URI;

# trash.pl:109: {
#   description => "Get information about a feed generator.",
#   output => {
#     encoding => "application/json",
#     schema   => {
#                   properties => {
#                     isOnline => { type => "boolean" },
#                     isValid => { type => "boolean" },
#                     view => { ref => "app.bsky.feed.defs#generatorView", type => "ref" },
#                   },
#                   required => ["view", "isOnline", "isValid"],
#                   type => "object",
#                 },
#   },
#   parameters => {
#     properties => { feed => { format => "at-uri", type => "string" } },
#     required => ["feed"],
#     type => "params",
#   },
#   type => "query",
# }
# /home/s/Desktop/Projects/At.pm/eg/atproto/lexicons/app/bsky/feed/getFeedGenerators.json

   use v5.38;
    no warnings 'experimental::class', 'experimental::builtin';    # Be quiet.
    use feature 'class';
    use URI;

# trash.pl:109: {
#   description => "Get information about a list of feed generators.",
#   output => {
#     encoding => "application/json",
#     schema   => {
#                   properties => {
#                     feeds => {
#                       items => { ref => "app.bsky.feed.defs#generatorView", type => "ref" },
#                       type  => "array",
#                     },
#                   },
#                   required => ["feeds"],
#                   type => "object",
#                 },
#   },
#   parameters => {
#     properties => {
#       feeds => { items => { format => "at-uri", type => "string" }, type => "array" },
#     },
#     required => ["feeds"],
#     type => "params",
#   },
#   type => "query",
# }
# /home/s/Desktop/Projects/At.pm/eg/atproto/lexicons/app/bsky/feed/getFeedSkeleton.json

   use v5.38;
    no warnings 'experimental::class', 'experimental::builtin';    # Be quiet.
    use feature 'class';
    use URI;

# trash.pl:109: {
#   description => "Get a skeleton of a feed provided by a feed generator.",
#   errors => [{ name => "UnknownFeed" }],
#   output => {
#     encoding => "application/json",
#     schema   => {
#                   properties => {
#                     cursor => { type => "string" },
#                     feed   => {
#                                 items => { ref => "app.bsky.feed.defs#skeletonFeedPost", type => "ref" },
#                                 type  => "array",
#                               },
#                   },
#                   required => ["feed"],
#                   type => "object",
#                 },
#   },
#   parameters => {
#     properties => {
#       cursor => { type => "string" },
#       feed   => { format => "at-uri", type => "string" },
#       limit  => { default => 50, maximum => 100, minimum => 1, type => "integer" },
#     },
#     required => ["feed"],
#     type => "params",
#   },
#   type => "query",
# }
# /home/s/Desktop/Projects/At.pm/eg/atproto/lexicons/app/bsky/feed/getLikes.json

   use v5.38;
    no warnings 'experimental::class', 'experimental::builtin';    # Be quiet.
    use feature 'class';
    use URI;

# trash.pl:109: {
#   description => "Get the list of likes.",
#   output => {
#     encoding => "application/json",
#     schema   => {
#                   properties => {
#                     cid => { format => "cid", type => "string" },
#                     cursor => { type => "string" },
#                     likes => { items => { ref => "#like", type => "ref" }, type => "array" },
#                     uri => { format => "at-uri", type => "string" },
#                   },
#                   required => ["uri", "likes"],
#                   type => "object",
#                 },
#   },
#   parameters => {
#     properties => {
#       cid => { format => "cid", type => "string" },
#       cursor => { type => "string" },
#       limit => { default => 50, maximum => 100, minimum => 1, type => "integer" },
#       uri => { format => "at-uri", type => "string" },
#     },
#     required => ["uri"],
#     type => "params",
#   },
#   type => "query",
# }
  class At::Lexicon::app::bsky::feed::getLikes::like {
    field $createdAt :param;
    field $actor :param;
    field $indexedAt :param;

    ADJUST{} # TODO: handle types such as string maxlen, etc.

    # perlclass does not have :reader yet
    method createdAt{ $createdAt };
    method actor{ $actor };
    method indexedAt{ $indexedAt };

    method _raw() {{
        createdAt => $createdAt,
        actor => $actor,
        indexedAt => $indexedAt,
    }}
  }
# /home/s/Desktop/Projects/At.pm/eg/atproto/lexicons/app/bsky/feed/getListFeed.json

   use v5.38;
    no warnings 'experimental::class', 'experimental::builtin';    # Be quiet.
    use feature 'class';
    use URI;

# trash.pl:109: {
#   description => "Get a view of a recent posts from actors in a list.",
#   errors => [{ name => "UnknownList" }],
#   output => {
#     encoding => "application/json",
#     schema   => {
#                   properties => {
#                     cursor => { type => "string" },
#                     feed   => {
#                                 items => { ref => "app.bsky.feed.defs#feedViewPost", type => "ref" },
#                                 type  => "array",
#                               },
#                   },
#                   required => ["feed"],
#                   type => "object",
#                 },
#   },
#   parameters => {
#     properties => {
#       cursor => { type => "string" },
#       limit  => { default => 50, maximum => 100, minimum => 1, type => "integer" },
#       list   => { format => "at-uri", type => "string" },
#     },
#     required => ["list"],
#     type => "params",
#   },
#   type => "query",
# }
# /home/s/Desktop/Projects/At.pm/eg/atproto/lexicons/app/bsky/feed/getPostThread.json

   use v5.38;
    no warnings 'experimental::class', 'experimental::builtin';    # Be quiet.
    use feature 'class';
    use URI;

# trash.pl:109: {
#   description => "Get posts in a thread.",
#   errors => [{ name => "NotFound" }],
#   output => {
#     encoding => "application/json",
#     schema   => {
#                   properties => {
#                     thread => {
#                       refs => [
#                                 "app.bsky.feed.defs#threadViewPost",
#                                 "app.bsky.feed.defs#notFoundPost",
#                                 "app.bsky.feed.defs#blockedPost",
#                               ],
#                       type => "union",
#                     },
#                   },
#                   required => ["thread"],
#                   type => "object",
#                 },
#   },
#   parameters => {
#     properties => {
#       depth => { default => 6, maximum => 1000, minimum => 0, type => "integer" },
#       parentHeight => { default => 80, maximum => 1000, minimum => 0, type => "integer" },
#       uri => { format => "at-uri", type => "string" },
#     },
#     required => ["uri"],
#     type => "params",
#   },
#   type => "query",
# }
# /home/s/Desktop/Projects/At.pm/eg/atproto/lexicons/app/bsky/feed/getPosts.json

   use v5.38;
    no warnings 'experimental::class', 'experimental::builtin';    # Be quiet.
    use feature 'class';
    use URI;

# trash.pl:109: {
#   description => "Get a view of an actor's feed.",
#   output => {
#     encoding => "application/json",
#     schema   => {
#                   properties => {
#                     posts => {
#                       items => { ref => "app.bsky.feed.defs#postView", type => "ref" },
#                       type  => "array",
#                     },
#                   },
#                   required => ["posts"],
#                   type => "object",
#                 },
#   },
#   parameters => {
#     properties => {
#       uris => {
#         items => { format => "at-uri", type => "string" },
#         maxLength => 25,
#         type => "array",
#       },
#     },
#     required => ["uris"],
#     type => "params",
#   },
#   type => "query",
# }
# /home/s/Desktop/Projects/At.pm/eg/atproto/lexicons/app/bsky/feed/getRepostedBy.json

   use v5.38;
    no warnings 'experimental::class', 'experimental::builtin';    # Be quiet.
    use feature 'class';
    use URI;

# trash.pl:109: {
#   description => "Get a list of reposts.",
#   output => {
#     encoding => "application/json",
#     schema   => {
#                   properties => {
#                     cid => { format => "cid", type => "string" },
#                     cursor => { type => "string" },
#                     repostedBy => {
#                       items => { ref => "app.bsky.actor.defs#profileView", type => "ref" },
#                       type  => "array",
#                     },
#                     uri => { format => "at-uri", type => "string" },
#                   },
#                   required => ["uri", "repostedBy"],
#                   type => "object",
#                 },
#   },
#   parameters => {
#     properties => {
#       cid => { format => "cid", type => "string" },
#       cursor => { type => "string" },
#       limit => { default => 50, maximum => 100, minimum => 1, type => "integer" },
#       uri => { format => "at-uri", type => "string" },
#     },
#     required => ["uri"],
#     type => "params",
#   },
#   type => "query",
# }
# /home/s/Desktop/Projects/At.pm/eg/atproto/lexicons/app/bsky/feed/getSuggestedFeeds.json

   use v5.38;
    no warnings 'experimental::class', 'experimental::builtin';    # Be quiet.
    use feature 'class';
    use URI;

# trash.pl:109: {
#   description => "Get a list of suggested feeds for the viewer.",
#   output => {
#     encoding => "application/json",
#     schema   => {
#                   properties => {
#                     cursor => { type => "string" },
#                     feeds  => {
#                                 items => { ref => "app.bsky.feed.defs#generatorView", type => "ref" },
#                                 type  => "array",
#                               },
#                   },
#                   required => ["feeds"],
#                   type => "object",
#                 },
#   },
#   parameters => {
#     properties => {
#       cursor => { type => "string" },
#       limit  => { default => 50, maximum => 100, minimum => 1, type => "integer" },
#     },
#     type => "params",
#   },
#   type => "query",
# }
# /home/s/Desktop/Projects/At.pm/eg/atproto/lexicons/app/bsky/feed/getTimeline.json

   use v5.38;
    no warnings 'experimental::class', 'experimental::builtin';    # Be quiet.
    use feature 'class';
    use URI;

# trash.pl:109: {
#   description => "Get a view of the actor's home timeline.",
#   output => {
#     encoding => "application/json",
#     schema   => {
#                   properties => {
#                     cursor => { type => "string" },
#                     feed   => {
#                                 items => { ref => "app.bsky.feed.defs#feedViewPost", type => "ref" },
#                                 type  => "array",
#                               },
#                   },
#                   required => ["feed"],
#                   type => "object",
#                 },
#   },
#   parameters => {
#     properties => {
#       algorithm => { type => "string" },
#       cursor    => { type => "string" },
#       limit     => { default => 50, maximum => 100, minimum => 1, type => "integer" },
#     },
#     type => "params",
#   },
#   type => "query",
# }
# /home/s/Desktop/Projects/At.pm/eg/atproto/lexicons/app/bsky/feed/like.json

   use v5.38;
    no warnings 'experimental::class', 'experimental::builtin';    # Be quiet.
    use feature 'class';
    use URI;

  class At::Lexicon::app::bsky::feed::like {
    field $createdAt :param;
    field $subject :param;

    ADJUST{} # TODO: handle types such as string maxlen, etc.

    # perlclass does not have :reader yet
    method createdAt{ $createdAt };
    method subject{ $subject };

    method _raw() {{
        createdAt => $createdAt,
        subject => $subject,
    }}
# /home/s/Desktop/Projects/At.pm/eg/atproto/lexicons/app/bsky/feed/post.json

   use v5.38;
    no warnings 'experimental::class', 'experimental::builtin';    # Be quiet.
    use feature 'class';
    use URI;

  class At::Lexicon::app::bsky::feed::post::replyRef {
    field $root :param;
    field $parent :param;

    ADJUST{} # TODO: handle types such as string maxlen, etc.

    # perlclass does not have :reader yet
    method root{ $root };
    method parent{ $parent };

    method _raw() {{
        root => $root,
        parent => $parent,
    }}
  }
  class At::Lexicon::app::bsky::feed::post {
    field $tags :param = ();
    field $langs :param = ();
    field $createdAt :param;
    field $reply :param = ();
    field $facets :param = ();
    field $entities :param = ();
    field $embed :param = ();
    field $text :param;
    field $labels :param = ();

    ADJUST{} # TODO: handle types such as string maxlen, etc.

    # perlclass does not have :reader yet
    method tags{ $tags };
    method langs{ $langs };
    method createdAt{ $createdAt };
    method reply{ $reply };
    method facets{ $facets };
    method entities{ $entities };
    method embed{ $embed };
    method text{ $text };
    method labels{ $labels };

    method _raw() {{
        tags => $tags,
        langs => $langs,
        createdAt => $createdAt,
        reply => $reply,
        facets => $facets,
        entities => $entities,
        embed => $embed,
        text => $text,
        labels => $labels,
    }}
# /home/s/Desktop/Projects/At.pm/eg/atproto/lexicons/app/bsky/feed/repost.json

   use v5.38;
    no warnings 'experimental::class', 'experimental::builtin';    # Be quiet.
    use feature 'class';
    use URI;

  class At::Lexicon::app::bsky::feed::repost {
    field $subject :param;
    field $createdAt :param;

    ADJUST{} # TODO: handle types such as string maxlen, etc.

    # perlclass does not have :reader yet
    method subject{ $subject };
    method createdAt{ $createdAt };

    method _raw() {{
        subject => $subject,
        createdAt => $createdAt,
    }}
# /home/s/Desktop/Projects/At.pm/eg/atproto/lexicons/app/bsky/feed/searchPosts.json

   use v5.38;
    no warnings 'experimental::class', 'experimental::builtin';    # Be quiet.
    use feature 'class';
    use URI;

# trash.pl:109: {
#   description => "Find posts matching search criteria.",
#   errors => [{ name => "BadQueryString" }],
#   output => {
#     encoding => "application/json",
#     schema   => {
#                   properties => {
#                     cursor    => { type => "string" },
#                     hitsTotal => {
#                                    description => "Count of search hits. Optional, may be rounded/truncated, and may not be possible to paginate through all hits.",
#                                    type => "integer",
#                                  },
#                     posts     => {
#                                    items => { ref => "app.bsky.feed.defs#postView", type => "ref" },
#                                    type  => "array",
#                                  },
#                   },
#                   required => ["posts"],
#                   type => "object",
#                 },
#   },
#   parameters => {
#     properties => {
#       cursor => {
#         description => "Optional pagination mechanism; may not necessarily allow scrolling through entire result set.",
#         type => "string",
#       },
#       limit => { default => 25, maximum => 100, minimum => 1, type => "integer" },
#       q => {
#         description => "Search query string; syntax, phrase, boolean, and faceting is unspecified, but Lucene query syntax is recommended.",
#         type => "string",
#       },
#     },
#     required => ["q"],
#     type => "params",
#   },
#   type => "query",
# }
# /home/s/Desktop/Projects/At.pm/eg/atproto/lexicons/app/bsky/feed/threadgate.json

   use v5.38;
    no warnings 'experimental::class', 'experimental::builtin';    # Be quiet.
    use feature 'class';
    use URI;

  class At::Lexicon::app::bsky::feed::threadgate::followingRule {

    ADJUST{} # TODO: handle types such as string maxlen, etc.

    # perlclass does not have :reader yet

    method _raw() {{
    }}
  }
  class At::Lexicon::app::bsky::feed::threadgate::listRule {
    field $list :param;

    ADJUST{} # TODO: handle types such as string maxlen, etc.

    # perlclass does not have :reader yet
    method list{ $list };

    method _raw() {{
        list => $list,
    }}
  }
  class At::Lexicon::app::bsky::feed::threadgate {
    field $post :param;
    field $allow :param = ();
    field $createdAt :param;

    ADJUST{} # TODO: handle types such as string maxlen, etc.

    # perlclass does not have :reader yet
    method post{ $post };
    method allow{ $allow };
    method createdAt{ $createdAt };

    method _raw() {{
        post => $post,
        allow => $allow,
        createdAt => $createdAt,
    }}
  class At::Lexicon::app::bsky::feed::threadgate::mentionRule {

    ADJUST{} # TODO: handle types such as string maxlen, etc.

    # perlclass does not have :reader yet

    method _raw() {{
    }}
  }
# /home/s/Desktop/Projects/At.pm/eg/atproto/lexicons/app/bsky/graph/block.json

   use v5.38;
    no warnings 'experimental::class', 'experimental::builtin';    # Be quiet.
    use feature 'class';
    use URI;

  class At::Lexicon::app::bsky::graph::block {
    field $subject :param;
    field $createdAt :param;

    ADJUST{} # TODO: handle types such as string maxlen, etc.

    # perlclass does not have :reader yet
    method subject{ $subject };
    method createdAt{ $createdAt };

    method _raw() {{
        subject => $subject,
        createdAt => $createdAt,
    }}
# /home/s/Desktop/Projects/At.pm/eg/atproto/lexicons/app/bsky/graph/defs.json

   use v5.38;
    no warnings 'experimental::class', 'experimental::builtin';    # Be quiet.
    use feature 'class';
    use URI;

  class At::Lexicon::app::bsky::graph::defs::listView {
    field $cid :param;
    field $name :param;
    field $purpose :param;
    field $descriptionFacets :param = ();
    field $description :param = ();
    field $avatar :param = ();
    field $creator :param;
    field $uri :param;
    field $viewer :param = ();
    field $indexedAt :param;

    ADJUST{} # TODO: handle types such as string maxlen, etc.

    # perlclass does not have :reader yet
    method cid{ $cid };
    method name{ $name };
    method purpose{ $purpose };
    method descriptionFacets{ $descriptionFacets };
    method description{ $description };
    method avatar{ $avatar };
    method creator{ $creator };
    method uri{ $uri };
    method viewer{ $viewer };
    method indexedAt{ $indexedAt };

    method _raw() {{
        cid => $cid,
        name => $name,
        purpose => $purpose,
        descriptionFacets => $descriptionFacets,
        description => $description,
        avatar => $avatar,
        creator => $creator,
        uri => $uri,
        viewer => $viewer,
        indexedAt => $indexedAt,
    }}
  }
# trash.pl:109: {
#   knownValues => [
#     "app.bsky.graph.defs#modlist",
#     "app.bsky.graph.defs#curatelist",
#   ],
#   type => "string",
# }
# trash.pl:109: {
#   description => "A list of actors to apply an aggregate moderation action (mute/block) on.",
#   type => "token",
# }
  class At::Lexicon::app::bsky::graph::defs::listItemView {
    field $subject :param;

    ADJUST{} # TODO: handle types such as string maxlen, etc.

    # perlclass does not have :reader yet
    method subject{ $subject };

    method _raw() {{
        subject => $subject,
    }}
  }
  class At::Lexicon::app::bsky::graph::defs::listViewBasic {
    field $uri :param;
    field $viewer :param = ();
    field $indexedAt :param = ();
    field $cid :param;
    field $purpose :param;
    field $name :param;
    field $avatar :param = ();

    ADJUST{} # TODO: handle types such as string maxlen, etc.

    # perlclass does not have :reader yet
    method uri{ $uri };
    method viewer{ $viewer };
    method indexedAt{ $indexedAt };
    method cid{ $cid };
    method purpose{ $purpose };
    method name{ $name };
    method avatar{ $avatar };

    method _raw() {{
        uri => $uri,
        viewer => $viewer,
        indexedAt => $indexedAt,
        cid => $cid,
        purpose => $purpose,
        name => $name,
        avatar => $avatar,
    }}
  }
# trash.pl:109: {
#   description => "A list of actors used for curation purposes such as list feeds or interaction gating.",
#   type => "token",
# }
  class At::Lexicon::app::bsky::graph::defs::listViewerState {
    field $blocked :param = ();
    field $muted :param = ();

    ADJUST{} # TODO: handle types such as string maxlen, etc.

    # perlclass does not have :reader yet
    method blocked{ $blocked };
    method muted{ $muted };

    method _raw() {{
        blocked => $blocked,
        muted => $muted,
    }}
  }
# /home/s/Desktop/Projects/At.pm/eg/atproto/lexicons/app/bsky/graph/follow.json

   use v5.38;
    no warnings 'experimental::class', 'experimental::builtin';    # Be quiet.
    use feature 'class';
    use URI;

  class At::Lexicon::app::bsky::graph::follow {
    field $createdAt :param;
    field $subject :param;

    ADJUST{} # TODO: handle types such as string maxlen, etc.

    # perlclass does not have :reader yet
    method createdAt{ $createdAt };
    method subject{ $subject };

    method _raw() {{
        createdAt => $createdAt,
        subject => $subject,
    }}
# /home/s/Desktop/Projects/At.pm/eg/atproto/lexicons/app/bsky/graph/getBlocks.json

   use v5.38;
    no warnings 'experimental::class', 'experimental::builtin';    # Be quiet.
    use feature 'class';
    use URI;

# trash.pl:109: {
#   description => "Get a list of who the actor is blocking.",
#   output => {
#     encoding => "application/json",
#     schema   => {
#                   properties => {
#                     blocks => {
#                                 items => { ref => "app.bsky.actor.defs#profileView", type => "ref" },
#                                 type  => "array",
#                               },
#                     cursor => { type => "string" },
#                   },
#                   required => ["blocks"],
#                   type => "object",
#                 },
#   },
#   parameters => {
#     properties => {
#       cursor => { type => "string" },
#       limit  => { default => 50, maximum => 100, minimum => 1, type => "integer" },
#     },
#     type => "params",
#   },
#   type => "query",
# }
# /home/s/Desktop/Projects/At.pm/eg/atproto/lexicons/app/bsky/graph/getFollowers.json

   use v5.38;
    no warnings 'experimental::class', 'experimental::builtin';    # Be quiet.
    use feature 'class';
    use URI;

# trash.pl:109: {
#   description => "Get a list of an actor's followers.",
#   output => {
#     encoding => "application/json",
#     schema   => {
#                   properties => {
#                     cursor    => { type => "string" },
#                     followers => {
#                                    items => { ref => "app.bsky.actor.defs#profileView", type => "ref" },
#                                    type  => "array",
#                                  },
#                     subject   => { ref => "app.bsky.actor.defs#profileView", type => "ref" },
#                   },
#                   required => ["subject", "followers"],
#                   type => "object",
#                 },
#   },
#   parameters => {
#     properties => {
#       actor  => { format => "at-identifier", type => "string" },
#       cursor => { type => "string" },
#       limit  => { default => 50, maximum => 100, minimum => 1, type => "integer" },
#     },
#     required => ["actor"],
#     type => "params",
#   },
#   type => "query",
# }
# /home/s/Desktop/Projects/At.pm/eg/atproto/lexicons/app/bsky/graph/getFollows.json

   use v5.38;
    no warnings 'experimental::class', 'experimental::builtin';    # Be quiet.
    use feature 'class';
    use URI;

# trash.pl:109: {
#   description => "Get a list of who the actor follows.",
#   output => {
#     encoding => "application/json",
#     schema   => {
#                   properties => {
#                     cursor  => { type => "string" },
#                     follows => {
#                                  items => { ref => "app.bsky.actor.defs#profileView", type => "ref" },
#                                  type  => "array",
#                                },
#                     subject => { ref => "app.bsky.actor.defs#profileView", type => "ref" },
#                   },
#                   required => ["subject", "follows"],
#                   type => "object",
#                 },
#   },
#   parameters => {
#     properties => {
#       actor  => { format => "at-identifier", type => "string" },
#       cursor => { type => "string" },
#       limit  => { default => 50, maximum => 100, minimum => 1, type => "integer" },
#     },
#     required => ["actor"],
#     type => "params",
#   },
#   type => "query",
# }
# /home/s/Desktop/Projects/At.pm/eg/atproto/lexicons/app/bsky/graph/getList.json

   use v5.38;
    no warnings 'experimental::class', 'experimental::builtin';    # Be quiet.
    use feature 'class';
    use URI;

# trash.pl:109: {
#   description => "Get a list of actors.",
#   output => {
#     encoding => "application/json",
#     schema   => {
#                   properties => {
#                     cursor => { type => "string" },
#                     items  => {
#                                 items => { ref => "app.bsky.graph.defs#listItemView", type => "ref" },
#                                 type  => "array",
#                               },
#                     list   => { ref => "app.bsky.graph.defs#listView", type => "ref" },
#                   },
#                   required => ["list", "items"],
#                   type => "object",
#                 },
#   },
#   parameters => {
#     properties => {
#       cursor => { type => "string" },
#       limit  => { default => 50, maximum => 100, minimum => 1, type => "integer" },
#       list   => { format => "at-uri", type => "string" },
#     },
#     required => ["list"],
#     type => "params",
#   },
#   type => "query",
# }
# /home/s/Desktop/Projects/At.pm/eg/atproto/lexicons/app/bsky/graph/getListBlocks.json

   use v5.38;
    no warnings 'experimental::class', 'experimental::builtin';    # Be quiet.
    use feature 'class';
    use URI;

# trash.pl:109: {
#   description => "Get lists that the actor is blocking.",
#   output => {
#     encoding => "application/json",
#     schema   => {
#                   properties => {
#                     cursor => { type => "string" },
#                     lists  => {
#                                 items => { ref => "app.bsky.graph.defs#listView", type => "ref" },
#                                 type  => "array",
#                               },
#                   },
#                   required => ["lists"],
#                   type => "object",
#                 },
#   },
#   parameters => {
#     properties => {
#       cursor => { type => "string" },
#       limit  => { default => 50, maximum => 100, minimum => 1, type => "integer" },
#     },
#     type => "params",
#   },
#   type => "query",
# }
# /home/s/Desktop/Projects/At.pm/eg/atproto/lexicons/app/bsky/graph/getListMutes.json

   use v5.38;
    no warnings 'experimental::class', 'experimental::builtin';    # Be quiet.
    use feature 'class';
    use URI;

# trash.pl:109: {
#   description => "Get lists that the actor is muting.",
#   output => {
#     encoding => "application/json",
#     schema   => {
#                   properties => {
#                     cursor => { type => "string" },
#                     lists  => {
#                                 items => { ref => "app.bsky.graph.defs#listView", type => "ref" },
#                                 type  => "array",
#                               },
#                   },
#                   required => ["lists"],
#                   type => "object",
#                 },
#   },
#   parameters => {
#     properties => {
#       cursor => { type => "string" },
#       limit  => { default => 50, maximum => 100, minimum => 1, type => "integer" },
#     },
#     type => "params",
#   },
#   type => "query",
# }
# /home/s/Desktop/Projects/At.pm/eg/atproto/lexicons/app/bsky/graph/getLists.json

   use v5.38;
    no warnings 'experimental::class', 'experimental::builtin';    # Be quiet.
    use feature 'class';
    use URI;

# trash.pl:109: {
#   description => "Get a list of lists that belong to an actor.",
#   output => {
#     encoding => "application/json",
#     schema   => {
#                   properties => {
#                     cursor => { type => "string" },
#                     lists  => {
#                                 items => { ref => "app.bsky.graph.defs#listView", type => "ref" },
#                                 type  => "array",
#                               },
#                   },
#                   required => ["lists"],
#                   type => "object",
#                 },
#   },
#   parameters => {
#     properties => {
#       actor  => { format => "at-identifier", type => "string" },
#       cursor => { type => "string" },
#       limit  => { default => 50, maximum => 100, minimum => 1, type => "integer" },
#     },
#     required => ["actor"],
#     type => "params",
#   },
#   type => "query",
# }
# /home/s/Desktop/Projects/At.pm/eg/atproto/lexicons/app/bsky/graph/getMutes.json

   use v5.38;
    no warnings 'experimental::class', 'experimental::builtin';    # Be quiet.
    use feature 'class';
    use URI;

# trash.pl:109: {
#   description => "Get a list of who the actor mutes.",
#   output => {
#     encoding => "application/json",
#     schema   => {
#                   properties => {
#                     cursor => { type => "string" },
#                     mutes  => {
#                                 items => { ref => "app.bsky.actor.defs#profileView", type => "ref" },
#                                 type  => "array",
#                               },
#                   },
#                   required => ["mutes"],
#                   type => "object",
#                 },
#   },
#   parameters => {
#     properties => {
#       cursor => { type => "string" },
#       limit  => { default => 50, maximum => 100, minimum => 1, type => "integer" },
#     },
#     type => "params",
#   },
#   type => "query",
# }
# /home/s/Desktop/Projects/At.pm/eg/atproto/lexicons/app/bsky/graph/getSuggestedFollowsByActor.json

   use v5.38;
    no warnings 'experimental::class', 'experimental::builtin';    # Be quiet.
    use feature 'class';
    use URI;

# trash.pl:109: {
#   description => "Get suggested follows related to a given actor.",
#   output => {
#     encoding => "application/json",
#     schema   => {
#                   properties => {
#                     suggestions => {
#                       items => { ref => "app.bsky.actor.defs#profileView", type => "ref" },
#                       type  => "array",
#                     },
#                   },
#                   required => ["suggestions"],
#                   type => "object",
#                 },
#   },
#   parameters => {
#     properties => { actor => { format => "at-identifier", type => "string" } },
#     required => ["actor"],
#     type => "params",
#   },
#   type => "query",
# }
# /home/s/Desktop/Projects/At.pm/eg/atproto/lexicons/app/bsky/graph/list.json

   use v5.38;
    no warnings 'experimental::class', 'experimental::builtin';    # Be quiet.
    use feature 'class';
    use URI;

  class At::Lexicon::app::bsky::graph::list {
    field $labels :param = ();
    field $descriptionFacets :param = ();
    field $purpose :param;
    field $name :param;
    field $avatar :param = ();
    field $createdAt :param;
    field $description :param = ();

    ADJUST{} # TODO: handle types such as string maxlen, etc.

    # perlclass does not have :reader yet
    method labels{ $labels };
    method descriptionFacets{ $descriptionFacets };
    method purpose{ $purpose };
    method name{ $name };
    method avatar{ $avatar };
    method createdAt{ $createdAt };
    method description{ $description };

    method _raw() {{
        labels => $labels,
        descriptionFacets => $descriptionFacets,
        purpose => $purpose,
        name => $name,
        avatar => $avatar,
        createdAt => $createdAt,
        description => $description,
    }}
# /home/s/Desktop/Projects/At.pm/eg/atproto/lexicons/app/bsky/graph/listblock.json

   use v5.38;
    no warnings 'experimental::class', 'experimental::builtin';    # Be quiet.
    use feature 'class';
    use URI;

  class At::Lexicon::app::bsky::graph::listblock {
    field $subject :param;
    field $createdAt :param;

    ADJUST{} # TODO: handle types such as string maxlen, etc.

    # perlclass does not have :reader yet
    method subject{ $subject };
    method createdAt{ $createdAt };

    method _raw() {{
        subject => $subject,
        createdAt => $createdAt,
    }}
# /home/s/Desktop/Projects/At.pm/eg/atproto/lexicons/app/bsky/graph/listitem.json

   use v5.38;
    no warnings 'experimental::class', 'experimental::builtin';    # Be quiet.
    use feature 'class';
    use URI;

  class At::Lexicon::app::bsky::graph::listitem {
    field $list :param;
    field $subject :param;
    field $createdAt :param;

    ADJUST{} # TODO: handle types such as string maxlen, etc.

    # perlclass does not have :reader yet
    method list{ $list };
    method subject{ $subject };
    method createdAt{ $createdAt };

    method _raw() {{
        list => $list,
        subject => $subject,
        createdAt => $createdAt,
    }}
# /home/s/Desktop/Projects/At.pm/eg/atproto/lexicons/app/bsky/graph/muteActor.json

   use v5.38;
    no warnings 'experimental::class', 'experimental::builtin';    # Be quiet.
    use feature 'class';
    use URI;

  method muteActor (%args){
    use Carp qw[confess];
    $client->http->session // confess 'creating a post requires an authenticated client';
# trash.pl:52: {
#   description => "Mute an actor by DID or handle.",
#   input => {
#     encoding => "application/json",
#     schema   => {
#                   properties => { actor => { format => "at-identifier", type => "string" } },
#                   required => ["actor"],
#                   type => "object",
#                 },
#   },
#   type => "procedure",
# }
    confess $_ . ' is a required parameter' for 'actor';
    my $res = $client->http->post( sprintf( '%s/xrpc/%s', $client->host(), 'app.bsky.graph.muteActor' )
      { content => \%args }
    );
    $res->{uri} = URI->new( $res->{uri} ) if defined $res->{uri};
    $res;
  }
# /home/s/Desktop/Projects/At.pm/eg/atproto/lexicons/app/bsky/graph/muteActorList.json

   use v5.38;
    no warnings 'experimental::class', 'experimental::builtin';    # Be quiet.
    use feature 'class';
    use URI;

  method muteActorList (%args){
    use Carp qw[confess];
    $client->http->session // confess 'creating a post requires an authenticated client';
# trash.pl:52: {
#   description => "Mute a list of actors.",
#   input => {
#     encoding => "application/json",
#     schema   => {
#                   properties => { list => { format => "at-uri", type => "string" } },
#                   required => ["list"],
#                   type => "object",
#                 },
#   },
#   type => "procedure",
# }
    confess $_ . ' is a required parameter' for 'list';
    my $res = $client->http->post( sprintf( '%s/xrpc/%s', $client->host(), 'app.bsky.graph.muteActorList' )
      { content => \%args }
    );
    $res->{uri} = URI->new( $res->{uri} ) if defined $res->{uri};
    $res;
  }
# /home/s/Desktop/Projects/At.pm/eg/atproto/lexicons/app/bsky/graph/unmuteActor.json

   use v5.38;
    no warnings 'experimental::class', 'experimental::builtin';    # Be quiet.
    use feature 'class';
    use URI;

  method unmuteActor (%args){
    use Carp qw[confess];
    $client->http->session // confess 'creating a post requires an authenticated client';
# trash.pl:52: {
#   description => "Unmute an actor by DID or handle.",
#   input => {
#     encoding => "application/json",
#     schema   => {
#                   properties => { actor => { format => "at-identifier", type => "string" } },
#                   required => ["actor"],
#                   type => "object",
#                 },
#   },
#   type => "procedure",
# }
    confess $_ . ' is a required parameter' for 'actor';
    my $res = $client->http->post( sprintf( '%s/xrpc/%s', $client->host(), 'app.bsky.graph.unmuteActor' )
      { content => \%args }
    );
    $res->{uri} = URI->new( $res->{uri} ) if defined $res->{uri};
    $res;
  }
# /home/s/Desktop/Projects/At.pm/eg/atproto/lexicons/app/bsky/graph/unmuteActorList.json

   use v5.38;
    no warnings 'experimental::class', 'experimental::builtin';    # Be quiet.
    use feature 'class';
    use URI;

  method unmuteActorList (%args){
    use Carp qw[confess];
    $client->http->session // confess 'creating a post requires an authenticated client';
# trash.pl:52: {
#   description => "Unmute a list of actors.",
#   input => {
#     encoding => "application/json",
#     schema   => {
#                   properties => { list => { format => "at-uri", type => "string" } },
#                   required => ["list"],
#                   type => "object",
#                 },
#   },
#   type => "procedure",
# }
    confess $_ . ' is a required parameter' for 'list';
    my $res = $client->http->post( sprintf( '%s/xrpc/%s', $client->host(), 'app.bsky.graph.unmuteActorList' )
      { content => \%args }
    );
    $res->{uri} = URI->new( $res->{uri} ) if defined $res->{uri};
    $res;
  }
# /home/s/Desktop/Projects/At.pm/eg/atproto/lexicons/app/bsky/notification/getUnreadCount.json

   use v5.38;
    no warnings 'experimental::class', 'experimental::builtin';    # Be quiet.
    use feature 'class';
    use URI;

# trash.pl:109: {
#   description => "Get the count of unread notifications.",
#   output => {
#     encoding => "application/json",
#     schema   => {
#                   properties => { count => { type => "integer" } },
#                   required => ["count"],
#                   type => "object",
#                 },
#   },
#   parameters => {
#     properties => { seenAt => { format => "datetime", type => "string" } },
#     type => "params",
#   },
#   type => "query",
# }
# /home/s/Desktop/Projects/At.pm/eg/atproto/lexicons/app/bsky/notification/listNotifications.json

   use v5.38;
    no warnings 'experimental::class', 'experimental::builtin';    # Be quiet.
    use feature 'class';
    use URI;

  class At::Lexicon::app::bsky::notification::listNotifications::notification {
    field $record :param;
    field $indexedAt :param;
    field $labels :param = ();
    field $uri :param;
    field $author :param;
    field $reasonSubject :param = ();
    field $isRead :param;
    field $cid :param;
    field $reason :param;

    ADJUST{} # TODO: handle types such as string maxlen, etc.

    # perlclass does not have :reader yet
    method record{ $record };
    method indexedAt{ $indexedAt };
    method labels{ $labels };
    method uri{ $uri };
    method author{ $author };
    method reasonSubject{ $reasonSubject };
    method isRead{ $isRead };
    method cid{ $cid };
    method reason{ $reason };

    method _raw() {{
        record => $record,
        indexedAt => $indexedAt,
        labels => $labels,
        uri => $uri,
        author => $author,
        reasonSubject => $reasonSubject,
        isRead => $isRead,
        cid => $cid,
        reason => $reason,
    }}
  }
# trash.pl:109: {
#   description => "Get a list of notifications.",
#   output => {
#     encoding => "application/json",
#     schema   => {
#                   properties => {
#                     cursor => { type => "string" },
#                     notifications => { items => { ref => "#notification", type => "ref" }, type => "array" },
#                   },
#                   required => ["notifications"],
#                   type => "object",
#                 },
#   },
#   parameters => {
#     properties => {
#       cursor => { type => "string" },
#       limit  => { default => 50, maximum => 100, minimum => 1, type => "integer" },
#       seenAt => { format => "datetime", type => "string" },
#     },
#     type => "params",
#   },
#   type => "query",
# }
# /home/s/Desktop/Projects/At.pm/eg/atproto/lexicons/app/bsky/notification/registerPush.json

   use v5.38;
    no warnings 'experimental::class', 'experimental::builtin';    # Be quiet.
    use feature 'class';
    use URI;

  method registerPush (%args){
    use Carp qw[confess];
    $client->http->session // confess 'creating a post requires an authenticated client';
# trash.pl:52: {
#   description => "Register for push notifications with a service.",
#   input => {
#     encoding => "application/json",
#     schema   => {
#                   properties => {
#                     appId      => { type => "string" },
#                     platform   => { knownValues => ["ios", "android", "web"], type => "string" },
#                     serviceDid => { format => "did", type => "string" },
#                     token      => { type => "string" },
#                   },
#                   required => ["serviceDid", "token", "platform", "appId"],
#                   type => "object",
#                 },
#   },
#   type => "procedure",
# }
    confess $_ . ' is a required parameter' for 'serviceDid', 'token', 'platform', 'appId';
    my $res = $client->http->post( sprintf( '%s/xrpc/%s', $client->host(), 'app.bsky.notification.registerPush' )
      { content => \%args }
    );
    $res->{uri} = URI->new( $res->{uri} ) if defined $res->{uri};
    $res;
  }
# /home/s/Desktop/Projects/At.pm/eg/atproto/lexicons/app/bsky/notification/updateSeen.json

   use v5.38;
    no warnings 'experimental::class', 'experimental::builtin';    # Be quiet.
    use feature 'class';
    use URI;

  method updateSeen (%args){
    use Carp qw[confess];
    $client->http->session // confess 'creating a post requires an authenticated client';
# trash.pl:52: {
#   description => "Notify server that the user has seen notifications.",
#   input => {
#     encoding => "application/json",
#     schema   => {
#                   properties => { seenAt => { format => "datetime", type => "string" } },
#                   required => ["seenAt"],
#                   type => "object",
#                 },
#   },
#   type => "procedure",
# }
    confess $_ . ' is a required parameter' for 'seenAt';
    my $res = $client->http->post( sprintf( '%s/xrpc/%s', $client->host(), 'app.bsky.notification.updateSeen' )
      { content => \%args }
    );
    $res->{uri} = URI->new( $res->{uri} ) if defined $res->{uri};
    $res;
  }
# /home/s/Desktop/Projects/At.pm/eg/atproto/lexicons/app/bsky/richtext/facet.json

   use v5.38;
    no warnings 'experimental::class', 'experimental::builtin';    # Be quiet.
    use feature 'class';
    use URI;

  class At::Lexicon::app::bsky::richtext::facet::main {
    field $features :param;
    field $index :param;

    ADJUST{} # TODO: handle types such as string maxlen, etc.

    # perlclass does not have :reader yet
    method features{ $features };
    method index{ $index };

    method _raw() {{
        features => $features,
        index => $index,
    }}
  }
  class At::Lexicon::app::bsky::richtext::facet::mention {
    field $did :param;

    ADJUST{} # TODO: handle types such as string maxlen, etc.

    # perlclass does not have :reader yet
    method did{ $did };

    method _raw() {{
        did => $did,
    }}
  }
  class At::Lexicon::app::bsky::richtext::facet::link {
    field $uri :param;

    ADJUST{} # TODO: handle types such as string maxlen, etc.

    # perlclass does not have :reader yet
    method uri{ $uri };

    method _raw() {{
        uri => $uri,
    }}
  }
  class At::Lexicon::app::bsky::richtext::facet::byteSlice {
    field $byteStart :param;
    field $byteEnd :param;

    ADJUST{} # TODO: handle types such as string maxlen, etc.

    # perlclass does not have :reader yet
    method byteStart{ $byteStart };
    method byteEnd{ $byteEnd };

    method _raw() {{
        byteStart => $byteStart,
        byteEnd => $byteEnd,
    }}
  }
  class At::Lexicon::app::bsky::richtext::facet::tag {
    field $tag :param;

    ADJUST{} # TODO: handle types such as string maxlen, etc.

    # perlclass does not have :reader yet
    method tag{ $tag };

    method _raw() {{
        tag => $tag,
    }}
  }
# /home/s/Desktop/Projects/At.pm/eg/atproto/lexicons/app/bsky/unspecced/defs.json

   use v5.38;
    no warnings 'experimental::class', 'experimental::builtin';    # Be quiet.
    use feature 'class';
    use URI;

  class At::Lexicon::app::bsky::unspecced::defs::skeletonSearchPost {
    field $uri :param;

    ADJUST{} # TODO: handle types such as string maxlen, etc.

    # perlclass does not have :reader yet
    method uri{ $uri };

    method _raw() {{
        uri => $uri,
    }}
  }
  class At::Lexicon::app::bsky::unspecced::defs::skeletonSearchActor {
    field $did :param;

    ADJUST{} # TODO: handle types such as string maxlen, etc.

    # perlclass does not have :reader yet
    method did{ $did };

    method _raw() {{
        did => $did,
    }}
  }
# /home/s/Desktop/Projects/At.pm/eg/atproto/lexicons/app/bsky/unspecced/getPopular.json

   use v5.38;
    no warnings 'experimental::class', 'experimental::builtin';    # Be quiet.
    use feature 'class';
    use URI;

# trash.pl:109: {
#   description => "DEPRECATED: will be removed soon. Use a feed generator alternative.",
#   output => {
#     encoding => "application/json",
#     schema   => {
#                   properties => {
#                     cursor => { type => "string" },
#                     feed   => {
#                                 items => { ref => "app.bsky.feed.defs#feedViewPost", type => "ref" },
#                                 type  => "array",
#                               },
#                   },
#                   required => ["feed"],
#                   type => "object",
#                 },
#   },
#   parameters => {
#     properties => {
#       cursor => { type => "string" },
#       includeNsfw => {
#         default => bless(do{\(my $o = 0)}, "JSON::Tiny::_Bool"),
#         type => "boolean",
#       },
#       limit => { default => 50, maximum => 100, minimum => 1, type => "integer" },
#     },
#     type => "params",
#   },
#   type => "query",
# }
# /home/s/Desktop/Projects/At.pm/eg/atproto/lexicons/app/bsky/unspecced/getPopularFeedGenerators.json

   use v5.38;
    no warnings 'experimental::class', 'experimental::builtin';    # Be quiet.
    use feature 'class';
    use URI;

# trash.pl:109: {
#   description => "An unspecced view of globally popular feed generators.",
#   output => {
#     encoding => "application/json",
#     schema   => {
#                   properties => {
#                     cursor => { type => "string" },
#                     feeds  => {
#                                 items => { ref => "app.bsky.feed.defs#generatorView", type => "ref" },
#                                 type  => "array",
#                               },
#                   },
#                   required => ["feeds"],
#                   type => "object",
#                 },
#   },
#   parameters => {
#     properties => {
#       cursor => { type => "string" },
#       limit  => { default => 50, maximum => 100, minimum => 1, type => "integer" },
#       query  => { type => "string" },
#     },
#     type => "params",
#   },
#   type => "query",
# }
# /home/s/Desktop/Projects/At.pm/eg/atproto/lexicons/app/bsky/unspecced/getTimelineSkeleton.json

   use v5.38;
    no warnings 'experimental::class', 'experimental::builtin';    # Be quiet.
    use feature 'class';
    use URI;

# trash.pl:109: {
#   description => "DEPRECATED: a skeleton of a timeline. Unspecced and will be unavailable soon.",
#   errors => [{ name => "UnknownFeed" }],
#   output => {
#     encoding => "application/json",
#     schema   => {
#                   properties => {
#                     cursor => { type => "string" },
#                     feed   => {
#                                 items => { ref => "app.bsky.feed.defs#skeletonFeedPost", type => "ref" },
#                                 type  => "array",
#                               },
#                   },
#                   required => ["feed"],
#                   type => "object",
#                 },
#   },
#   parameters => {
#     properties => {
#       cursor => { type => "string" },
#       limit  => { default => 50, maximum => 100, minimum => 1, type => "integer" },
#     },
#     type => "params",
#   },
#   type => "query",
# }
# /home/s/Desktop/Projects/At.pm/eg/atproto/lexicons/app/bsky/unspecced/searchActorsSkeleton.json

   use v5.38;
    no warnings 'experimental::class', 'experimental::builtin';    # Be quiet.
    use feature 'class';
    use URI;

# trash.pl:109: {
#   description => "Backend Actors (profile) search, returns only skeleton.",
#   errors => [{ name => "BadQueryString" }],
#   output => {
#     encoding => "application/json",
#     schema   => {
#                   properties => {
#                     actors    => {
#                                    items => { ref => "app.bsky.unspecced.defs#skeletonSearchActor", type => "ref" },
#                                    type  => "array",
#                                  },
#                     cursor    => { type => "string" },
#                     hitsTotal => {
#                                    description => "Count of search hits. Optional, may be rounded/truncated, and may not be possible to paginate through all hits.",
#                                    type => "integer",
#                                  },
#                   },
#                   required => ["actors"],
#                   type => "object",
#                 },
#   },
#   parameters => {
#     properties => {
#       cursor => {
#         description => "Optional pagination mechanism; may not necessarily allow scrolling through entire result set.",
#         type => "string",
#       },
#       limit => { default => 25, maximum => 100, minimum => 1, type => "integer" },
#       q => {
#         description => "Search query string; syntax, phrase, boolean, and faceting is unspecified, but Lucene query syntax is recommended. For typeahead search, only simple term match is supported, not full syntax.",
#         type => "string",
#       },
#       typeahead => {
#         description => "If true, acts as fast/simple 'typeahead' query.",
#         type => "boolean",
#       },
#     },
#     required => ["q"],
#     type => "params",
#   },
#   type => "query",
# }
# /home/s/Desktop/Projects/At.pm/eg/atproto/lexicons/app/bsky/unspecced/searchPostsSkeleton.json

   use v5.38;
    no warnings 'experimental::class', 'experimental::builtin';    # Be quiet.
    use feature 'class';
    use URI;

# trash.pl:109: {
#   description => "Backend Posts search, returns only skeleton",
#   errors => [{ name => "BadQueryString" }],
#   output => {
#     encoding => "application/json",
#     schema   => {
#                   properties => {
#                     cursor    => { type => "string" },
#                     hitsTotal => {
#                                    description => "Count of search hits. Optional, may be rounded/truncated, and may not be possible to paginate through all hits.",
#                                    type => "integer",
#                                  },
#                     posts     => {
#                                    items => { ref => "app.bsky.unspecced.defs#skeletonSearchPost", type => "ref" },
#                                    type  => "array",
#                                  },
#                   },
#                   required => ["posts"],
#                   type => "object",
#                 },
#   },
#   parameters => {
#     properties => {
#       cursor => {
#         description => "Optional pagination mechanism; may not necessarily allow scrolling through entire result set.",
#         type => "string",
#       },
#       limit => { default => 25, maximum => 100, minimum => 1, type => "integer" },
#       q => {
#         description => "Search query string; syntax, phrase, boolean, and faceting is unspecified, but Lucene query syntax is recommended.",
#         type => "string",
#       },
#     },
#     required => ["q"],
#     type => "params",
#   },
#   type => "query",
# }
# /home/s/Desktop/Projects/At.pm/eg/atproto/lexicons/com/atproto/admin/defs.json

   use v5.38;
    no warnings 'experimental::class', 'experimental::builtin';    # Be quiet.
    use feature 'class';
    use URI;

  class At::Lexicon::com::atproto::admin::defs::reportView {
    field $subject :param;
    field $reasonType :param;
    field $id :param;
    field $reportedBy :param;
    field $reason :param = ();
    field $createdAt :param;
    field $subjectRepoHandle :param = ();
    field $resolvedByActionIds :param;

    ADJUST{} # TODO: handle types such as string maxlen, etc.

    # perlclass does not have :reader yet
    method subject{ $subject };
    method reasonType{ $reasonType };
    method id{ $id };
    method reportedBy{ $reportedBy };
    method reason{ $reason };
    method createdAt{ $createdAt };
    method subjectRepoHandle{ $subjectRepoHandle };
    method resolvedByActionIds{ $resolvedByActionIds };

    method _raw() {{
        subject => $subject,
        reasonType => $reasonType,
        id => $id,
        reportedBy => $reportedBy,
        reason => $reason,
        createdAt => $createdAt,
        subjectRepoHandle => $subjectRepoHandle,
        resolvedByActionIds => $resolvedByActionIds,
    }}
  }
  class At::Lexicon::com::atproto::admin::defs::videoDetails {
    field $length :param;
    field $height :param;
    field $width :param;

    ADJUST{} # TODO: handle types such as string maxlen, etc.

    # perlclass does not have :reader yet
    method length{ $length };
    method height{ $height };
    method width{ $width };

    method _raw() {{
        length => $length,
        height => $height,
        width => $width,
    }}
  }
  class At::Lexicon::com::atproto::admin::defs::recordViewDetail {
    field $labels :param = ();
    field $uri :param;
    field $moderation :param;
    field $value :param;
    field $indexedAt :param;
    field $cid :param;
    field $blobs :param;
    field $repo :param;

    ADJUST{} # TODO: handle types such as string maxlen, etc.

    # perlclass does not have :reader yet
    method labels{ $labels };
    method uri{ $uri };
    method moderation{ $moderation };
    method value{ $value };
    method indexedAt{ $indexedAt };
    method cid{ $cid };
    method blobs{ $blobs };
    method repo{ $repo };

    method _raw() {{
        labels => $labels,
        uri => $uri,
        moderation => $moderation,
        value => $value,
        indexedAt => $indexedAt,
        cid => $cid,
        blobs => $blobs,
        repo => $repo,
    }}
  }
# trash.pl:109: {
#   description => "Moderation action type: Takedown. Indicates that content should not be served by the PDS.",
#   type => "token",
# }
  class At::Lexicon::com::atproto::admin::defs::moderationDetail {
    field $reports :param;
    field $currentAction :param = ();
    field $actions :param;

    ADJUST{} # TODO: handle types such as string maxlen, etc.

    # perlclass does not have :reader yet
    method reports{ $reports };
    method currentAction{ $currentAction };
    method actions{ $actions };

    method _raw() {{
        reports => $reports,
        currentAction => $currentAction,
        actions => $actions,
    }}
  }
  class At::Lexicon::com::atproto::admin::defs::recordViewNotFound {
    field $uri :param;

    ADJUST{} # TODO: handle types such as string maxlen, etc.

    # perlclass does not have :reader yet
    method uri{ $uri };

    method _raw() {{
        uri => $uri,
    }}
  }
  class At::Lexicon::com::atproto::admin::defs::actionView {
    field $id :param;
    field $subject :param;
    field $reversal :param = ();
    field $createdAt :param;
    field $createLabelVals :param = ();
    field $subjectBlobCids :param;
    field $durationInHours :param = ();
    field $action :param;
    field $resolvedReportIds :param;
    field $reason :param;
    field $createdBy :param;
    field $negateLabelVals :param = ();

    ADJUST{} # TODO: handle types such as string maxlen, etc.

    # perlclass does not have :reader yet
    method id{ $id };
    method subject{ $subject };
    method reversal{ $reversal };
    method createdAt{ $createdAt };
    method createLabelVals{ $createLabelVals };
    method subjectBlobCids{ $subjectBlobCids };
    method durationInHours{ $durationInHours };
    method action{ $action };
    method resolvedReportIds{ $resolvedReportIds };
    method reason{ $reason };
    method createdBy{ $createdBy };
    method negateLabelVals{ $negateLabelVals };

    method _raw() {{
        id => $id,
        subject => $subject,
        reversal => $reversal,
        createdAt => $createdAt,
        createLabelVals => $createLabelVals,
        subjectBlobCids => $subjectBlobCids,
        durationInHours => $durationInHours,
        action => $action,
        resolvedReportIds => $resolvedReportIds,
        reason => $reason,
        createdBy => $createdBy,
        negateLabelVals => $negateLabelVals,
    }}
  }
  class At::Lexicon::com::atproto::admin::defs::statusAttr {
    field $applied :param;
    field $ref :param = ();

    ADJUST{} # TODO: handle types such as string maxlen, etc.

    # perlclass does not have :reader yet
    method applied{ $applied };
    method ref{ $ref };

    method _raw() {{
        applied => $applied,
        ref => $ref,
    }}
  }
  __END__
  class At::Lexicon::com::atproto::admin::defs::imageDetails {
    field $height :param;
    field $width :param;

    ADJUST{} # TODO: handle types such as string maxlen, etc.

    # perlclass does not have :reader yet
    method height{ $height };
    method width{ $width };

    method _raw() {{
        height => $height,
        width => $width,
    }}
  }
  class At::Lexicon::com::atproto::admin::defs::actionViewDetail {
    field $action :param;
    field $resolvedReports :param;
    field $reason :param;
    field $createdAt :param;
    field $durationInHours :param = ();
    field $createLabelVals :param = ();
    field $subject :param;
    field $reversal :param = ();
    field $id :param;
    field $negateLabelVals :param = ();
    field $subjectBlobs :param;
    field $createdBy :param;

    ADJUST{} # TODO: handle types such as string maxlen, etc.

    # perlclass does not have :reader yet
    method action{ $action };
    method resolvedReports{ $resolvedReports };
    method reason{ $reason };
    method createdAt{ $createdAt };
    method durationInHours{ $durationInHours };
    method createLabelVals{ $createLabelVals };
    method subject{ $subject };
    method reversal{ $reversal };
    method id{ $id };
    method negateLabelVals{ $negateLabelVals };
    method subjectBlobs{ $subjectBlobs };
    method createdBy{ $createdBy };

    method _raw() {{
        action => $action,
        resolvedReports => $resolvedReports,
        reason => $reason,
        createdAt => $createdAt,
        durationInHours => $durationInHours,
        createLabelVals => $createLabelVals,
        subject => $subject,
        reversal => $reversal,
        id => $id,
        negateLabelVals => $negateLabelVals,
        subjectBlobs => $subjectBlobs,
        createdBy => $createdBy,
    }}
  }
  class At::Lexicon::com::atproto::admin::defs::repoViewNotFound {
    field $did :param;

    ADJUST{} # TODO: handle types such as string maxlen, etc.

    # perlclass does not have :reader yet
    method did{ $did };

    method _raw() {{
        did => $did,
    }}
  }
  class At::Lexicon::com::atproto::admin::defs::actionViewCurrent {
    field $id :param;
    field $durationInHours :param = ();
    field $action :param;

    ADJUST{} # TODO: handle types such as string maxlen, etc.

    # perlclass does not have :reader yet
    method id{ $id };
    method durationInHours{ $durationInHours };
    method action{ $action };

    method _raw() {{
        id => $id,
        durationInHours => $durationInHours,
        action => $action,
    }}
  }
  class At::Lexicon::com::atproto::admin::defs::repoView {
    field $invitesDisabled :param = ();
    field $relatedRecords :param;
    field $email :param = ();
    field $did :param;
    field $moderation :param;
    field $indexedAt :param;
    field $invitedBy :param = ();
    field $inviteNote :param = ();
    field $handle :param;

    ADJUST{} # TODO: handle types such as string maxlen, etc.

    # perlclass does not have :reader yet
    method invitesDisabled{ $invitesDisabled };
    method relatedRecords{ $relatedRecords };
    method email{ $email };
    method did{ $did };
    method moderation{ $moderation };
    method indexedAt{ $indexedAt };
    method invitedBy{ $invitedBy };
    method inviteNote{ $inviteNote };
    method handle{ $handle };

    method _raw() {{
        invitesDisabled => $invitesDisabled,
        relatedRecords => $relatedRecords,
        email => $email,
        did => $did,
        moderation => $moderation,
        indexedAt => $indexedAt,
        invitedBy => $invitedBy,
        inviteNote => $inviteNote,
        handle => $handle,
    }}
  }
  class At::Lexicon::com::atproto::admin::defs::repoBlobRef {
    field $recordUri :param = ();
    field $cid :param;
    field $did :param;

    ADJUST{} # TODO: handle types such as string maxlen, etc.

    # perlclass does not have :reader yet
    method recordUri{ $recordUri };
    method cid{ $cid };
    method did{ $did };

    method _raw() {{
        recordUri => $recordUri,
        cid => $cid,
        did => $did,
    }}
  }
# trash.pl:109: {
#   description => "Moderation action type: Flag. Indicates that the content was reviewed and considered to violate PDS rules, but may still be served.",
#   type => "token",
# }
  class At::Lexicon::com::atproto::admin::defs::blobView {
    field $size :param;
    field $details :param = ();
    field $moderation :param = ();
    field $mimeType :param;
    field $cid :param;
    field $createdAt :param;

    ADJUST{} # TODO: handle types such as string maxlen, etc.

    # perlclass does not have :reader yet
    method size{ $size };
    method details{ $details };
    method moderation{ $moderation };
    method mimeType{ $mimeType };
    method cid{ $cid };
    method createdAt{ $createdAt };

    method _raw() {{
        size => $size,
        details => $details,
        moderation => $moderation,
        mimeType => $mimeType,
        cid => $cid,
        createdAt => $createdAt,
    }}
  }
# trash.pl:109: {
#   description => "Moderation action type: Escalate. Indicates that the content has been flagged for additional review.",
#   type => "token",
# }
  class At::Lexicon::com::atproto::admin::defs::reportViewDetail {
    field $reason :param = ();
    field $reportedBy :param;
    field $createdAt :param;
    field $reasonType :param;
    field $subject :param;
    field $resolvedByActions :param;
    field $id :param;

    ADJUST{} # TODO: handle types such as string maxlen, etc.

    # perlclass does not have :reader yet
    method reason{ $reason };
    method reportedBy{ $reportedBy };
    method createdAt{ $createdAt };
    method reasonType{ $reasonType };
    method subject{ $subject };
    method resolvedByActions{ $resolvedByActions };
    method id{ $id };

    method _raw() {{
        reason => $reason,
        reportedBy => $reportedBy,
        createdAt => $createdAt,
        reasonType => $reasonType,
        subject => $subject,
        resolvedByActions => $resolvedByActions,
        id => $id,
    }}
  }

  __END__
  class At::Lexicon::com::atproto::admin::defs::accountView {
    field $invitedBy :param = ();
    field $inviteNote :param = ();
    field $handle :param;
    field $emailConfirmedAt :param = ();
    field $email :param = ();
    field $invitesDisabled :param = ();
    field $invites :param = ();
    field $indexedAt :param;
    field $did :param;

    ADJUST{} # TODO: handle types such as string maxlen, etc.

    # perlclass does not have :reader yet
    method invitedBy{ $invitedBy };
    method inviteNote{ $inviteNote };
    method handle{ $handle };
    method emailConfirmedAt{ $emailConfirmedAt };
    method email{ $email };
    method invitesDisabled{ $invitesDisabled };
    method invites{ $invites };
    method indexedAt{ $indexedAt };
    method did{ $did };

    method _raw() {{
        invitedBy => $invitedBy,
        inviteNote => $inviteNote,
        handle => $handle,
        emailConfirmedAt => $emailConfirmedAt,
        email => $email,
        invitesDisabled => $invitesDisabled,
        invites => $invites,
        indexedAt => $indexedAt,
        did => $did,
    }}
  }
  class At::Lexicon::com::atproto::admin::defs::repoRef {
    field $did :param;

    ADJUST{} # TODO: handle types such as string maxlen, etc.

    # perlclass does not have :reader yet
    method did{ $did };

    method _raw() {{
        did => $did,
    }}
  }
  class At::Lexicon::com::atproto::admin::defs::actionReversal {
    field $createdBy :param;
    field $createdAt :param;
    field $reason :param;

    ADJUST{} # TODO: handle types such as string maxlen, etc.

    # perlclass does not have :reader yet
    method createdBy{ $createdBy };
    method createdAt{ $createdAt };
    method reason{ $reason };

    method _raw() {{
        createdBy => $createdBy,
        createdAt => $createdAt,
        reason => $reason,
    }}
  }
  class At::Lexicon::com::atproto::admin::defs::repoViewDetail {
    field $invitedBy :param = ();
    field $handle :param;
    field $inviteNote :param = ();
    field $emailConfirmedAt :param = ();
    field $email :param = ();
    field $relatedRecords :param;
    field $invites :param = ();
    field $labels :param = ();
    field $invitesDisabled :param = ();
    field $indexedAt :param;
    field $did :param;
    field $moderation :param;

    ADJUST{} # TODO: handle types such as string maxlen, etc.

    # perlclass does not have :reader yet
    method invitedBy{ $invitedBy };
    method handle{ $handle };
    method inviteNote{ $inviteNote };
    method emailConfirmedAt{ $emailConfirmedAt };
    method email{ $email };
    method relatedRecords{ $relatedRecords };
    method invites{ $invites };
    method labels{ $labels };
    method invitesDisabled{ $invitesDisabled };
    method indexedAt{ $indexedAt };
    method did{ $did };
    method moderation{ $moderation };

    method _raw() {{
        invitedBy => $invitedBy,
        handle => $handle,
        inviteNote => $inviteNote,
        emailConfirmedAt => $emailConfirmedAt,
        email => $email,
        relatedRecords => $relatedRecords,
        invites => $invites,
        labels => $labels,
        invitesDisabled => $invitesDisabled,
        indexedAt => $indexedAt,
        did => $did,
        moderation => $moderation,
    }}
  }
  class At::Lexicon::com::atproto::admin::defs::recordView {
    field $moderation :param;
    field $blobCids :param;
    field $indexedAt :param;
    field $value :param;
    field $uri :param;
    field $repo :param;
    field $cid :param;

    ADJUST{} # TODO: handle types such as string maxlen, etc.

    # perlclass does not have :reader yet
    method moderation{ $moderation };
    method blobCids{ $blobCids };
    method indexedAt{ $indexedAt };
    method value{ $value };
    method uri{ $uri };
    method repo{ $repo };
    method cid{ $cid };

    method _raw() {{
        moderation => $moderation,
        blobCids => $blobCids,
        indexedAt => $indexedAt,
        value => $value,
        uri => $uri,
        repo => $repo,
        cid => $cid,
    }}
  }
# trash.pl:109: {
#   knownValues => ["#takedown", "#flag", "#acknowledge", "#escalate"],
#   type => "string",
# }
# trash.pl:109: {
#   description => "Moderation action type: Acknowledge. Indicates that the content was reviewed and not considered to violate PDS rules.",
#   type => "token",
# }
  class At::Lexicon::com::atproto::admin::defs::moderation {
    field $currentAction :param = ();

    ADJUST{} # TODO: handle types such as string maxlen, etc.

    # perlclass does not have :reader yet
    method currentAction{ $currentAction };

    method _raw() {{
        currentAction => $currentAction,
    }}
  }
# /home/s/Desktop/Projects/At.pm/eg/atproto/lexicons/com/atproto/admin/disableAccountInvites.json

   use v5.38;
    no warnings 'experimental::class', 'experimental::builtin';    # Be quiet.
    use feature 'class';
    use URI;

  method disableAccountInvites (%args){
    use Carp qw[confess];
    $client->http->session // confess 'creating a post requires an authenticated client';
# trash.pl:52: {
#   description => "Disable an account from receiving new invite codes, but does not invalidate existing codes.",
#   input => {
#     encoding => "application/json",
#     schema   => {
#                   properties => {
#                     account => { format => "did", type => "string" },
#                     note => {
#                       description => "Optional reason for disabled invites.",
#                       type => "string",
#                     },
#                   },
#                   required => ["account"],
#                   type => "object",
#                 },
#   },
#   type => "procedure",
# }
    confess $_ . ' is a required parameter' for 'account';
    my $res = $client->http->post( sprintf( '%s/xrpc/%s', $client->host(), 'com.atproto.admin.disableAccountInvites' )
      { content => \%args }
    );
    $res->{uri} = URI->new( $res->{uri} ) if defined $res->{uri};
    $res;
  }
# /home/s/Desktop/Projects/At.pm/eg/atproto/lexicons/com/atproto/admin/disableInviteCodes.json

   use v5.38;
    no warnings 'experimental::class', 'experimental::builtin';    # Be quiet.
    use feature 'class';
    use URI;

  method disableInviteCodes (%args){
    use Carp qw[confess];
    $client->http->session // confess 'creating a post requires an authenticated client';
# trash.pl:52: {
#   description => "Disable some set of codes and/or all codes associated with a set of users.",
#   input => {
#     encoding => "application/json",
#     schema   => {
#                   properties => {
#                     accounts => { items => { type => "string" }, type => "array" },
#                     codes => { items => { type => "string" }, type => "array" },
#                   },
#                   type => "object",
#                 },
#   },
#   type => "procedure",
# }
    my $res = $client->http->post( sprintf( '%s/xrpc/%s', $client->host(), 'com.atproto.admin.disableInviteCodes' )
      { content => \%args }
    );
    $res->{uri} = URI->new( $res->{uri} ) if defined $res->{uri};
    $res;
  }
# /home/s/Desktop/Projects/At.pm/eg/atproto/lexicons/com/atproto/admin/enableAccountInvites.json

   use v5.38;
    no warnings 'experimental::class', 'experimental::builtin';    # Be quiet.
    use feature 'class';
    use URI;

  method enableAccountInvites (%args){
    use Carp qw[confess];
    $client->http->session // confess 'creating a post requires an authenticated client';
# trash.pl:52: {
#   description => "Re-enable an account's ability to receive invite codes.",
#   input => {
#     encoding => "application/json",
#     schema   => {
#                   properties => {
#                     account => { format => "did", type => "string" },
#                     note => {
#                       description => "Optional reason for enabled invites.",
#                       type => "string",
#                     },
#                   },
#                   required => ["account"],
#                   type => "object",
#                 },
#   },
#   type => "procedure",
# }
    confess $_ . ' is a required parameter' for 'account';
    my $res = $client->http->post( sprintf( '%s/xrpc/%s', $client->host(), 'com.atproto.admin.enableAccountInvites' )
      { content => \%args }
    );
    $res->{uri} = URI->new( $res->{uri} ) if defined $res->{uri};
    $res;
  }
# /home/s/Desktop/Projects/At.pm/eg/atproto/lexicons/com/atproto/admin/getAccountInfo.json

   use v5.38;
    no warnings 'experimental::class', 'experimental::builtin';    # Be quiet.
    use feature 'class';
    use URI;

# trash.pl:109: {
#   description => "Get details about an account.",
#   output => {
#     encoding => "application/json",
#     schema   => { ref => "com.atproto.admin.defs#accountView", type => "ref" },
#   },
#   parameters => {
#     properties => { did => { format => "did", type => "string" } },
#     required => ["did"],
#     type => "params",
#   },
#   type => "query",
# }
# /home/s/Desktop/Projects/At.pm/eg/atproto/lexicons/com/atproto/admin/getInviteCodes.json

   use v5.38;
    no warnings 'experimental::class', 'experimental::builtin';    # Be quiet.
    use feature 'class';
    use URI;

# trash.pl:109: {
#   description => "Get an admin view of invite codes.",
#   output => {
#     encoding => "application/json",
#     schema   => {
#                   properties => {
#                     codes  => {
#                                 items => { ref => "com.atproto.server.defs#inviteCode", type => "ref" },
#                                 type  => "array",
#                               },
#                     cursor => { type => "string" },
#                   },
#                   required => ["codes"],
#                   type => "object",
#                 },
#   },
#   parameters => {
#     properties => {
#       cursor => { type => "string" },
#       limit  => { default => 100, maximum => 500, minimum => 1, type => "integer" },
#       sort   => {
#                   default => "recent",
#                   knownValues => ["recent", "usage"],
#                   type => "string",
#                 },
#     },
#     type => "params",
#   },
#   type => "query",
# }
# /home/s/Desktop/Projects/At.pm/eg/atproto/lexicons/com/atproto/admin/getModerationAction.json

   use v5.38;
    no warnings 'experimental::class', 'experimental::builtin';    # Be quiet.
    use feature 'class';
    use URI;

# trash.pl:109: {
#   description => "Get details about a moderation action.",
#   output => {
#     encoding => "application/json",
#     schema   => { ref => "com.atproto.admin.defs#actionViewDetail", type => "ref" },
#   },
#   parameters => {
#     properties => { id => { type => "integer" } },
#     required => ["id"],
#     type => "params",
#   },
#   type => "query",
# }
# /home/s/Desktop/Projects/At.pm/eg/atproto/lexicons/com/atproto/admin/getModerationActions.json

   use v5.38;
    no warnings 'experimental::class', 'experimental::builtin';    # Be quiet.
    use feature 'class';
    use URI;

# trash.pl:109: {
#   description => "Get a list of moderation actions related to a subject.",
#   output => {
#     encoding => "application/json",
#     schema   => {
#                   properties => {
#                     actions => {
#                                  items => { ref => "com.atproto.admin.defs#actionView", type => "ref" },
#                                  type  => "array",
#                                },
#                     cursor  => { type => "string" },
#                   },
#                   required => ["actions"],
#                   type => "object",
#                 },
#   },
#   parameters => {
#     properties => {
#       cursor  => { type => "string" },
#       limit   => { default => 50, maximum => 100, minimum => 1, type => "integer" },
#       subject => { type => "string" },
#     },
#     type => "params",
#   },
#   type => "query",
# }
# /home/s/Desktop/Projects/At.pm/eg/atproto/lexicons/com/atproto/admin/getModerationReport.json

   use v5.38;
    no warnings 'experimental::class', 'experimental::builtin';    # Be quiet.
    use feature 'class';
    use URI;

# trash.pl:109: {
#   description => "Get details about a moderation report.",
#   output => {
#     encoding => "application/json",
#     schema   => { ref => "com.atproto.admin.defs#reportViewDetail", type => "ref" },
#   },
#   parameters => {
#     properties => { id => { type => "integer" } },
#     required => ["id"],
#     type => "params",
#   },
#   type => "query",
# }
# /home/s/Desktop/Projects/At.pm/eg/atproto/lexicons/com/atproto/admin/getModerationReports.json

   use v5.38;
    no warnings 'experimental::class', 'experimental::builtin';    # Be quiet.
    use feature 'class';
    use URI;

# trash.pl:109: {
#   description => "Get moderation reports related to a subject.",
#   output => {
#     encoding => "application/json",
#     schema   => {
#                   properties => {
#                     cursor  => { type => "string" },
#                     reports => {
#                                  items => { ref => "com.atproto.admin.defs#reportView", type => "ref" },
#                                  type  => "array",
#                                },
#                   },
#                   required => ["reports"],
#                   type => "object",
#                 },
#   },
#   parameters => {
#     properties => {
#       actionedBy     => {
#                           description => "Get all reports that were actioned by a specific moderator.",
#                           format => "did",
#                           type => "string",
#                         },
#       actionType     => {
#                           knownValues => [
#                             "com.atproto.admin.defs#takedown",
#                             "com.atproto.admin.defs#flag",
#                             "com.atproto.admin.defs#acknowledge",
#                             "com.atproto.admin.defs#escalate",
#                           ],
#                           type => "string",
#                         },
#       cursor         => { type => "string" },
#       ignoreSubjects => { items => { type => "string" }, type => "array" },
#       limit          => { default => 50, maximum => 100, minimum => 1, type => "integer" },
#       reporters      => {
#                           description => "Filter reports made by one or more DIDs.",
#                           items => { type => "string" },
#                           type => "array",
#                         },
#       resolved       => { type => "boolean" },
#       reverse        => {
#                           description => "Reverse the order of the returned records. When true, returns reports in chronological order.",
#                           type => "boolean",
#                         },
#       subject        => { type => "string" },
#     },
#     type => "params",
#   },
#   type => "query",
# }
# /home/s/Desktop/Projects/At.pm/eg/atproto/lexicons/com/atproto/admin/getRecord.json

   use v5.38;
    no warnings 'experimental::class', 'experimental::builtin';    # Be quiet.
    use feature 'class';
    use URI;

# trash.pl:109: {
#   description => "Get details about a record.",
#   errors => [{ name => "RecordNotFound" }],
#   output => {
#     encoding => "application/json",
#     schema   => { ref => "com.atproto.admin.defs#recordViewDetail", type => "ref" },
#   },
#   parameters => {
#     properties => {
#       cid => { format => "cid", type => "string" },
#       uri => { format => "at-uri", type => "string" },
#     },
#     required => ["uri"],
#     type => "params",
#   },
#   type => "query",
# }
# /home/s/Desktop/Projects/At.pm/eg/atproto/lexicons/com/atproto/admin/getRepo.json

   use v5.38;
    no warnings 'experimental::class', 'experimental::builtin';    # Be quiet.
    use feature 'class';
    use URI;

# trash.pl:109: {
#   description => "Get details about a repository.",
#   errors => [{ name => "RepoNotFound" }],
#   output => {
#     encoding => "application/json",
#     schema   => { ref => "com.atproto.admin.defs#repoViewDetail", type => "ref" },
#   },
#   parameters => {
#     properties => { did => { format => "did", type => "string" } },
#     required => ["did"],
#     type => "params",
#   },
#   type => "query",
# }
# /home/s/Desktop/Projects/At.pm/eg/atproto/lexicons/com/atproto/admin/getSubjectStatus.json

   use v5.38;
    no warnings 'experimental::class', 'experimental::builtin';    # Be quiet.
    use feature 'class';
    use URI;

# trash.pl:109: {
#   description => "Get the service-specific admin status of a subject (account, record, or blob).",
#   output => {
#     encoding => "application/json",
#     schema   => {
#                   properties => {
#                     subject  => {
#                                   refs => [
#                                             "com.atproto.admin.defs#repoRef",
#                                             "com.atproto.repo.strongRef",
#                                             "com.atproto.admin.defs#repoBlobRef",
#                                           ],
#                                   type => "union",
#                                 },
#                     takedown => { ref => "com.atproto.admin.defs#statusAttr", type => "ref" },
#                   },
#                   required => ["subject"],
#                   type => "object",
#                 },
#   },
#   parameters => {
#     properties => {
#       blob => { format => "cid", type => "string" },
#       did  => { format => "did", type => "string" },
#       uri  => { format => "at-uri", type => "string" },
#     },
#     type => "params",
#   },
#   type => "query",
# }
# /home/s/Desktop/Projects/At.pm/eg/atproto/lexicons/com/atproto/admin/resolveModerationReports.json

   use v5.38;
    no warnings 'experimental::class', 'experimental::builtin';    # Be quiet.
    use feature 'class';
    use URI;

  method resolveModerationReports (%args){
    use Carp qw[confess];
    $client->http->session // confess 'creating a post requires an authenticated client';
# trash.pl:52: {
#   description => "Resolve moderation reports by an action.",
#   input => {
#     encoding => "application/json",
#     schema   => {
#                   properties => {
#                     actionId  => { type => "integer" },
#                     createdBy => { format => "did", type => "string" },
#                     reportIds => { items => { type => "integer" }, type => "array" },
#                   },
#                   required => ["actionId", "reportIds", "createdBy"],
#                   type => "object",
#                 },
#   },
#   output => {
#     encoding => "application/json",
#     schema   => { ref => "com.atproto.admin.defs#actionView", type => "ref" },
#   },
#   type => "procedure",
# }
    confess $_ . ' is a required parameter' for 'actionId', 'reportIds', 'createdBy';
    my $res = $client->http->post( sprintf( '%s/xrpc/%s', $client->host(), 'com.atproto.admin.resolveModerationReports' )
      { content => \%args }
    );
    $res->{uri} = URI->new( $res->{uri} ) if defined $res->{uri};
    $res;
  }
# /home/s/Desktop/Projects/At.pm/eg/atproto/lexicons/com/atproto/admin/reverseModerationAction.json

   use v5.38;
    no warnings 'experimental::class', 'experimental::builtin';    # Be quiet.
    use feature 'class';
    use URI;

  method reverseModerationAction (%args){
    use Carp qw[confess];
    $client->http->session // confess 'creating a post requires an authenticated client';
# trash.pl:52: {
#   description => "Reverse a moderation action.",
#   input => {
#     encoding => "application/json",
#     schema   => {
#                   properties => {
#                     createdBy => { format => "did", type => "string" },
#                     id => { type => "integer" },
#                     reason => { type => "string" },
#                   },
#                   required => ["id", "reason", "createdBy"],
#                   type => "object",
#                 },
#   },
#   output => {
#     encoding => "application/json",
#     schema   => { ref => "com.atproto.admin.defs#actionView", type => "ref" },
#   },
#   type => "procedure",
# }
    confess $_ . ' is a required parameter' for 'id', 'reason', 'createdBy';
    my $res = $client->http->post( sprintf( '%s/xrpc/%s', $client->host(), 'com.atproto.admin.reverseModerationAction' )
      { content => \%args }
    );
    $res->{uri} = URI->new( $res->{uri} ) if defined $res->{uri};
    $res;
  }
# /home/s/Desktop/Projects/At.pm/eg/atproto/lexicons/com/atproto/admin/searchRepos.json

   use v5.38;
    no warnings 'experimental::class', 'experimental::builtin';    # Be quiet.
    use feature 'class';
    use URI;

# trash.pl:109: {
#   description => "Find repositories based on a search term.",
#   output => {
#     encoding => "application/json",
#     schema   => {
#                   properties => {
#                     cursor => { type => "string" },
#                     repos  => {
#                                 items => { ref => "com.atproto.admin.defs#repoView", type => "ref" },
#                                 type  => "array",
#                               },
#                   },
#                   required => ["repos"],
#                   type => "object",
#                 },
#   },
#   parameters => {
#     properties => {
#       cursor => { type => "string" },
#       limit => { default => 50, maximum => 100, minimum => 1, type => "integer" },
#       q => { type => "string" },
#       term => { description => "DEPRECATED: use 'q' instead", type => "string" },
#     },
#     type => "params",
#   },
#   type => "query",
# }
# /home/s/Desktop/Projects/At.pm/eg/atproto/lexicons/com/atproto/admin/sendEmail.json

   use v5.38;
    no warnings 'experimental::class', 'experimental::builtin';    # Be quiet.
    use feature 'class';
    use URI;

  method sendEmail (%args){
    use Carp qw[confess];
    $client->http->session // confess 'creating a post requires an authenticated client';
# trash.pl:52: {
#   description => "Send email to a user's account email address.",
#   input => {
#     encoding => "application/json",
#     schema   => {
#                   properties => {
#                     content      => { type => "string" },
#                     recipientDid => { format => "did", type => "string" },
#                     subject      => { type => "string" },
#                   },
#                   required => ["recipientDid", "content"],
#                   type => "object",
#                 },
#   },
#   output => {
#     encoding => "application/json",
#     schema   => {
#                   properties => { sent => { type => "boolean" } },
#                   required => ["sent"],
#                   type => "object",
#                 },
#   },
#   type => "procedure",
# }
    confess $_ . ' is a required parameter' for 'recipientDid', 'content';
    my $res = $client->http->post( sprintf( '%s/xrpc/%s', $client->host(), 'com.atproto.admin.sendEmail' )
      { content => \%args }
    );
    $res->{uri} = URI->new( $res->{uri} ) if defined $res->{uri};
    $res;
  }
# /home/s/Desktop/Projects/At.pm/eg/atproto/lexicons/com/atproto/admin/takeModerationAction.json

   use v5.38;
    no warnings 'experimental::class', 'experimental::builtin';    # Be quiet.
    use feature 'class';
    use URI;

  method takeModerationAction (%args){
    use Carp qw[confess];
    $client->http->session // confess 'creating a post requires an authenticated client';
# trash.pl:52: {
#   description => "Take a moderation action on an actor.",
#   errors      => [{ name => "SubjectHasAction" }],
#   input       => {
#                    encoding => "application/json",
#                    schema   => {
#                                  properties => {
#                                    action => {
#                                      knownValues => [
#                                        "com.atproto.admin.defs#takedown",
#                                        "com.atproto.admin.defs#flag",
#                                        "com.atproto.admin.defs#acknowledge",
#                                      ],
#                                      type => "string",
#                                    },
#                                    createdBy => { format => "did", type => "string" },
#                                    createLabelVals => { items => { type => "string" }, type => "array" },
#                                    durationInHours => {
#                                      description => "Indicates how long this action is meant to be in effect before automatically expiring.",
#                                      type => "integer",
#                                    },
#                                    negateLabelVals => { items => { type => "string" }, type => "array" },
#                                    reason => { type => "string" },
#                                    subject => {
#                                      refs => [
#                                                "com.atproto.admin.defs#repoRef",
#                                                "com.atproto.repo.strongRef",
#                                              ],
#                                      type => "union",
#                                    },
#                                    subjectBlobCids => { items => { format => "cid", type => "string" }, type => "array" },
#                                  },
#                                  required => ["action", "subject", "reason", "createdBy"],
#                                  type => "object",
#                                },
#                  },
#   output      => {
#                    encoding => "application/json",
#                    schema   => { ref => "com.atproto.admin.defs#actionView", type => "ref" },
#                  },
#   type        => "procedure",
# }
    confess $_ . ' is a required parameter' for 'action', 'subject', 'reason', 'createdBy';
    my $res = $client->http->post( sprintf( '%s/xrpc/%s', $client->host(), 'com.atproto.admin.takeModerationAction' )
      { content => \%args }
    );
    $res->{uri} = URI->new( $res->{uri} ) if defined $res->{uri};
    $res;
  }
# /home/s/Desktop/Projects/At.pm/eg/atproto/lexicons/com/atproto/admin/updateAccountEmail.json

   use v5.38;
    no warnings 'experimental::class', 'experimental::builtin';    # Be quiet.
    use feature 'class';
    use URI;

  method updateAccountEmail (%args){
    use Carp qw[confess];
    $client->http->session // confess 'creating a post requires an authenticated client';
# trash.pl:52: {
#   description => "Administrative action to update an account's email.",
#   input => {
#     encoding => "application/json",
#     schema   => {
#                   properties => {
#                     account => {
#                                  description => "The handle or DID of the repo.",
#                                  format => "at-identifier",
#                                  type => "string",
#                                },
#                     email   => { type => "string" },
#                   },
#                   required => ["account", "email"],
#                   type => "object",
#                 },
#   },
#   type => "procedure",
# }
    confess $_ . ' is a required parameter' for 'account', 'email';
    my $res = $client->http->post( sprintf( '%s/xrpc/%s', $client->host(), 'com.atproto.admin.updateAccountEmail' )
      { content => \%args }
    );
    $res->{uri} = URI->new( $res->{uri} ) if defined $res->{uri};
    $res;
  }
# /home/s/Desktop/Projects/At.pm/eg/atproto/lexicons/com/atproto/admin/updateAccountHandle.json

   use v5.38;
    no warnings 'experimental::class', 'experimental::builtin';    # Be quiet.
    use feature 'class';
    use URI;

  method updateAccountHandle (%args){
    use Carp qw[confess];
    $client->http->session // confess 'creating a post requires an authenticated client';
# trash.pl:52: {
#   description => "Administrative action to update an account's handle.",
#   input => {
#     encoding => "application/json",
#     schema   => {
#                   properties => {
#                     did => { format => "did", type => "string" },
#                     handle => { format => "handle", type => "string" },
#                   },
#                   required => ["did", "handle"],
#                   type => "object",
#                 },
#   },
#   type => "procedure",
# }
    confess $_ . ' is a required parameter' for 'did', 'handle';
    my $res = $client->http->post( sprintf( '%s/xrpc/%s', $client->host(), 'com.atproto.admin.updateAccountHandle' )
      { content => \%args }
    );
    $res->{uri} = URI->new( $res->{uri} ) if defined $res->{uri};
    $res;
  }
# /home/s/Desktop/Projects/At.pm/eg/atproto/lexicons/com/atproto/admin/updateSubjectStatus.json

   use v5.38;
    no warnings 'experimental::class', 'experimental::builtin';    # Be quiet.
    use feature 'class';
    use URI;

  method updateSubjectStatus (%args){
    use Carp qw[confess];
    $client->http->session // confess 'creating a post requires an authenticated client';
# trash.pl:52: {
#   description => "Update the service-specific admin status of a subject (account, record, or blob).",
#   input => {
#     encoding => "application/json",
#     schema   => {
#                   properties => {
#                     subject  => {
#                                   refs => [
#                                             "com.atproto.admin.defs#repoRef",
#                                             "com.atproto.repo.strongRef",
#                                             "com.atproto.admin.defs#repoBlobRef",
#                                           ],
#                                   type => "union",
#                                 },
#                     takedown => { ref => "com.atproto.admin.defs#statusAttr", type => "ref" },
#                   },
#                   required => ["subject"],
#                   type => "object",
#                 },
#   },
#   output => {
#     encoding => "application/json",
#     schema   => {
#                   properties => {
#                     subject  => {
#                                   refs => [
#                                             "com.atproto.admin.defs#repoRef",
#                                             "com.atproto.repo.strongRef",
#                                             "com.atproto.admin.defs#repoBlobRef",
#                                           ],
#                                   type => "union",
#                                 },
#                     takedown => { ref => "com.atproto.admin.defs#statusAttr", type => "ref" },
#                   },
#                   required => ["subject"],
#                   type => "object",
#                 },
#   },
#   type => "procedure",
# }
    confess $_ . ' is a required parameter' for 'subject';
    my $res = $client->http->post( sprintf( '%s/xrpc/%s', $client->host(), 'com.atproto.admin.updateSubjectStatus' )
      { content => \%args }
    );
    $res->{uri} = URI->new( $res->{uri} ) if defined $res->{uri};
    $res;
  }
# /home/s/Desktop/Projects/At.pm/eg/atproto/lexicons/com/atproto/identity/resolveHandle.json

   use v5.38;
    no warnings 'experimental::class', 'experimental::builtin';    # Be quiet.
    use feature 'class';
    use URI;

# trash.pl:109: {
#   description => "Provides the DID of a repo.",
#   output => {
#     encoding => "application/json",
#     schema   => {
#                   properties => { did => { format => "did", type => "string" } },
#                   required => ["did"],
#                   type => "object",
#                 },
#   },
#   parameters => {
#     properties => {
#       handle => {
#         description => "The handle to resolve.",
#         format => "handle",
#         type => "string",
#       },
#     },
#     required => ["handle"],
#     type => "params",
#   },
#   type => "query",
# }
# /home/s/Desktop/Projects/At.pm/eg/atproto/lexicons/com/atproto/identity/updateHandle.json

   use v5.38;
    no warnings 'experimental::class', 'experimental::builtin';    # Be quiet.
    use feature 'class';
    use URI;

  method updateHandle (%args){
    use Carp qw[confess];
    $client->http->session // confess 'creating a post requires an authenticated client';
# trash.pl:52: {
#   description => "Updates the handle of the account.",
#   input => {
#     encoding => "application/json",
#     schema   => {
#                   properties => { handle => { format => "handle", type => "string" } },
#                   required => ["handle"],
#                   type => "object",
#                 },
#   },
#   type => "procedure",
# }
    confess $_ . ' is a required parameter' for 'handle';
    my $res = $client->http->post( sprintf( '%s/xrpc/%s', $client->host(), 'com.atproto.identity.updateHandle' )
      { content => \%args }
    );
    $res->{uri} = URI->new( $res->{uri} ) if defined $res->{uri};
    $res;
  }
# /home/s/Desktop/Projects/At.pm/eg/atproto/lexicons/com/atproto/label/defs.json

   use v5.38;
    no warnings 'experimental::class', 'experimental::builtin';    # Be quiet.
    use feature 'class';
    use URI;

  class At::Lexicon::com::atproto::label::defs::label {
    field $neg :param = ();
    field $cts :param;
    field $cid :param = ();
    field $src :param;
    field $val :param;
    field $uri :param;

    ADJUST{} # TODO: handle types such as string maxlen, etc.

    # perlclass does not have :reader yet
    method neg{ $neg };
    method cts{ $cts };
    method cid{ $cid };
    method src{ $src };
    method val{ $val };
    method uri{ $uri };

    method _raw() {{
        neg => $neg,
        cts => $cts,
        cid => $cid,
        src => $src,
        val => $val,
        uri => $uri,
    }}
  }
  class At::Lexicon::com::atproto::label::defs::selfLabels {
    field $values :param;

    ADJUST{} # TODO: handle types such as string maxlen, etc.

    # perlclass does not have :reader yet
    method values{ $values };

    method _raw() {{
        values => $values,
    }}
  }
  class At::Lexicon::com::atproto::label::defs::selfLabel {
    field $val :param;

    ADJUST{} # TODO: handle types such as string maxlen, etc.

    # perlclass does not have :reader yet
    method val{ $val };

    method _raw() {{
        val => $val,
    }}
  }
# /home/s/Desktop/Projects/At.pm/eg/atproto/lexicons/com/atproto/label/queryLabels.json

   use v5.38;
    no warnings 'experimental::class', 'experimental::builtin';    # Be quiet.
    use feature 'class';
    use URI;

# trash.pl:109: {
#   description => "Find labels relevant to the provided URI patterns.",
#   output => {
#     encoding => "application/json",
#     schema   => {
#                   properties => {
#                     cursor => { type => "string" },
#                     labels => {
#                                 items => { ref => "com.atproto.label.defs#label", type => "ref" },
#                                 type  => "array",
#                               },
#                   },
#                   required => ["labels"],
#                   type => "object",
#                 },
#   },
#   parameters => {
#     properties => {
#       cursor      => { type => "string" },
#       limit       => { default => 50, maximum => 250, minimum => 1, type => "integer" },
#       sources     => {
#                        description => "Optional list of label sources (DIDs) to filter on.",
#                        items => { format => "did", type => "string" },
#                        type => "array",
#                      },
#       uriPatterns => {
#                        description => "List of AT URI patterns to match (boolean 'OR'). Each may be a prefix (ending with '*'; will match inclusive of the string leading to '*'), or a full URI.",
#                        items => { type => "string" },
#                        type => "array",
#                      },
#     },
#     required => ["uriPatterns"],
#     type => "params",
#   },
#   type => "query",
# }
# /home/s/Desktop/Projects/At.pm/eg/atproto/lexicons/com/atproto/label/subscribeLabels.json

   use v5.38;
    no warnings 'experimental::class', 'experimental::builtin';    # Be quiet.
    use feature 'class';
    use URI;

  class At::Lexicon::com::atproto::label::subscribeLabels::labels {
    field $labels :param;
    field $seq :param;

    ADJUST{} # TODO: handle types such as string maxlen, etc.

    # perlclass does not have :reader yet
    method labels{ $labels };
    method seq{ $seq };

    method _raw() {{
        labels => $labels,
        seq => $seq,
    }}
  }
  class At::Lexicon::com::atproto::label::subscribeLabels::info {
    field $message :param = ();
    field $name :param;

    ADJUST{} # TODO: handle types such as string maxlen, etc.

    # perlclass does not have :reader yet
    method message{ $message };
    method name{ $name };

    method _raw() {{
        message => $message,
        name => $name,
    }}
  }
# trash.pl:109: {
#   description => "Subscribe to label updates.",
#   errors => [{ name => "FutureCursor" }],
#   message => { schema => { refs => ["#labels", "#info"], type => "union" } },
#   parameters => {
#     properties => {
#       cursor => {
#         description => "The last known event to backfill from.",
#         type => "integer",
#       },
#     },
#     type => "params",
#   },
#   type => "subscription",
# }
# /home/s/Desktop/Projects/At.pm/eg/atproto/lexicons/com/atproto/moderation/createReport.json

   use v5.38;
    no warnings 'experimental::class', 'experimental::builtin';    # Be quiet.
    use feature 'class';
    use URI;

  method createReport (%args){
    use Carp qw[confess];
    $client->http->session // confess 'creating a post requires an authenticated client';
# trash.pl:52: {
#   description => "Report a repo or a record.",
#   input => {
#     encoding => "application/json",
#     schema   => {
#                   properties => {
#                     reason     => { type => "string" },
#                     reasonType => { ref => "com.atproto.moderation.defs#reasonType", type => "ref" },
#                     subject    => {
#                                     refs => [
#                                               "com.atproto.admin.defs#repoRef",
#                                               "com.atproto.repo.strongRef",
#                                             ],
#                                     type => "union",
#                                   },
#                   },
#                   required => ["reasonType", "subject"],
#                   type => "object",
#                 },
#   },
#   output => {
#     encoding => "application/json",
#     schema   => {
#                   properties => {
#                     createdAt => { format => "datetime", type => "string" },
#                     id => { type => "integer" },
#                     reason => { maxGraphemes => 2000, maxLength => 20000, type => "string" },
#                     reasonType => { ref => "com.atproto.moderation.defs#reasonType", type => "ref" },
#                     reportedBy => { format => "did", type => "string" },
#                     subject => {
#                       refs => [
#                                 "com.atproto.admin.defs#repoRef",
#                                 "com.atproto.repo.strongRef",
#                               ],
#                       type => "union",
#                     },
#                   },
#                   required => ["id", "reasonType", "subject", "reportedBy", "createdAt"],
#                   type => "object",
#                 },
#   },
#   type => "procedure",
# }
    confess $_ . ' is a required parameter' for 'reasonType', 'subject';
    my $res = $client->http->post( sprintf( '%s/xrpc/%s', $client->host(), 'com.atproto.moderation.createReport' )
      { content => \%args }
    );
    $res->{uri} = URI->new( $res->{uri} ) if defined $res->{uri};
    $res;
  }
# /home/s/Desktop/Projects/At.pm/eg/atproto/lexicons/com/atproto/moderation/defs.json

   use v5.38;
    no warnings 'experimental::class', 'experimental::builtin';    # Be quiet.
    use feature 'class';
    use URI;

# trash.pl:109: {
#   knownValues => [
#     "com.atproto.moderation.defs#reasonSpam",
#     "com.atproto.moderation.defs#reasonViolation",
#     "com.atproto.moderation.defs#reasonMisleading",
#     "com.atproto.moderation.defs#reasonSexual",
#     "com.atproto.moderation.defs#reasonRude",
#     "com.atproto.moderation.defs#reasonOther",
#   ],
#   type => "string",
# }
# trash.pl:109: {
#   description => "Spam: frequent unwanted promotion, replies, mentions",
#   type => "token",
# }
# trash.pl:109: {
#   description => "Other: reports not falling under another report category",
#   type => "token",
# }
# trash.pl:109: {
#   description => "Misleading identity, affiliation, or content",
#   type => "token",
# }
# trash.pl:109: {
#   description => "Unwanted or mislabeled sexual content",
#   type => "token",
# }
# trash.pl:109: {
#   description => "Rude, harassing, explicit, or otherwise unwelcoming behavior",
#   type => "token",
# }
# trash.pl:109: {
#   description => "Direct violation of server rules, laws, terms of service",
#   type => "token",
# }
# /home/s/Desktop/Projects/At.pm/eg/atproto/lexicons/com/atproto/repo/applyWrites.json

   use v5.38;
    no warnings 'experimental::class', 'experimental::builtin';    # Be quiet.
    use feature 'class';
    use URI;

  class At::Lexicon::com::atproto::repo::applyWrites::create {
    field $collection :param;
    field $value :param;
    field $rkey :param = ();

    ADJUST{} # TODO: handle types such as string maxlen, etc.

    # perlclass does not have :reader yet
    method collection{ $collection };
    method value{ $value };
    method rkey{ $rkey };

    method _raw() {{
        collection => $collection,
        value => $value,
        rkey => $rkey,
    }}
  }
  class At::Lexicon::com::atproto::repo::applyWrites::update {
    field $collection :param;
    field $value :param;
    field $rkey :param;

    ADJUST{} # TODO: handle types such as string maxlen, etc.

    # perlclass does not have :reader yet
    method collection{ $collection };
    method value{ $value };
    method rkey{ $rkey };

    method _raw() {{
        collection => $collection,
        value => $value,
        rkey => $rkey,
    }}
  }
  method applyWrites (%args){
    use Carp qw[confess];
    $client->http->session // confess 'creating a post requires an authenticated client';
# trash.pl:52: do {
#   my $a = {
#     description => "Apply a batch transaction of creates, updates, and deletes.",
#     errors => [{ name => "InvalidSwap" }],
#     input => {
#       encoding => "application/json",
#       schema   => {
#                     properties => {
#                       repo => {
#                         description => "The handle or DID of the repo.",
#                         format => "at-identifier",
#                         type => "string",
#                       },
#                       swapCommit => { format => "cid", type => "string" },
#                       validate => {
#                         default => bless(do{\(my $o = 1)}, "JSON::Tiny::_Bool"),
#                         description => "Flag for validating the records.",
#                         type => "boolean",
#                       },
#                       writes => {
#                         items => {
#                                    closed => 'fix',
#                                    refs   => ["#create", "#update", "#delete"],
#                                    type   => "union",
#                                  },
#                         type  => "array",
#                       },
#                     },
#                     required => ["repo", "writes"],
#                     type => "object",
#                   },
#     },
#     type => "procedure",
#   };
#   $a->{input}{schema}{properties}{writes}{items}{closed} = \${$a->{input}{schema}{properties}{validate}{default}};
#   $a;
# }
    confess $_ . ' is a required parameter' for 'repo', 'writes';
    my $res = $client->http->post( sprintf( '%s/xrpc/%s', $client->host(), 'com.atproto.repo.applyWrites' )
      { content => \%args }
    );
    $res->{uri} = URI->new( $res->{uri} ) if defined $res->{uri};
    $res;
  }
  class At::Lexicon::com::atproto::repo::applyWrites::delete {
    field $rkey :param;
    field $collection :param;

    ADJUST{} # TODO: handle types such as string maxlen, etc.

    # perlclass does not have :reader yet
    method rkey{ $rkey };
    method collection{ $collection };

    method _raw() {{
        rkey => $rkey,
        collection => $collection,
    }}
  }
# /home/s/Desktop/Projects/At.pm/eg/atproto/lexicons/com/atproto/repo/createRecord.json

   use v5.38;
    no warnings 'experimental::class', 'experimental::builtin';    # Be quiet.
    use feature 'class';
    use URI;

  method createRecord (%args){
    use Carp qw[confess];
    $client->http->session // confess 'creating a post requires an authenticated client';
# trash.pl:52: {
#   description => "Create a new record.",
#   errors      => [{ name => "InvalidSwap" }],
#   input       => {
#                    encoding => "application/json",
#                    schema   => {
#                                  properties => {
#                                    collection => {
#                                      description => "The NSID of the record collection.",
#                                      format => "nsid",
#                                      type => "string",
#                                    },
#                                    record => { description => "The record to create.", type => "unknown" },
#                                    repo => {
#                                      description => "The handle or DID of the repo.",
#                                      format => "at-identifier",
#                                      type => "string",
#                                    },
#                                    rkey => {
#                                      description => "The key of the record.",
#                                      maxLength => 15,
#                                      type => "string",
#                                    },
#                                    swapCommit => {
#                                      description => "Compare and swap with the previous commit by CID.",
#                                      format => "cid",
#                                      type => "string",
#                                    },
#                                    validate => {
#                                      default => bless(do{\(my $o = 1)}, "JSON::Tiny::_Bool"),
#                                      description => "Flag for validating the record.",
#                                      type => "boolean",
#                                    },
#                                  },
#                                  required => ["repo", "collection", "record"],
#                                  type => "object",
#                                },
#                  },
#   output      => {
#                    encoding => "application/json",
#                    schema   => {
#                                  properties => {
#                                    cid => { format => "cid", type => "string" },
#                                    uri => { format => "at-uri", type => "string" },
#                                  },
#                                  required => ["uri", "cid"],
#                                  type => "object",
#                                },
#                  },
#   type        => "procedure",
# }
    confess $_ . ' is a required parameter' for 'repo', 'collection', 'record';
    my $res = $client->http->post( sprintf( '%s/xrpc/%s', $client->host(), 'com.atproto.repo.createRecord' )
      { content => \%args }
    );
    $res->{uri} = URI->new( $res->{uri} ) if defined $res->{uri};
    $res;
  }
# /home/s/Desktop/Projects/At.pm/eg/atproto/lexicons/com/atproto/repo/deleteRecord.json

   use v5.38;
    no warnings 'experimental::class', 'experimental::builtin';    # Be quiet.
    use feature 'class';
    use URI;

  method deleteRecord (%args){
    use Carp qw[confess];
    $client->http->session // confess 'creating a post requires an authenticated client';
# trash.pl:52: {
#   description => "Delete a record, or ensure it doesn't exist.",
#   errors => [{ name => "InvalidSwap" }],
#   input => {
#     encoding => "application/json",
#     schema   => {
#                   properties => {
#                     collection => {
#                       description => "The NSID of the record collection.",
#                       format => "nsid",
#                       type => "string",
#                     },
#                     repo => {
#                       description => "The handle or DID of the repo.",
#                       format => "at-identifier",
#                       type => "string",
#                     },
#                     rkey => { description => "The key of the record.", type => "string" },
#                     swapCommit => {
#                       description => "Compare and swap with the previous commit by CID.",
#                       format => "cid",
#                       type => "string",
#                     },
#                     swapRecord => {
#                       description => "Compare and swap with the previous record by CID.",
#                       format => "cid",
#                       type => "string",
#                     },
#                   },
#                   required => ["repo", "collection", "rkey"],
#                   type => "object",
#                 },
#   },
#   type => "procedure",
# }
    confess $_ . ' is a required parameter' for 'repo', 'collection', 'rkey';
    my $res = $client->http->post( sprintf( '%s/xrpc/%s', $client->host(), 'com.atproto.repo.deleteRecord' )
      { content => \%args }
    );
    $res->{uri} = URI->new( $res->{uri} ) if defined $res->{uri};
    $res;
  }
# /home/s/Desktop/Projects/At.pm/eg/atproto/lexicons/com/atproto/repo/describeRepo.json

   use v5.38;
    no warnings 'experimental::class', 'experimental::builtin';    # Be quiet.
    use feature 'class';
    use URI;

# trash.pl:109: {
#   description => "Get information about the repo, including the list of collections.",
#   output => {
#     encoding => "application/json",
#     schema   => {
#                   properties => {
#                     collections => { items => { format => "nsid", type => "string" }, type => "array" },
#                     did => { format => "did", type => "string" },
#                     didDoc => { type => "unknown" },
#                     handle => { format => "handle", type => "string" },
#                     handleIsCorrect => { type => "boolean" },
#                   },
#                   required => ["handle", "did", "didDoc", "collections", "handleIsCorrect"],
#                   type => "object",
#                 },
#   },
#   parameters => {
#     properties => {
#       repo => {
#         description => "The handle or DID of the repo.",
#         format => "at-identifier",
#         type => "string",
#       },
#     },
#     required => ["repo"],
#     type => "params",
#   },
#   type => "query",
# }
# /home/s/Desktop/Projects/At.pm/eg/atproto/lexicons/com/atproto/repo/getRecord.json

   use v5.38;
    no warnings 'experimental::class', 'experimental::builtin';    # Be quiet.
    use feature 'class';
    use URI;

# trash.pl:109: {
#   description => "Get a record.",
#   output => {
#     encoding => "application/json",
#     schema   => {
#                   properties => {
#                     cid   => { format => "cid", type => "string" },
#                     uri   => { format => "at-uri", type => "string" },
#                     value => { type => "unknown" },
#                   },
#                   required => ["uri", "value"],
#                   type => "object",
#                 },
#   },
#   parameters => {
#     properties => {
#       cid => {
#         description => "The CID of the version of the record. If not specified, then return the most recent version.",
#         format => "cid",
#         type => "string",
#       },
#       collection => {
#         description => "The NSID of the record collection.",
#         format => "nsid",
#         type => "string",
#       },
#       repo => {
#         description => "The handle or DID of the repo.",
#         format => "at-identifier",
#         type => "string",
#       },
#       rkey => { description => "The key of the record.", type => "string" },
#     },
#     required => ["repo", "collection", "rkey"],
#     type => "params",
#   },
#   type => "query",
# }
# /home/s/Desktop/Projects/At.pm/eg/atproto/lexicons/com/atproto/repo/listRecords.json

   use v5.38;
    no warnings 'experimental::class', 'experimental::builtin';    # Be quiet.
    use feature 'class';
    use URI;

# trash.pl:109: {
#   description => "List a range of records in a collection.",
#   output => {
#     encoding => "application/json",
#     schema   => {
#                   properties => {
#                     cursor  => { type => "string" },
#                     records => { items => { ref => "#record", type => "ref" }, type => "array" },
#                   },
#                   required => ["records"],
#                   type => "object",
#                 },
#   },
#   parameters => {
#     properties => {
#       collection => {
#                       description => "The NSID of the record type.",
#                       format => "nsid",
#                       type => "string",
#                     },
#       cursor     => { type => "string" },
#       limit      => {
#                       default     => 50,
#                       description => "The number of records to return.",
#                       maximum     => 100,
#                       minimum     => 1,
#                       type        => "integer",
#                     },
#       repo       => {
#                       description => "The handle or DID of the repo.",
#                       format => "at-identifier",
#                       type => "string",
#                     },
#       reverse    => {
#                       description => "Flag to reverse the order of the returned records.",
#                       type => "boolean",
#                     },
#       rkeyEnd    => {
#                       description => "DEPRECATED: The highest sort-ordered rkey to stop at (exclusive)",
#                       type => "string",
#                     },
#       rkeyStart  => {
#                       description => "DEPRECATED: The lowest sort-ordered rkey to start from (exclusive)",
#                       type => "string",
#                     },
#     },
#     required => ["repo", "collection"],
#     type => "params",
#   },
#   type => "query",
# }
  class At::Lexicon::com::atproto::repo::listRecords::record {
    field $value :param;
    field $uri :param;
    field $cid :param;

    ADJUST{} # TODO: handle types such as string maxlen, etc.

    # perlclass does not have :reader yet
    method value{ $value };
    method uri{ $uri };
    method cid{ $cid };

    method _raw() {{
        value => $value,
        uri => $uri,
        cid => $cid,
    }}
  }
# /home/s/Desktop/Projects/At.pm/eg/atproto/lexicons/com/atproto/repo/putRecord.json

   use v5.38;
    no warnings 'experimental::class', 'experimental::builtin';    # Be quiet.
    use feature 'class';
    use URI;

  method putRecord (%args){
    use Carp qw[confess];
    $client->http->session // confess 'creating a post requires an authenticated client';
# trash.pl:52: {
#   description => "Write a record, creating or updating it as needed.",
#   errors      => [{ name => "InvalidSwap" }],
#   input       => {
#                    encoding => "application/json",
#                    schema   => {
#                                  nullable => ["swapRecord"],
#                                  properties => {
#                                    collection => {
#                                      description => "The NSID of the record collection.",
#                                      format => "nsid",
#                                      type => "string",
#                                    },
#                                    record => { description => "The record to write.", type => "unknown" },
#                                    repo => {
#                                      description => "The handle or DID of the repo.",
#                                      format => "at-identifier",
#                                      type => "string",
#                                    },
#                                    rkey => {
#                                      description => "The key of the record.",
#                                      maxLength => 15,
#                                      type => "string",
#                                    },
#                                    swapCommit => {
#                                      description => "Compare and swap with the previous commit by CID.",
#                                      format => "cid",
#                                      type => "string",
#                                    },
#                                    swapRecord => {
#                                      description => "Compare and swap with the previous record by CID.",
#                                      format => "cid",
#                                      type => "string",
#                                    },
#                                    validate => {
#                                      default => bless(do{\(my $o = 1)}, "JSON::Tiny::_Bool"),
#                                      description => "Flag for validating the record.",
#                                      type => "boolean",
#                                    },
#                                  },
#                                  required => ["repo", "collection", "rkey", "record"],
#                                  type => "object",
#                                },
#                  },
#   output      => {
#                    encoding => "application/json",
#                    schema   => {
#                                  properties => {
#                                    cid => { format => "cid", type => "string" },
#                                    uri => { format => "at-uri", type => "string" },
#                                  },
#                                  required => ["uri", "cid"],
#                                  type => "object",
#                                },
#                  },
#   type        => "procedure",
# }
    confess $_ . ' is a required parameter' for 'repo', 'collection', 'rkey', 'record';
    my $res = $client->http->post( sprintf( '%s/xrpc/%s', $client->host(), 'com.atproto.repo.putRecord' )
      { content => \%args }
    );
    $res->{uri} = URI->new( $res->{uri} ) if defined $res->{uri};
    $res;
  }
# /home/s/Desktop/Projects/At.pm/eg/atproto/lexicons/com/atproto/repo/strongRef.json

   use v5.38;
    no warnings 'experimental::class', 'experimental::builtin';    # Be quiet.
    use feature 'class';
    use URI;

  class At::Lexicon::com::atproto::repo::strongRef::main {
    field $cid :param;
    field $uri :param;

    ADJUST{} # TODO: handle types such as string maxlen, etc.

    # perlclass does not have :reader yet
    method cid{ $cid };
    method uri{ $uri };

    method _raw() {{
        cid => $cid,
        uri => $uri,
    }}
  }
# /home/s/Desktop/Projects/At.pm/eg/atproto/lexicons/com/atproto/repo/uploadBlob.json

   use v5.38;
    no warnings 'experimental::class', 'experimental::builtin';    # Be quiet.
    use feature 'class';
    use URI;

  method uploadBlob (%args){
    use Carp qw[confess];
    $client->http->session // confess 'creating a post requires an authenticated client';
# trash.pl:52: {
#   description => "Upload a new blob to be added to repo in a later request.",
#   input => { encoding => "*/*" },
#   output => {
#     encoding => "application/json",
#     schema   => {
#                   properties => { blob => { type => "blob" } },
#                   required => ["blob"],
#                   type => "object",
#                 },
#   },
#   type => "procedure",
# }
    my $res = $client->http->post( sprintf( '%s/xrpc/%s', $client->host(), 'com.atproto.repo.uploadBlob' )
      { content => \%args }
    );
    $res->{uri} = URI->new( $res->{uri} ) if defined $res->{uri};
    $res;
  }
# /home/s/Desktop/Projects/At.pm/eg/atproto/lexicons/com/atproto/server/confirmEmail.json

   use v5.38;
    no warnings 'experimental::class', 'experimental::builtin';    # Be quiet.
    use feature 'class';
    use URI;

  method confirmEmail (%args){
    use Carp qw[confess];
    $client->http->session // confess 'creating a post requires an authenticated client';
# trash.pl:52: {
#   description => "Confirm an email using a token from com.atproto.server.requestEmailConfirmation.",
#   errors => [
#     { name => "AccountNotFound" },
#     { name => "ExpiredToken" },
#     { name => "InvalidToken" },
#     { name => "InvalidEmail" },
#   ],
#   input => {
#     encoding => "application/json",
#     schema   => {
#                   properties => { email => { type => "string" }, token => { type => "string" } },
#                   required => ["email", "token"],
#                   type => "object",
#                 },
#   },
#   type => "procedure",
# }
    confess $_ . ' is a required parameter' for 'email', 'token';
    my $res = $client->http->post( sprintf( '%s/xrpc/%s', $client->host(), 'com.atproto.server.confirmEmail' )
      { content => \%args }
    );
    $res->{uri} = URI->new( $res->{uri} ) if defined $res->{uri};
    $res;
  }
# /home/s/Desktop/Projects/At.pm/eg/atproto/lexicons/com/atproto/server/createAccount.json

   use v5.38;
    no warnings 'experimental::class', 'experimental::builtin';    # Be quiet.
    use feature 'class';
    use URI;

  method createAccount (%args){
    use Carp qw[confess];
    $client->http->session // confess 'creating a post requires an authenticated client';
# trash.pl:52: {
#   description => "Create an account.",
#   errors      => [
#                    { name => "InvalidHandle" },
#                    { name => "InvalidPassword" },
#                    { name => "InvalidInviteCode" },
#                    { name => "HandleNotAvailable" },
#                    { name => "UnsupportedDomain" },
#                    { name => "UnresolvableDid" },
#                    { name => "IncompatibleDidDoc" },
#                  ],
#   input       => {
#                    encoding => "application/json",
#                    schema   => {
#                                  properties => {
#                                    did => { format => "did", type => "string" },
#                                    email => { type => "string" },
#                                    handle => { format => "handle", type => "string" },
#                                    inviteCode => { type => "string" },
#                                    password => { type => "string" },
#                                    plcOp => { type => "unknown" },
#                                    recoveryKey => { type => "string" },
#                                  },
#                                  required => ["handle"],
#                                  type => "object",
#                                },
#                  },
#   output      => {
#                    encoding => "application/json",
#                    schema   => {
#                                  properties => {
#                                    accessJwt => { type => "string" },
#                                    did => { format => "did", type => "string" },
#                                    didDoc => { type => "unknown" },
#                                    handle => { format => "handle", type => "string" },
#                                    refreshJwt => { type => "string" },
#                                  },
#                                  required => ["accessJwt", "refreshJwt", "handle", "did"],
#                                  type => "object",
#                                },
#                  },
#   type        => "procedure",
# }
    confess $_ . ' is a required parameter' for 'handle';
    my $res = $client->http->post( sprintf( '%s/xrpc/%s', $client->host(), 'com.atproto.server.createAccount' )
      { content => \%args }
    );
    $res->{uri} = URI->new( $res->{uri} ) if defined $res->{uri};
    $res;
  }
# /home/s/Desktop/Projects/At.pm/eg/atproto/lexicons/com/atproto/server/createAppPassword.json

   use v5.38;
    no warnings 'experimental::class', 'experimental::builtin';    # Be quiet.
    use feature 'class';
    use URI;

  class At::Lexicon::com::atproto::server::createAppPassword::appPassword {
    field $createdAt :param;
    field $name :param;
    field $password :param;

    ADJUST{} # TODO: handle types such as string maxlen, etc.

    # perlclass does not have :reader yet
    method createdAt{ $createdAt };
    method name{ $name };
    method password{ $password };

    method _raw() {{
        createdAt => $createdAt,
        name => $name,
        password => $password,
    }}
  }
  method createAppPassword (%args){
    use Carp qw[confess];
    $client->http->session // confess 'creating a post requires an authenticated client';
# trash.pl:52: {
#   description => "Create an App Password.",
#   errors      => [{ name => "AccountTakedown" }],
#   input       => {
#                    encoding => "application/json",
#                    schema   => {
#                                  properties => { name => { type => "string" } },
#                                  required => ["name"],
#                                  type => "object",
#                                },
#                  },
#   output      => {
#                    encoding => "application/json",
#                    schema   => { ref => "#appPassword", type => "ref" },
#                  },
#   type        => "procedure",
# }
    confess $_ . ' is a required parameter' for 'name';
    my $res = $client->http->post( sprintf( '%s/xrpc/%s', $client->host(), 'com.atproto.server.createAppPassword' )
      { content => \%args }
    );
    $res->{uri} = URI->new( $res->{uri} ) if defined $res->{uri};
    $res;
  }
# /home/s/Desktop/Projects/At.pm/eg/atproto/lexicons/com/atproto/server/createInviteCode.json

   use v5.38;
    no warnings 'experimental::class', 'experimental::builtin';    # Be quiet.
    use feature 'class';
    use URI;

  method createInviteCode (%args){
    use Carp qw[confess];
    $client->http->session // confess 'creating a post requires an authenticated client';
# trash.pl:52: {
#   description => "Create an invite code.",
#   input => {
#     encoding => "application/json",
#     schema   => {
#                   properties => {
#                     forAccount => { format => "did", type => "string" },
#                     useCount   => { type => "integer" },
#                   },
#                   required => ["useCount"],
#                   type => "object",
#                 },
#   },
#   output => {
#     encoding => "application/json",
#     schema   => {
#                   properties => { code => { type => "string" } },
#                   required => ["code"],
#                   type => "object",
#                 },
#   },
#   type => "procedure",
# }
    confess $_ . ' is a required parameter' for 'useCount';
    my $res = $client->http->post( sprintf( '%s/xrpc/%s', $client->host(), 'com.atproto.server.createInviteCode' )
      { content => \%args }
    );
    $res->{uri} = URI->new( $res->{uri} ) if defined $res->{uri};
    $res;
  }
# /home/s/Desktop/Projects/At.pm/eg/atproto/lexicons/com/atproto/server/createInviteCodes.json

   use v5.38;
    no warnings 'experimental::class', 'experimental::builtin';    # Be quiet.
    use feature 'class';
    use URI;

  class At::Lexicon::com::atproto::server::createInviteCodes::accountCodes {
    field $codes :param;
    field $account :param;

    ADJUST{} # TODO: handle types such as string maxlen, etc.

    # perlclass does not have :reader yet
    method codes{ $codes };
    method account{ $account };

    method _raw() {{
        codes => $codes,
        account => $account,
    }}
  }
  method createInviteCodes (%args){
    use Carp qw[confess];
    $client->http->session // confess 'creating a post requires an authenticated client';
# trash.pl:52: {
#   description => "Create invite codes.",
#   input => {
#     encoding => "application/json",
#     schema   => {
#                   properties => {
#                     codeCount   => { default => 1, type => "integer" },
#                     forAccounts => { items => { format => "did", type => "string" }, type => "array" },
#                     useCount    => { type => "integer" },
#                   },
#                   required => ["codeCount", "useCount"],
#                   type => "object",
#                 },
#   },
#   output => {
#     encoding => "application/json",
#     schema   => {
#                   properties => {
#                     codes => { items => { ref => "#accountCodes", type => "ref" }, type => "array" },
#                   },
#                   required => ["codes"],
#                   type => "object",
#                 },
#   },
#   type => "procedure",
# }
    confess $_ . ' is a required parameter' for 'codeCount', 'useCount';
    my $res = $client->http->post( sprintf( '%s/xrpc/%s', $client->host(), 'com.atproto.server.createInviteCodes' )
      { content => \%args }
    );
    $res->{uri} = URI->new( $res->{uri} ) if defined $res->{uri};
    $res;
  }
# /home/s/Desktop/Projects/At.pm/eg/atproto/lexicons/com/atproto/server/createSession.json

   use v5.38;
    no warnings 'experimental::class', 'experimental::builtin';    # Be quiet.
    use feature 'class';
    use URI;

  method createSession (%args){
    use Carp qw[confess];
    $client->http->session // confess 'creating a post requires an authenticated client';
# trash.pl:52: {
#   description => "Create an authentication session.",
#   errors      => [{ name => "AccountTakedown" }],
#   input       => {
#                    encoding => "application/json",
#                    schema   => {
#                                  properties => {
#                                    identifier => {
#                                                    description => "Handle or other identifier supported by the server for the authenticating user.",
#                                                    type => "string",
#                                                  },
#                                    password   => { type => "string" },
#                                  },
#                                  required => ["identifier", "password"],
#                                  type => "object",
#                                },
#                  },
#   output      => {
#                    encoding => "application/json",
#                    schema   => {
#                                  properties => {
#                                    accessJwt => { type => "string" },
#                                    did => { format => "did", type => "string" },
#                                    didDoc => { type => "unknown" },
#                                    email => { type => "string" },
#                                    emailConfirmed => { type => "boolean" },
#                                    handle => { format => "handle", type => "string" },
#                                    refreshJwt => { type => "string" },
#                                  },
#                                  required => ["accessJwt", "refreshJwt", "handle", "did"],
#                                  type => "object",
#                                },
#                  },
#   type        => "procedure",
# }
    confess $_ . ' is a required parameter' for 'identifier', 'password';
    my $res = $client->http->post( sprintf( '%s/xrpc/%s', $client->host(), 'com.atproto.server.createSession' )
      { content => \%args }
    );
    $res->{uri} = URI->new( $res->{uri} ) if defined $res->{uri};
    $res;
  }
# /home/s/Desktop/Projects/At.pm/eg/atproto/lexicons/com/atproto/server/defs.json

   use v5.38;
    no warnings 'experimental::class', 'experimental::builtin';    # Be quiet.
    use feature 'class';
    use URI;

  class At::Lexicon::com::atproto::server::defs::inviteCode {
    field $code :param;
    field $createdAt :param;
    field $forAccount :param;
    field $uses :param;
    field $disabled :param;
    field $createdBy :param;
    field $available :param;

    ADJUST{} # TODO: handle types such as string maxlen, etc.

    # perlclass does not have :reader yet
    method code{ $code };
    method createdAt{ $createdAt };
    method forAccount{ $forAccount };
    method uses{ $uses };
    method disabled{ $disabled };
    method createdBy{ $createdBy };
    method available{ $available };

    method _raw() {{
        code => $code,
        createdAt => $createdAt,
        forAccount => $forAccount,
        uses => $uses,
        disabled => $disabled,
        createdBy => $createdBy,
        available => $available,
    }}
  }
  class At::Lexicon::com::atproto::server::defs::inviteCodeUse {
    field $usedAt :param;
    field $usedBy :param;

    ADJUST{} # TODO: handle types such as string maxlen, etc.

    # perlclass does not have :reader yet
    method usedAt{ $usedAt };
    method usedBy{ $usedBy };

    method _raw() {{
        usedAt => $usedAt,
        usedBy => $usedBy,
    }}
  }
# /home/s/Desktop/Projects/At.pm/eg/atproto/lexicons/com/atproto/server/deleteAccount.json

   use v5.38;
    no warnings 'experimental::class', 'experimental::builtin';    # Be quiet.
    use feature 'class';
    use URI;

  method deleteAccount (%args){
    use Carp qw[confess];
    $client->http->session // confess 'creating a post requires an authenticated client';
# trash.pl:52: {
#   description => "Delete an actor's account with a token and password.",
#   errors => [{ name => "ExpiredToken" }, { name => "InvalidToken" }],
#   input => {
#     encoding => "application/json",
#     schema   => {
#                   properties => {
#                     did => { format => "did", type => "string" },
#                     password => { type => "string" },
#                     token => { type => "string" },
#                   },
#                   required => ["did", "password", "token"],
#                   type => "object",
#                 },
#   },
#   type => "procedure",
# }
    confess $_ . ' is a required parameter' for 'did', 'password', 'token';
    my $res = $client->http->post( sprintf( '%s/xrpc/%s', $client->host(), 'com.atproto.server.deleteAccount' )
      { content => \%args }
    );
    $res->{uri} = URI->new( $res->{uri} ) if defined $res->{uri};
    $res;
  }
# /home/s/Desktop/Projects/At.pm/eg/atproto/lexicons/com/atproto/server/deleteSession.json

   use v5.38;
    no warnings 'experimental::class', 'experimental::builtin';    # Be quiet.
    use feature 'class';
    use URI;

  method deleteSession(){
    use Carp qw[confess];
    $client->http->session // confess 'creating a post requires an authenticated client';
# trash.pl:52: { description => "Delete the current session.", type => "procedure" }
    my $res = $client->http->post( sprintf( '%s/xrpc/%s', $client->host(), 'com.atproto.server.deleteSession' )
    );
    $res->{uri} = URI->new( $res->{uri} ) if defined $res->{uri};
    $res;
  }
# /home/s/Desktop/Projects/At.pm/eg/atproto/lexicons/com/atproto/server/describeServer.json

   use v5.38;
    no warnings 'experimental::class', 'experimental::builtin';    # Be quiet.
    use feature 'class';
    use URI;

  class At::Lexicon::com::atproto::server::describeServer::links {
    field $privacyPolicy :param = ();
    field $termsOfService :param = ();

    ADJUST{} # TODO: handle types such as string maxlen, etc.

    # perlclass does not have :reader yet
    method privacyPolicy{ $privacyPolicy };
    method termsOfService{ $termsOfService };

    method _raw() {{
        privacyPolicy => $privacyPolicy,
        termsOfService => $termsOfService,
    }}
  }
# trash.pl:109: {
#   description => "Get a document describing the service's accounts configuration.",
#   output => {
#     encoding => "application/json",
#     schema   => {
#                   properties => {
#                     availableUserDomains => { items => { type => "string" }, type => "array" },
#                     inviteCodeRequired => { type => "boolean" },
#                     links => { ref => "#links", type => "ref" },
#                   },
#                   required => ["availableUserDomains"],
#                   type => "object",
#                 },
#   },
#   type => "query",
# }
# /home/s/Desktop/Projects/At.pm/eg/atproto/lexicons/com/atproto/server/getAccountInviteCodes.json

   use v5.38;
    no warnings 'experimental::class', 'experimental::builtin';    # Be quiet.
    use feature 'class';
    use URI;

# trash.pl:109: do {
#   my $a = {
#     description => "Get all invite codes for a given account.",
#     errors => [{ name => "DuplicateCreate" }],
#     output => {
#       encoding => "application/json",
#       schema   => {
#                     properties => {
#                       codes => {
#                         items => { ref => "com.atproto.server.defs#inviteCode", type => "ref" },
#                         type  => "array",
#                       },
#                     },
#                     required => ["codes"],
#                     type => "object",
#                   },
#     },
#     parameters => {
#       properties => {
#         createAvailable => {
#                              default => bless(do{\(my $o = 1)}, "JSON::Tiny::_Bool"),
#                              type => "boolean",
#                            },
#         includeUsed     => { default => 'fix', type => "boolean" },
#       },
#       type => "params",
#     },
#     type => "query",
#   };
#   $a->{parameters}{properties}{includeUsed}{default} = \${$a->{parameters}{properties}{createAvailable}{default}};
#   $a;
# }
# /home/s/Desktop/Projects/At.pm/eg/atproto/lexicons/com/atproto/server/getSession.json

   use v5.38;
    no warnings 'experimental::class', 'experimental::builtin';    # Be quiet.
    use feature 'class';
    use URI;

# trash.pl:109: {
#   description => "Get information about the current session.",
#   output => {
#     encoding => "application/json",
#     schema   => {
#                   properties => {
#                     did => { format => "did", type => "string" },
#                     didDoc => { type => "unknown" },
#                     email => { type => "string" },
#                     emailConfirmed => { type => "boolean" },
#                     handle => { format => "handle", type => "string" },
#                   },
#                   required => ["handle", "did"],
#                   type => "object",
#                 },
#   },
#   type => "query",
# }
# /home/s/Desktop/Projects/At.pm/eg/atproto/lexicons/com/atproto/server/listAppPasswords.json

   use v5.38;
    no warnings 'experimental::class', 'experimental::builtin';    # Be quiet.
    use feature 'class';
    use URI;

  class At::Lexicon::com::atproto::server::listAppPasswords::appPassword {
    field $createdAt :param;
    field $name :param;

    ADJUST{} # TODO: handle types such as string maxlen, etc.

    # perlclass does not have :reader yet
    method createdAt{ $createdAt };
    method name{ $name };

    method _raw() {{
        createdAt => $createdAt,
        name => $name,
    }}
  }
# trash.pl:109: {
#   description => "List all App Passwords.",
#   errors => [{ name => "AccountTakedown" }],
#   output => {
#     encoding => "application/json",
#     schema   => {
#                   properties => {
#                     passwords => { items => { ref => "#appPassword", type => "ref" }, type => "array" },
#                   },
#                   required => ["passwords"],
#                   type => "object",
#                 },
#   },
#   type => "query",
# }
# /home/s/Desktop/Projects/At.pm/eg/atproto/lexicons/com/atproto/server/refreshSession.json

   use v5.38;
    no warnings 'experimental::class', 'experimental::builtin';    # Be quiet.
    use feature 'class';
    use URI;

  method refreshSession(){
    use Carp qw[confess];
    $client->http->session // confess 'creating a post requires an authenticated client';
# trash.pl:52: {
#   description => "Refresh an authentication session.",
#   errors => [{ name => "AccountTakedown" }],
#   output => {
#     encoding => "application/json",
#     schema   => {
#                   properties => {
#                     accessJwt => { type => "string" },
#                     did => { format => "did", type => "string" },
#                     didDoc => { type => "unknown" },
#                     handle => { format => "handle", type => "string" },
#                     refreshJwt => { type => "string" },
#                   },
#                   required => ["accessJwt", "refreshJwt", "handle", "did"],
#                   type => "object",
#                 },
#   },
#   type => "procedure",
# }
    my $res = $client->http->post( sprintf( '%s/xrpc/%s', $client->host(), 'com.atproto.server.refreshSession' )
    );
    $res->{uri} = URI->new( $res->{uri} ) if defined $res->{uri};
    $res;
  }
# /home/s/Desktop/Projects/At.pm/eg/atproto/lexicons/com/atproto/server/requestAccountDelete.json

   use v5.38;
    no warnings 'experimental::class', 'experimental::builtin';    # Be quiet.
    use feature 'class';
    use URI;

  method requestAccountDelete(){
    use Carp qw[confess];
    $client->http->session // confess 'creating a post requires an authenticated client';
# trash.pl:52: {
#   description => "Initiate a user account deletion via email.",
#   type => "procedure",
# }
    my $res = $client->http->post( sprintf( '%s/xrpc/%s', $client->host(), 'com.atproto.server.requestAccountDelete' )
    );
    $res->{uri} = URI->new( $res->{uri} ) if defined $res->{uri};
    $res;
  }
# /home/s/Desktop/Projects/At.pm/eg/atproto/lexicons/com/atproto/server/requestEmailConfirmation.json

   use v5.38;
    no warnings 'experimental::class', 'experimental::builtin';    # Be quiet.
    use feature 'class';
    use URI;

  method requestEmailConfirmation(){
    use Carp qw[confess];
    $client->http->session // confess 'creating a post requires an authenticated client';
# trash.pl:52: {
#   description => "Request an email with a code to confirm ownership of email.",
#   type => "procedure",
# }
    my $res = $client->http->post( sprintf( '%s/xrpc/%s', $client->host(), 'com.atproto.server.requestEmailConfirmation' )
    );
    $res->{uri} = URI->new( $res->{uri} ) if defined $res->{uri};
    $res;
  }
# /home/s/Desktop/Projects/At.pm/eg/atproto/lexicons/com/atproto/server/requestEmailUpdate.json

   use v5.38;
    no warnings 'experimental::class', 'experimental::builtin';    # Be quiet.
    use feature 'class';
    use URI;

  method requestEmailUpdate(){
    use Carp qw[confess];
    $client->http->session // confess 'creating a post requires an authenticated client';
# trash.pl:52: {
#   description => "Request a token in order to update email.",
#   output => {
#     encoding => "application/json",
#     schema   => {
#                   properties => { tokenRequired => { type => "boolean" } },
#                   required => ["tokenRequired"],
#                   type => "object",
#                 },
#   },
#   type => "procedure",
# }
    my $res = $client->http->post( sprintf( '%s/xrpc/%s', $client->host(), 'com.atproto.server.requestEmailUpdate' )
    );
    $res->{uri} = URI->new( $res->{uri} ) if defined $res->{uri};
    $res;
  }
# /home/s/Desktop/Projects/At.pm/eg/atproto/lexicons/com/atproto/server/requestPasswordReset.json

   use v5.38;
    no warnings 'experimental::class', 'experimental::builtin';    # Be quiet.
    use feature 'class';
    use URI;

  method requestPasswordReset (%args){
    use Carp qw[confess];
    $client->http->session // confess 'creating a post requires an authenticated client';
# trash.pl:52: {
#   description => "Initiate a user account password reset via email.",
#   input => {
#     encoding => "application/json",
#     schema   => {
#                   properties => { email => { type => "string" } },
#                   required => ["email"],
#                   type => "object",
#                 },
#   },
#   type => "procedure",
# }
    confess $_ . ' is a required parameter' for 'email';
    my $res = $client->http->post( sprintf( '%s/xrpc/%s', $client->host(), 'com.atproto.server.requestPasswordReset' )
      { content => \%args }
    );
    $res->{uri} = URI->new( $res->{uri} ) if defined $res->{uri};
    $res;
  }
# /home/s/Desktop/Projects/At.pm/eg/atproto/lexicons/com/atproto/server/reserveSigningKey.json

   use v5.38;
    no warnings 'experimental::class', 'experimental::builtin';    # Be quiet.
    use feature 'class';
    use URI;

  method reserveSigningKey (%args){
    use Carp qw[confess];
    $client->http->session // confess 'creating a post requires an authenticated client';
# trash.pl:52: {
#   description => "Reserve a repo signing key for account creation.",
#   input => {
#     encoding => "application/json",
#     schema   => {
#                   properties => {
#                     did => {
#                              description => "The did to reserve a new did:key for",
#                              type => "string",
#                            },
#                   },
#                   type => "object",
#                 },
#   },
#   output => {
#     encoding => "application/json",
#     schema   => {
#                   properties => {
#                     signingKey => {
#                       description => "Public signing key in the form of a did:key.",
#                       type => "string",
#                     },
#                   },
#                   required => ["signingKey"],
#                   type => "object",
#                 },
#   },
#   type => "procedure",
# }
    my $res = $client->http->post( sprintf( '%s/xrpc/%s', $client->host(), 'com.atproto.server.reserveSigningKey' )
      { content => \%args }
    );
    $res->{uri} = URI->new( $res->{uri} ) if defined $res->{uri};
    $res;
  }
# /home/s/Desktop/Projects/At.pm/eg/atproto/lexicons/com/atproto/server/resetPassword.json

   use v5.38;
    no warnings 'experimental::class', 'experimental::builtin';    # Be quiet.
    use feature 'class';
    use URI;

  method resetPassword (%args){
    use Carp qw[confess];
    $client->http->session // confess 'creating a post requires an authenticated client';
# trash.pl:52: {
#   description => "Reset a user account password using a token.",
#   errors => [{ name => "ExpiredToken" }, { name => "InvalidToken" }],
#   input => {
#     encoding => "application/json",
#     schema   => {
#                   properties => { password => { type => "string" }, token => { type => "string" } },
#                   required => ["token", "password"],
#                   type => "object",
#                 },
#   },
#   type => "procedure",
# }
    confess $_ . ' is a required parameter' for 'token', 'password';
    my $res = $client->http->post( sprintf( '%s/xrpc/%s', $client->host(), 'com.atproto.server.resetPassword' )
      { content => \%args }
    );
    $res->{uri} = URI->new( $res->{uri} ) if defined $res->{uri};
    $res;
  }
# /home/s/Desktop/Projects/At.pm/eg/atproto/lexicons/com/atproto/server/revokeAppPassword.json

   use v5.38;
    no warnings 'experimental::class', 'experimental::builtin';    # Be quiet.
    use feature 'class';
    use URI;

  method revokeAppPassword (%args){
    use Carp qw[confess];
    $client->http->session // confess 'creating a post requires an authenticated client';
# trash.pl:52: {
#   description => "Revoke an App Password by name.",
#   input => {
#     encoding => "application/json",
#     schema   => {
#                   properties => { name => { type => "string" } },
#                   required => ["name"],
#                   type => "object",
#                 },
#   },
#   type => "procedure",
# }
    confess $_ . ' is a required parameter' for 'name';
    my $res = $client->http->post( sprintf( '%s/xrpc/%s', $client->host(), 'com.atproto.server.revokeAppPassword' )
      { content => \%args }
    );
    $res->{uri} = URI->new( $res->{uri} ) if defined $res->{uri};
    $res;
  }
# /home/s/Desktop/Projects/At.pm/eg/atproto/lexicons/com/atproto/server/updateEmail.json

   use v5.38;
    no warnings 'experimental::class', 'experimental::builtin';    # Be quiet.
    use feature 'class';
    use URI;

  method updateEmail (%args){
    use Carp qw[confess];
    $client->http->session // confess 'creating a post requires an authenticated client';
# trash.pl:52: {
#   description => "Update an account's email.",
#   errors => [
#     { name => "ExpiredToken" },
#     { name => "InvalidToken" },
#     { name => "TokenRequired" },
#   ],
#   input => {
#     encoding => "application/json",
#     schema   => {
#                   properties => {
#                     email => { type => "string" },
#                     token => {
#                                description => "Requires a token from com.atproto.sever.requestEmailUpdate if the account's email has been confirmed.",
#                                type => "string",
#                              },
#                   },
#                   required => ["email"],
#                   type => "object",
#                 },
#   },
#   type => "procedure",
# }
    confess $_ . ' is a required parameter' for 'email';
    my $res = $client->http->post( sprintf( '%s/xrpc/%s', $client->host(), 'com.atproto.server.updateEmail' )
      { content => \%args }
    );
    $res->{uri} = URI->new( $res->{uri} ) if defined $res->{uri};
    $res;
  }
# /home/s/Desktop/Projects/At.pm/eg/atproto/lexicons/com/atproto/sync/getBlob.json

   use v5.38;
    no warnings 'experimental::class', 'experimental::builtin';    # Be quiet.
    use feature 'class';
    use URI;

# trash.pl:109: {
#   description => "Get a blob associated with a given repo.",
#   output => { encoding => "*/*" },
#   parameters => {
#     properties => {
#       cid => {
#                description => "The CID of the blob to fetch",
#                format => "cid",
#                type => "string",
#              },
#       did => {
#                description => "The DID of the repo.",
#                format => "did",
#                type => "string",
#              },
#     },
#     required => ["did", "cid"],
#     type => "params",
#   },
#   type => "query",
# }
# /home/s/Desktop/Projects/At.pm/eg/atproto/lexicons/com/atproto/sync/getBlocks.json

   use v5.38;
    no warnings 'experimental::class', 'experimental::builtin';    # Be quiet.
    use feature 'class';
    use URI;

# trash.pl:109: {
#   description => "Get blocks from a given repo.",
#   output => { encoding => "application/vnd.ipld.car" },
#   parameters => {
#     properties => {
#       cids => { items => { format => "cid", type => "string" }, type => "array" },
#       did  => {
#                 description => "The DID of the repo.",
#                 format => "did",
#                 type => "string",
#               },
#     },
#     required => ["did", "cids"],
#     type => "params",
#   },
#   type => "query",
# }
# /home/s/Desktop/Projects/At.pm/eg/atproto/lexicons/com/atproto/sync/getCheckout.json

   use v5.38;
    no warnings 'experimental::class', 'experimental::builtin';    # Be quiet.
    use feature 'class';
    use URI;

# trash.pl:109: {
#   description => "DEPRECATED - please use com.atproto.sync.getRepo instead",
#   output => { encoding => "application/vnd.ipld.car" },
#   parameters => {
#     properties => {
#       did => {
#                description => "The DID of the repo.",
#                format => "did",
#                type => "string",
#              },
#     },
#     required => ["did"],
#     type => "params",
#   },
#   type => "query",
# }
# /home/s/Desktop/Projects/At.pm/eg/atproto/lexicons/com/atproto/sync/getHead.json

   use v5.38;
    no warnings 'experimental::class', 'experimental::builtin';    # Be quiet.
    use feature 'class';
    use URI;

# trash.pl:109: {
#   description => "DEPRECATED - please use com.atproto.sync.getLatestCommit instead",
#   errors => [{ name => "HeadNotFound" }],
#   output => {
#     encoding => "application/json",
#     schema   => {
#                   properties => { root => { format => "cid", type => "string" } },
#                   required => ["root"],
#                   type => "object",
#                 },
#   },
#   parameters => {
#     properties => {
#       did => {
#                description => "The DID of the repo.",
#                format => "did",
#                type => "string",
#              },
#     },
#     required => ["did"],
#     type => "params",
#   },
#   type => "query",
# }
# /home/s/Desktop/Projects/At.pm/eg/atproto/lexicons/com/atproto/sync/getLatestCommit.json

   use v5.38;
    no warnings 'experimental::class', 'experimental::builtin';    # Be quiet.
    use feature 'class';
    use URI;

# trash.pl:109: {
#   description => "Get the current commit CID & revision of the repo.",
#   errors => [{ name => "RepoNotFound" }],
#   output => {
#     encoding => "application/json",
#     schema   => {
#                   properties => {
#                     cid => { format => "cid", type => "string" },
#                     rev => { type => "string" },
#                   },
#                   required => ["cid", "rev"],
#                   type => "object",
#                 },
#   },
#   parameters => {
#     properties => {
#       did => {
#                description => "The DID of the repo.",
#                format => "did",
#                type => "string",
#              },
#     },
#     required => ["did"],
#     type => "params",
#   },
#   type => "query",
# }
# /home/s/Desktop/Projects/At.pm/eg/atproto/lexicons/com/atproto/sync/getRecord.json

   use v5.38;
    no warnings 'experimental::class', 'experimental::builtin';    # Be quiet.
    use feature 'class';
    use URI;

# trash.pl:109: {
#   description => "Get blocks needed for existence or non-existence of record.",
#   output => { encoding => "application/vnd.ipld.car" },
#   parameters => {
#     properties => {
#       collection => { format => "nsid", type => "string" },
#       commit => {
#         description => "An optional past commit CID.",
#         format => "cid",
#         type => "string",
#       },
#       did => {
#         description => "The DID of the repo.",
#         format => "did",
#         type => "string",
#       },
#       rkey => { type => "string" },
#     },
#     required => ["did", "collection", "rkey"],
#     type => "params",
#   },
#   type => "query",
# }
# /home/s/Desktop/Projects/At.pm/eg/atproto/lexicons/com/atproto/sync/getRepo.json

   use v5.38;
    no warnings 'experimental::class', 'experimental::builtin';    # Be quiet.
    use feature 'class';
    use URI;

# trash.pl:109: {
#   description => "Gets the DID's repo, optionally catching up from a specific revision.",
#   output => { encoding => "application/vnd.ipld.car" },
#   parameters => {
#     properties => {
#       did => {
#         description => "The DID of the repo.",
#         format => "did",
#         type => "string",
#       },
#       since => {
#         description => "The revision of the repo to catch up from.",
#         type => "string",
#       },
#     },
#     required => ["did"],
#     type => "params",
#   },
#   type => "query",
# }
# /home/s/Desktop/Projects/At.pm/eg/atproto/lexicons/com/atproto/sync/listBlobs.json

   use v5.38;
    no warnings 'experimental::class', 'experimental::builtin';    # Be quiet.
    use feature 'class';
    use URI;

# trash.pl:109: {
#   description => "List blob CIDs since some revision.",
#   output => {
#     encoding => "application/json",
#     schema   => {
#                   properties => {
#                     cids   => { items => { format => "cid", type => "string" }, type => "array" },
#                     cursor => { type => "string" },
#                   },
#                   required => ["cids"],
#                   type => "object",
#                 },
#   },
#   parameters => {
#     properties => {
#       cursor => { type => "string" },
#       did    => {
#                   description => "The DID of the repo.",
#                   format => "did",
#                   type => "string",
#                 },
#       limit  => { default => 500, maximum => 1000, minimum => 1, type => "integer" },
#       since  => {
#                   description => "Optional revision of the repo to list blobs since.",
#                   type => "string",
#                 },
#     },
#     required => ["did"],
#     type => "params",
#   },
#   type => "query",
# }
# /home/s/Desktop/Projects/At.pm/eg/atproto/lexicons/com/atproto/sync/listRepos.json

   use v5.38;
    no warnings 'experimental::class', 'experimental::builtin';    # Be quiet.
    use feature 'class';
    use URI;

# trash.pl:109: {
#   description => "List DIDs and root CIDs of hosted repos.",
#   output => {
#     encoding => "application/json",
#     schema   => {
#                   properties => {
#                     cursor => { type => "string" },
#                     repos  => { items => { ref => "#repo", type => "ref" }, type => "array" },
#                   },
#                   required => ["repos"],
#                   type => "object",
#                 },
#   },
#   parameters => {
#     properties => {
#       cursor => { type => "string" },
#       limit  => { default => 500, maximum => 1000, minimum => 1, type => "integer" },
#     },
#     type => "params",
#   },
#   type => "query",
# }
  class At::Lexicon::com::atproto::sync::listRepos::repo {
    field $did :param;
    field $head :param;
    field $rev :param;

    ADJUST{} # TODO: handle types such as string maxlen, etc.

    # perlclass does not have :reader yet
    method did{ $did };
    method head{ $head };
    method rev{ $rev };

    method _raw() {{
        did => $did,
        head => $head,
        rev => $rev,
    }}
  }
# /home/s/Desktop/Projects/At.pm/eg/atproto/lexicons/com/atproto/sync/notifyOfUpdate.json

   use v5.38;
    no warnings 'experimental::class', 'experimental::builtin';    # Be quiet.
    use feature 'class';
    use URI;

  method notifyOfUpdate (%args){
    use Carp qw[confess];
    $client->http->session // confess 'creating a post requires an authenticated client';
# trash.pl:52: {
#   description => "Notify a crawling service of a recent update; often when a long break between updates causes the connection with the crawling service to break.",
#   input => {
#     encoding => "application/json",
#     schema   => {
#                   properties => {
#                     hostname => {
#                       description => "Hostname of the service that is notifying of update.",
#                       type => "string",
#                     },
#                   },
#                   required => ["hostname"],
#                   type => "object",
#                 },
#   },
#   type => "procedure",
# }
    confess $_ . ' is a required parameter' for 'hostname';
    my $res = $client->http->post( sprintf( '%s/xrpc/%s', $client->host(), 'com.atproto.sync.notifyOfUpdate' )
      { content => \%args }
    );
    $res->{uri} = URI->new( $res->{uri} ) if defined $res->{uri};
    $res;
  }
# /home/s/Desktop/Projects/At.pm/eg/atproto/lexicons/com/atproto/sync/requestCrawl.json

   use v5.38;
    no warnings 'experimental::class', 'experimental::builtin';    # Be quiet.
    use feature 'class';
    use URI;

  method requestCrawl (%args){
    use Carp qw[confess];
    $client->http->session // confess 'creating a post requires an authenticated client';
# trash.pl:52: {
#   description => "Request a service to persistently crawl hosted repos.",
#   input => {
#     encoding => "application/json",
#     schema   => {
#                   properties => {
#                     hostname => {
#                       description => "Hostname of the service that is requesting to be crawled.",
#                       type => "string",
#                     },
#                   },
#                   required => ["hostname"],
#                   type => "object",
#                 },
#   },
#   type => "procedure",
# }
    confess $_ . ' is a required parameter' for 'hostname';
    my $res = $client->http->post( sprintf( '%s/xrpc/%s', $client->host(), 'com.atproto.sync.requestCrawl' )
      { content => \%args }
    );
    $res->{uri} = URI->new( $res->{uri} ) if defined $res->{uri};
    $res;
  }
# /home/s/Desktop/Projects/At.pm/eg/atproto/lexicons/com/atproto/sync/subscribeRepos.json

   use v5.38;
    no warnings 'experimental::class', 'experimental::builtin';    # Be quiet.
    use feature 'class';
    use URI;

# trash.pl:109: {
#   description => "Subscribe to repo updates.",
#   errors => [{ name => "FutureCursor" }, { name => "ConsumerTooSlow" }],
#   message => {
#     schema => {
#       refs => ["#commit", "#handle", "#migrate", "#tombstone", "#info"],
#       type => "union",
#     },
#   },
#   parameters => {
#     properties => {
#       cursor => {
#         description => "The last known event to backfill from.",
#         type => "integer",
#       },
#     },
#     type => "params",
#   },
#   type => "subscription",
# }
  class At::Lexicon::com::atproto::sync::subscribeRepos::tombstone {
    field $time :param;
    field $did :param;
    field $seq :param;

    ADJUST{} # TODO: handle types such as string maxlen, etc.

    # perlclass does not have :reader yet
    method time{ $time };
    method did{ $did };
    method seq{ $seq };

    method _raw() {{
        time => $time,
        did => $did,
        seq => $seq,
    }}
  }
  class At::Lexicon::com::atproto::sync::subscribeRepos::info {
    field $name :param;
    field $message :param = ();

    ADJUST{} # TODO: handle types such as string maxlen, etc.

    # perlclass does not have :reader yet
    method name{ $name };
    method message{ $message };

    method _raw() {{
        name => $name,
        message => $message,
    }}
  }
  class At::Lexicon::com::atproto::sync::subscribeRepos::handle {
    field $seq :param;
    field $did :param;
    field $handle :param;
    field $time :param;

    ADJUST{} # TODO: handle types such as string maxlen, etc.

    # perlclass does not have :reader yet
    method seq{ $seq };
    method did{ $did };
    method handle{ $handle };
    method time{ $time };

    method _raw() {{
        seq => $seq,
        did => $did,
        handle => $handle,
        time => $time,
    }}
  }
  class At::Lexicon::com::atproto::sync::subscribeRepos::commit {
    field $since :param;
    field $prev :param = ();
    field $blobs :param;
    field $rebase :param;
    field $seq :param;
    field $blocks :param;
    field $time :param;
    field $repo :param;
    field $rev :param;
    field $tooBig :param;
    field $ops :param;
    field $commit :param;

    ADJUST{} # TODO: handle types such as string maxlen, etc.

    # perlclass does not have :reader yet
    method since{ $since };
    method prev{ $prev };
    method blobs{ $blobs };
    method rebase{ $rebase };
    method seq{ $seq };
    method blocks{ $blocks };
    method time{ $time };
    method repo{ $repo };
    method rev{ $rev };
    method tooBig{ $tooBig };
    method ops{ $ops };
    method commit{ $commit };

    method _raw() {{
        since => $since,
        prev => $prev,
        blobs => $blobs,
        rebase => $rebase,
        seq => $seq,
        blocks => $blocks,
        time => $time,
        repo => $repo,
        rev => $rev,
        tooBig => $tooBig,
        ops => $ops,
        commit => $commit,
    }}
  }
  class At::Lexicon::com::atproto::sync::subscribeRepos::migrate {
    field $time :param;
    field $did :param;
    field $migrateTo :param;
    field $seq :param;

    ADJUST{} # TODO: handle types such as string maxlen, etc.

    # perlclass does not have :reader yet
    method time{ $time };
    method did{ $did };
    method migrateTo{ $migrateTo };
    method seq{ $seq };

    method _raw() {{
        time => $time,
        did => $did,
        migrateTo => $migrateTo,
        seq => $seq,
    }}
  }
  class At::Lexicon::com::atproto::sync::subscribeRepos::repoOp {
    field $action :param;
    field $cid :param;
    field $path :param;

    ADJUST{} # TODO: handle types such as string maxlen, etc.

    # perlclass does not have :reader yet
    method action{ $action };
    method cid{ $cid };
    method path{ $path };

    method _raw() {{
        action => $action,
        cid => $cid,
        path => $path,
    }}
  }
# /home/s/Desktop/Projects/At.pm/eg/atproto/lexicons/com/atproto/temp/fetchLabels.json

   use v5.38;
    no warnings 'experimental::class', 'experimental::builtin';    # Be quiet.
    use feature 'class';
    use URI;

# trash.pl:109: {
#   description => "Fetch all labels from a labeler created after a certain date.",
#   output => {
#     encoding => "application/json",
#     schema   => {
#                   properties => {
#                     labels => {
#                       items => { ref => "com.atproto.label.defs#label", type => "ref" },
#                       type  => "array",
#                     },
#                   },
#                   required => ["labels"],
#                   type => "object",
#                 },
#   },
#   parameters => {
#     properties => {
#       limit => { default => 50, maximum => 250, minimum => 1, type => "integer" },
#       since => { type => "integer" },
#     },
#     type => "params",
#   },
#   type => "query",
# }
