package At::Lexicon::app::bsky::feed 0.02 {
    use v5.38;
    no warnings 'experimental::class', 'experimental::builtin';    # Be quiet.
    use feature 'class';
    use bytes;
    our @CARP_NOT;
    use At::Lexicon::app::bsky::richtext;
    #
    # trash.pl:205: {
    #   properties => {
    #     author      => { ref => "app.bsky.actor.defs#profileViewBasic", type => "ref" },
    #     cid         => { format => "cid", type => "string" },
    #     embed       => {
    #                      refs => [
    #                                "app.bsky.embed.images#view",
    #                                "app.bsky.embed.external#view",
    #                                "app.bsky.embed.record#view",
    #                                "app.bsky.embed.recordWithMedia#view",
    #                              ],
    #                      type => "union",
    #                    },
    #     indexedAt   => { format => "datetime", type => "string" },
    #     labels      => {
    #                      items => { ref => "com.atproto.label.defs#label", type => "ref" },
    #                      type  => "array",
    #                    },
    #     likeCount   => { type => "integer" },
    #     record      => { type => "unknown" },
    #     replyCount  => { type => "integer" },
    #     repostCount => { type => "integer" },
    #     threadgate  => { ref => "#threadgateView", type => "ref" },
    #     uri         => { format => "at-uri", type => "string" },
    #     viewer      => { ref => "#viewerState", type => "ref" },
    #   },
    #   required => ["uri", "cid", "author", "record", "indexedAt"],
    #   type => "object",
    # }
    class At::Lexicon::app::bsky::feed::postView {

        # trash.pl:240: { ref => "app.bsky.actor.defs#profileViewBasic", type => "ref" }
        field $author : param;    # ::actor::profileViewBasic, required
        field $cid : param;       # cid, required

        # here at trash.pl line 239.
        # trash.pl:240: {
        #   refs => [
        #             "app.bsky.embed.images#view",
        #             "app.bsky.embed.external#view",
        #             "app.bsky.embed.record#view",
        #             "app.bsky.embed.recordWithMedia#view",
        #           ],
        #   type => "union",
        # }
        field $embed : param = ();
        field $indexedAt : param;    # datetime, required

        # here at trash.pl line 239.
        # trash.pl:240: {
        #   items => { ref => "com.atproto.label.defs#label", type => "ref" },
        #   type  => "array",
        # }
        field $labels : param    = ();
        field $likeCount : param = ();      # int
        field $record : param;              # unknown
        field $replyCount : param  = ();    # int
        field $repostCount : param = ();    # int

        # here at trash.pl line 239.
        # trash.pl:240: { ref => "#threadgateView", type => "ref" }
        field $threadgate : param = ();
        field $uri : param;    # at-uri, required

        # trash.pl:240: { ref => "#viewerState", type => "ref" }
        field $viewer : param = ();
        ADJUST {
            # trash.pl:92: { ref => "app.bsky.actor.defs#profileViewBasic", type => "ref" }
            # trash.pl:86: { type => "integer" }
            # trash.pl:86: { type => "integer" }
            # trash.pl:86: { type => "integer" }
            # trash.pl:92: { ref => "#viewerState", type => "ref" }
            # trash.pl:180: { type => "unknown" }
            # trash.pl:99: { format => "datetime", type => "string" }
            $indexedAt = At::Protocol::Timestamp->new( timestamp => $indexedAt ) unless builtin::blessed $indexedAt;

            # trash.pl:99: { format => "cid", type => "string" }
            $labels = [ map { $_ = At::Lexicon::app::atproto::label->new(%$_) unless builtin::blessed $_ } @$labels ] if defined $labels;

            # trash.pl:92: { ref => "#threadgateView", type => "ref" }
            # trash.pl:173: {
            #   refs => [
            #             "app.bsky.embed.images#view",
            #             "app.bsky.embed.external#view",
            #             "app.bsky.embed.record#view",
            #             "app.bsky.embed.recordWithMedia#view",
            #           ],
            #   type => "union",
            # }
            # Todo: union        $embed;
            # trash.pl:99: { format => "at-uri", type => "string" }
            $uri = URI->new($uri) unless builtin::blessed $uri;
        }

        # perlclass does not have :reader yet
        method author      {$author}
        method replyCount  {$replyCount}
        method likeCount   {$likeCount}
        method repostCount {$repostCount}
        method viewer      {$viewer}
        method record      {$record}
        method indexedAt   {$indexedAt}
        method cid         {$cid}
        method labels      {$labels}
        method threadgate  {$threadgate}
        method embed       {$embed}
        method uri         {$uri}

        method _raw() {
            {   author     => $author->_raw,
                replyCount => $replyCount,

                # trash.pl:281: { type => "integer" }
                likeCount => $likeCount,

                # trash.pl:281: { type => "integer" }
                repostCount => $repostCount,

                # trash.pl:281: { type => "integer" }
                viewer => $viewer->_raw,
                record => $record,

                # trash.pl:281: { type => "unknown" }
                indexedAt => $indexedAt->as_string,
                cid       => $cid->as_string,
                defined $labels ? ( labels => [ map { $_->_raw } @$labels ] ) : (),

                # trash.pl:281: {
                #   items => { ref => "com.atproto.label.defs#label", type => "ref" },
                #   type  => "array",
                # }
                threadgate => $threadgate->_raw,
                embed      => $embed,

                # trash.pl:281: {
                #   refs => [
                #             "app.bsky.embed.images#view",
                #             "app.bsky.embed.external#view",
                #             "app.bsky.embed.record#view",
                #             "app.bsky.embed.recordWithMedia#view",
                #           ],
                #   type => "union",
                # }
                uri => $uri->as_string,
            }
        }
    }
# app.bsky.feed.defs at trash.pl line 204.
# trash.pl:205: {
#   properties => {
#     did => { format => "did", type => "string" },
#     viewer => { ref => "app.bsky.actor.defs#viewerState", type => "ref" },
#   },
#   required => ["did"],
#   type => "object",
# }
class At::Lexicon::app::bsky::feed::blockedAuthor {

    # here at trash.pl line 239.
    # trash.pl:240: { format => "did", type => "string" }
    field $did : param;

    # here at trash.pl line 239.
    # trash.pl:240: { ref => "app.bsky.actor.defs#viewerState", type => "ref" }
    field $viewer : param = ();
    ADJUST {    # TODO: handle types such as string maxlen, etc.

        # trash.pl:99: { format => "did", type => "string" }
        $did = At::Protocol::DID->new( uri => $did ) unless builtin::blessed $did;

        # trash.pl:92: { ref => "app.bsky.actor.defs#viewerState", type => "ref" }
    }

    # perlclass does not have :reader yet
    method did    {$did}
    method viewer {$viewer}

    method _raw() {
        { did => $did->as_string, viewer => $viewer->_raw, }
    }
}

# app.bsky.feed.defs at trash.pl line 204.
# trash.pl:205: {
#   properties => {
#     author => { ref => "#blockedAuthor", type => "ref" },
#     blocked => {
#       const => bless(do{\(my $o = 1)}, "JSON::Tiny::_Bool"),
#       type  => "boolean",
#     },
#     uri => { format => "at-uri", type => "string" },
#   },
#   required => ["uri", "blocked", "author"],
#   type => "object",
# }
class At::Lexicon::app::bsky::feed::blockedPost {

    # here at trash.pl line 239.
    # trash.pl:240: { ref => "#blockedAuthor", type => "ref" }
    field $author : param;

    # here at trash.pl line 239.
    # trash.pl:240: { format => "at-uri", type => "string" }
    field $uri : param;

    # here at trash.pl line 239.
    # trash.pl:240: {
    #   const => bless(do{\(my $o = 1)}, "JSON::Tiny::_Bool"),
    #   type  => "boolean",
    # }
    field $blocked : param;
    ADJUST {    # TODO: handle types such as string maxlen, etc.

        # trash.pl:92: { ref => "#blockedAuthor", type => "ref" }
        # trash.pl:99: { format => "at-uri", type => "string" }
        $uri = URI->new($uri) unless builtin::blessed $uri;

        # trash.pl:58: {
        #   const => bless(do{\(my $o = 1)}, "JSON::Tiny::_Bool"),
        #   type  => "boolean",
        # }
    }

    # perlclass does not have :reader yet
    method author  {$author}
    method uri     {$uri}
    method blocked {$blocked}

    method _raw() {
        { author => $author->_raw, uri => $uri->as_string, blocked => !!$blocked, }
    }
}

# app.bsky.feed.defs at trash.pl line 204.
# trash.pl:205: {
#   properties => {
#     post   => { ref => "#postView", type => "ref" },
#     reason => { refs => ["#reasonRepost"], type => "union" },
#     reply  => { ref => "#replyRef", type => "ref" },
#   },
#   required => ["post"],
#   type => "object",
# }
class At::Lexicon::app::bsky::feed::feedViewPost {

    # here at trash.pl line 239.
    # trash.pl:240: { refs => ["#reasonRepost"], type => "union" }
    field $reason : param = ();

    # here at trash.pl line 239.
    # trash.pl:240: { ref => "#replyRef", type => "ref" }
    field $reply : param = ();

    # here at trash.pl line 239.
    # trash.pl:240: { ref => "#postView", type => "ref" }
    field $post : param;
    ADJUST {    # TODO: handle types such as string maxlen, etc.

        # trash.pl:173: { refs => ["#reasonRepost"], type => "union" }
        # Todo: union        $reason;
        # trash.pl:92: { ref => "#replyRef", type => "ref" }
        # trash.pl:92: { ref => "#postView", type => "ref" }
    }

    # perlclass does not have :reader yet
    method reason {$reason}
    method reply  {$reply}
    method post   {$post}

    method _raw() {
        {   reason => $reason,

            # trash.pl:281: { refs => ["#reasonRepost"], type => "union" }
            reply => $reply->_raw,
            post  => $post->_raw,
        }
    }
}

# app.bsky.feed.defs at trash.pl line 204.
# trash.pl:205: {
#   properties => {
#     avatar => { type => "string" },
#     cid => { format => "cid", type => "string" },
#     creator => { ref => "app.bsky.actor.defs#profileView", type => "ref" },
#     description => { maxGraphemes => 300, maxLength => 3000, type => "string" },
#     descriptionFacets => {
#       items => { ref => "app.bsky.richtext.facet", type => "ref" },
#       type  => "array",
#     },
#     did => { format => "did", type => "string" },
#     displayName => { type => "string" },
#     indexedAt => { format => "datetime", type => "string" },
#     likeCount => { minimum => 0, type => "integer" },
#     uri => { format => "at-uri", type => "string" },
#     viewer => { ref => "#generatorViewerState", type => "ref" },
#   },
#   required => ["uri", "cid", "did", "creator", "displayName", "indexedAt"],
#   type => "object",
# }
class At::Lexicon::app::bsky::feed::generatorView {

    # here at trash.pl line 239.
    # trash.pl:240: { format => "did", type => "string" }
    field $did : param;

    # here at trash.pl line 239.
    # trash.pl:240: { format => "datetime", type => "string" }
    field $indexedAt : param;

    # here at trash.pl line 239.
    # trash.pl:240: { ref => "#generatorViewerState", type => "ref" }
    field $viewer : param = ();

    # here at trash.pl line 239.
    # trash.pl:240: { minimum => 0, type => "integer" }
    field $likeCount : param = ();

    # here at trash.pl line 239.
    # trash.pl:240: { maxGraphemes => 300, maxLength => 3000, type => "string" }
    field $description : param = ();

    # here at trash.pl line 239.
    # trash.pl:240: { format => "at-uri", type => "string" }
    field $uri : param;

    # here at trash.pl line 239.
    # trash.pl:240: { type => "string" }
    field $displayName : param;

    # here at trash.pl line 239.
    # trash.pl:240: { ref => "app.bsky.actor.defs#profileView", type => "ref" }
    field $creator : param;

    # here at trash.pl line 239.
    # trash.pl:240: {
    #   items => { ref => "app.bsky.richtext.facet", type => "ref" },
    #   type  => "array",
    # }
    field $descriptionFacets : param = ();

    # here at trash.pl line 239.
    # trash.pl:240: { type => "string" }
    field $avatar : param = ();

    # here at trash.pl line 239.
    # trash.pl:240: { format => "cid", type => "string" }
    field $cid : param;
    ADJUST {    # TODO: handle types such as string maxlen, etc.

        # trash.pl:99: { format => "did", type => "string" }
        $did = At::Protocol::DID->new( uri => $did ) unless builtin::blessed $did;

        # trash.pl:99: { format => "datetime", type => "string" }
        $indexedAt = At::Protocol::Timestamp->new( timestamp => $indexedAt ) unless builtin::blessed $indexedAt;

        # trash.pl:92: { ref => "#generatorViewerState", type => "ref" }
        # trash.pl:86: { minimum => 0, type => "integer" }
        # trash.pl:99: { maxGraphemes => 300, maxLength => 3000, type => "string" }
        Carp::cluck q[description is too long; expected 300 characters or fewer] if bytes::length $description > 300;
        Carp::cluck q[description is too long; expected 3000 bytes or fewer]     if length $description > 3000;

        # trash.pl:99: { format => "at-uri", type => "string" }
        $uri = URI->new($uri) unless builtin::blessed $uri;

        # trash.pl:99: { type => "string" }
        # trash.pl:92: { ref => "app.bsky.actor.defs#profileView", type => "ref" }
        # trash.pl:28: {
        #   items => { ref => "app.bsky.richtext.facet", type => "ref" },
        #   type  => "array",
        # }
        # trash.pl:99: { type => "string" }
        # trash.pl:99: { format => "cid", type => "string" }
    }

    # perlclass does not have :reader yet
    method did               {$did}
    method indexedAt         {$indexedAt}
    method viewer            {$viewer}
    method likeCount         {$likeCount}
    method description       {$description}
    method uri               {$uri}
    method displayName       {$displayName}
    method creator           {$creator}
    method descriptionFacets {$descriptionFacets}
    method avatar            {$avatar}
    method cid               {$cid}

    method _raw() {
        {   did       => $did->as_string,
            indexedAt => $indexedAt->as_string,
            viewer    => $viewer->_raw,
            likeCount => $likeCount,

            # trash.pl:281: { minimum => 0, type => "integer" }
            description       => $description,
            uri               => $uri->as_string,
            displayName       => $displayName,
            creator           => $creator->_raw,
            descriptionFacets => $descriptionFacets,

            # trash.pl:281: {
            #   items => { ref => "app.bsky.richtext.facet", type => "ref" },
            #   type  => "array",
            # }
            avatar => $avatar,
            cid    => $cid->as_string,
        }
    }
}

# app.bsky.feed.defs at trash.pl line 204.
# trash.pl:205: {
#   properties => { like => { format => "at-uri", type => "string" } },
#   type => "object",
# }
class At::Lexicon::app::bsky::feed::generatorViewerState {

    # here at trash.pl line 239.
    # trash.pl:240: { format => "at-uri", type => "string" }
    field $like : param = ();
    ADJUST {    # TODO: handle types such as string maxlen, etc.

        # trash.pl:99: { format => "at-uri", type => "string" }
        $like = URI->new($like) unless builtin::blessed $like;
    }

    # perlclass does not have :reader yet
    method like {$like}

    method _raw() {
        { like => $like->as_string, }
    }
}

# app.bsky.feed.defs at trash.pl line 204.
# trash.pl:205: {
#   properties => {
#     notFound => {
#       const => bless(do{\(my $o = 1)}, "JSON::Tiny::_Bool"),
#       type  => "boolean",
#     },
#     uri => { format => "at-uri", type => "string" },
#   },
#   required => ["uri", "notFound"],
#   type => "object",
# }
class At::Lexicon::app::bsky::feed::notFoundPost {

    # here at trash.pl line 239.
    # trash.pl:240: { format => "at-uri", type => "string" }
    field $uri : param;

    # here at trash.pl line 239.
    # trash.pl:240: {
    #   const => bless(do{\(my $o = 1)}, "JSON::Tiny::_Bool"),
    #   type  => "boolean",
    # }
    field $notFound : param;
    ADJUST {    # TODO: handle types such as string maxlen, etc.

        # trash.pl:99: { format => "at-uri", type => "string" }
        $uri = URI->new($uri) unless builtin::blessed $uri;

        # trash.pl:58: {
        #   const => bless(do{\(my $o = 1)}, "JSON::Tiny::_Bool"),
        #   type  => "boolean",
        # }
    }

    # perlclass does not have :reader yet
    method uri      {$uri}
    method notFound {$notFound}

    method _raw() {
        { uri => $uri->as_string, notFound => !!$notFound, }
    }
}

# app.bsky.feed.defs at trash.pl line 204.
# trash.pl:205: {
#   properties => {
#     by => { ref => "app.bsky.actor.defs#profileViewBasic", type => "ref" },
#     indexedAt => { format => "datetime", type => "string" },
#   },
#   required => ["by", "indexedAt"],
#   type => "object",
# }
class At::Lexicon::app::bsky::feed::reasonRepost {

    # here at trash.pl line 239.
    # trash.pl:240: { format => "datetime", type => "string" }
    field $indexedAt : param;

    # here at trash.pl line 239.
    # trash.pl:240: { ref => "app.bsky.actor.defs#profileViewBasic", type => "ref" }
    field $by : param;
    ADJUST {    # TODO: handle types such as string maxlen, etc.

        # trash.pl:99: { format => "datetime", type => "string" }
        $indexedAt = At::Protocol::Timestamp->new( timestamp => $indexedAt ) unless builtin::blessed $indexedAt;

        # trash.pl:92: { ref => "app.bsky.actor.defs#profileViewBasic", type => "ref" }
    }

    # perlclass does not have :reader yet
    method indexedAt {$indexedAt}
    method by        {$by}

    method _raw() {
        { indexedAt => $indexedAt->as_string, by => $by->_raw, }
    }
}

# app.bsky.feed.defs at trash.pl line 204.
# trash.pl:205: {
#   properties => {
#     parent => {
#                 refs => ["#postView", "#notFoundPost", "#blockedPost"],
#                 type => "union",
#               },
#     root   => {
#                 refs => ["#postView", "#notFoundPost", "#blockedPost"],
#                 type => "union",
#               },
#   },
#   required => ["root", "parent"],
#   type => "object",
# }
class At::Lexicon::app::bsky::feed::replyRef {

    # here at trash.pl line 239.
    # trash.pl:240: {
    #   refs => ["#postView", "#notFoundPost", "#blockedPost"],
    #   type => "union",
    # }
    field $parent : param;

    # here at trash.pl line 239.
    # trash.pl:240: {
    #   refs => ["#postView", "#notFoundPost", "#blockedPost"],
    #   type => "union",
    # }
    field $root : param;
    ADJUST {    # TODO: handle types such as string maxlen, etc.

        # trash.pl:173: {
        #   refs => ["#postView", "#notFoundPost", "#blockedPost"],
        #   type => "union",
        # }
        # Todo: union        $parent;
        # trash.pl:173: {
        #   refs => ["#postView", "#notFoundPost", "#blockedPost"],
        #   type => "union",
        # }
        # Todo: union        $root;
    }

    # perlclass does not have :reader yet
    method parent {$parent}
    method root   {$root}

    method _raw() {
        {   parent => $parent,

            # trash.pl:281: {
            #   refs => ["#postView", "#notFoundPost", "#blockedPost"],
            #   type => "union",
            # }
            root => $root,

            # trash.pl:281: {
            #   refs => ["#postView", "#notFoundPost", "#blockedPost"],
            #   type => "union",
            # }
        }
    }
}

# app.bsky.feed.defs at trash.pl line 204.
# trash.pl:205: {
#   properties => {
#     post   => { format => "at-uri", type => "string" },
#     reason => { refs => ["#skeletonReasonRepost"], type => "union" },
#   },
#   required => ["post"],
#   type => "object",
# }
class At::Lexicon::app::bsky::feed::skeletonFeedPost {

    # here at trash.pl line 239.
    # trash.pl:240: { refs => ["#skeletonReasonRepost"], type => "union" }
    field $reason : param = ();

    # here at trash.pl line 239.
    # trash.pl:240: { format => "at-uri", type => "string" }
    field $post : param;
    ADJUST {    # TODO: handle types such as string maxlen, etc.

        # trash.pl:173: { refs => ["#skeletonReasonRepost"], type => "union" }
        # Todo: union        $reason;
        # trash.pl:99: { format => "at-uri", type => "string" }
        $post = URI->new($post) unless builtin::blessed $post;
    }

    # perlclass does not have :reader yet
    method reason {$reason}
    method post   {$post}

    method _raw() {
        {   reason => $reason,

            # trash.pl:281: { refs => ["#skeletonReasonRepost"], type => "union" }
            post => $post->as_string,
        }
    }
}

# app.bsky.feed.defs at trash.pl line 204.
# trash.pl:205: {
#   properties => { repost => { format => "at-uri", type => "string" } },
#   required => ["repost"],
#   type => "object",
# }
class At::Lexicon::app::bsky::feed::skeletonReasonRepost {

    # here at trash.pl line 239.
    # trash.pl:240: { format => "at-uri", type => "string" }
    field $repost : param;
    ADJUST {    # TODO: handle types such as string maxlen, etc.

        # trash.pl:99: { format => "at-uri", type => "string" }
        $repost = URI->new($repost) unless builtin::blessed $repost;
    }

    # perlclass does not have :reader yet
    method repost {$repost}

    method _raw() {
        { repost => $repost->as_string, }
    }
}

# app.bsky.feed.defs at trash.pl line 204.
# trash.pl:205: {
#   properties => {
#     parent  => {
#                  refs => ["#threadViewPost", "#notFoundPost", "#blockedPost"],
#                  type => "union",
#                },
#     post    => { ref => "#postView", type => "ref" },
#     replies => {
#                  items => {
#                             refs => ["#threadViewPost", "#notFoundPost", "#blockedPost"],
#                             type => "union",
#                           },
#                  type  => "array",
#                },
#   },
#   required => ["post"],
#   type => "object",
# }
class At::Lexicon::app::bsky::feed::threadViewPost {

    # here at trash.pl line 239.
    # trash.pl:240: {
    #   items => {
    #              refs => ["#threadViewPost", "#notFoundPost", "#blockedPost"],
    #              type => "union",
    #            },
    #   type  => "array",
    # }
    field $replies : param = ();

    # here at trash.pl line 239.
    # trash.pl:240: {
    #   refs => ["#threadViewPost", "#notFoundPost", "#blockedPost"],
    #   type => "union",
    # }
    field $parent : param = ();

    # here at trash.pl line 239.
    # trash.pl:240: { ref => "#postView", type => "ref" }
    field $post : param;
    ADJUST {    # TODO: handle types such as string maxlen, etc.

        # trash.pl:28: {
        #   items => {
        #              refs => ["#threadViewPost", "#notFoundPost", "#blockedPost"],
        #              type => "union",
        #            },
        #   type  => "array",
        # }
        # trash.pl:173: {
        #   refs => ["#threadViewPost", "#notFoundPost", "#blockedPost"],
        #   type => "union",
        # }
        # Todo: union        $parent;
        # trash.pl:92: { ref => "#postView", type => "ref" }
    }

    # perlclass does not have :reader yet
    method replies {$replies}
    method parent  {$parent}
    method post    {$post}

    method _raw() {
        {   replies => $replies,

            # trash.pl:281: {
            #   items => {
            #              refs => ["#threadViewPost", "#notFoundPost", "#blockedPost"],
            #              type => "union",
            #            },
            #   type  => "array",
            # }
            parent => $parent,

            # trash.pl:281: {
            #   refs => ["#threadViewPost", "#notFoundPost", "#blockedPost"],
            #   type => "union",
            # }
            post => $post->_raw,
        }
    }
}

# app.bsky.feed.defs at trash.pl line 204.
# trash.pl:205: {
#   properties => {
#     cid => { format => "cid", type => "string" },
#     lists => {
#       items => { ref => "app.bsky.graph.defs#listViewBasic", type => "ref" },
#       type  => "array",
#     },
#     record => { type => "unknown" },
#     uri => { format => "at-uri", type => "string" },
#   },
#   type => "object",
# }
class At::Lexicon::app::bsky::feed::threadgateView {

    # here at trash.pl line 239.
    # trash.pl:240: { format => "cid", type => "string" }
    field $cid : param = ();

    # here at trash.pl line 239.
    # trash.pl:240: { type => "unknown" }
    field $record : param = ();

    # here at trash.pl line 239.
    # trash.pl:240: {
    #   items => { ref => "app.bsky.graph.defs#listViewBasic", type => "ref" },
    #   type  => "array",
    # }
    field $lists : param = ();

    # here at trash.pl line 239.
    # trash.pl:240: { format => "at-uri", type => "string" }
    field $uri : param = ();
    ADJUST {    # TODO: handle types such as string maxlen, etc.

        # trash.pl:99: { format => "cid", type => "string" }
        # trash.pl:180: { type => "unknown" }
        # trash.pl:28: {
        #   items => { ref => "app.bsky.graph.defs#listViewBasic", type => "ref" },
        #   type  => "array",
        # }
        # trash.pl:99: { format => "at-uri", type => "string" }
        $uri = URI->new($uri) unless builtin::blessed $uri;
    }

    # perlclass does not have :reader yet
    method cid    {$cid}
    method record {$record}
    method lists  {$lists}
    method uri    {$uri}

    method _raw() {
        {   cid    => $cid->as_string,
            record => $record,

            # trash.pl:281: { type => "unknown" }
            lists => $lists,

            # trash.pl:281: {
            #   items => { ref => "app.bsky.graph.defs#listViewBasic", type => "ref" },
            #   type  => "array",
            # }
            uri => $uri->as_string,
        }
    }
}

# app.bsky.feed.defs at trash.pl line 204.
# trash.pl:205: {
#   properties => {
#     like => { format => "at-uri", type => "string" },
#     replyDisabled => { type => "boolean" },
#     repost => { format => "at-uri", type => "string" },
#   },
#   type => "object",
# }
class At::Lexicon::app::bsky::feed::viewerState {

    # here at trash.pl line 239.
    # trash.pl:240: { format => "at-uri", type => "string" }
    field $repost : param = ();

    # here at trash.pl line 239.
    # trash.pl:240: { type => "boolean" }
    field $replyDisabled : param = ();

    # here at trash.pl line 239.
    # trash.pl:240: { format => "at-uri", type => "string" }
    field $like : param = ();
    ADJUST {    # TODO: handle types such as string maxlen, etc.

        # trash.pl:99: { format => "at-uri", type => "string" }
        $repost = URI->new($repost) unless builtin::blessed $repost;

        # trash.pl:58: { type => "boolean" }
        # trash.pl:99: { format => "at-uri", type => "string" }
        $like = URI->new($like) unless builtin::blessed $like;
    }

    # perlclass does not have :reader yet
    method repost        {$repost}
    method replyDisabled {$replyDisabled}
    method like          {$like}

    method _raw() {
        { repost => $repost->as_string, replyDisabled => !!$replyDisabled, like => $like->as_string, }
    }
}

# app.bsky.feed.describeFeedGenerator at trash.pl line 204.
# trash.pl:205: {
#   properties => { uri => { format => "at-uri", type => "string" } },
#   required => ["uri"],
#   type => "object",
# }
class At::Lexicon::app::bsky::feed::describeFeedGenerator::feed {

    # here at trash.pl line 239.
    # trash.pl:240: { format => "at-uri", type => "string" }
    field $uri : param;
    ADJUST {    # TODO: handle types such as string maxlen, etc.

        # trash.pl:99: { format => "at-uri", type => "string" }
        $uri = URI->new($uri) unless builtin::blessed $uri;
    }

    # perlclass does not have :reader yet
    method uri {$uri}

    method _raw() {
        { uri => $uri->as_string, }
    }
}

# app.bsky.feed.describeFeedGenerator at trash.pl line 204.
# trash.pl:205: {
#   properties => {
#     privacyPolicy  => { type => "string" },
#     termsOfService => { type => "string" },
#   },
#   type => "object",
# }
class At::Lexicon::app::bsky::feed::describeFeedGenerator::links {

    # here at trash.pl line 239.
    # trash.pl:240: { type => "string" }
    field $privacyPolicy : param = ();

    # here at trash.pl line 239.
    # trash.pl:240: { type => "string" }
    field $termsOfService : param = ();
    ADJUST {    # TODO: handle types such as string maxlen, etc.

        # trash.pl:99: { type => "string" }
        # trash.pl:99: { type => "string" }
    }

    # perlclass does not have :reader yet
    method privacyPolicy  {$privacyPolicy}
    method termsOfService {$termsOfService}

    method _raw() {
        { privacyPolicy => $privacyPolicy, termsOfService => $termsOfService, }
    }
}

# app.bsky.feed.describeFeedGenerator at trash.pl line 204.
# trash.pl:205: {
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
class At::Lexicon::app::bsky::feed;

method describeFeedGenerator() {
    use Carp qw[confess];
    $client->http->session // confess 'creating a post requires an authenticated client';

    # trash.pl:216: {
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
    my $res = $client->http->get( sprintf( '%s/xrpc/%s', $client->host(), 'app.bsky.feed.describeFeedGenerator' ) );
    $res->{uri} = URI->new( $res->{uri} ) if defined $res->{uri};
    $res;
}

# app.bsky.feed.generator at trash.pl line 204.
# trash.pl:205: {
#   description => "A declaration of the existence of a feed generator.",
#   key => "any",
#   record => {
#     properties => {
#       avatar => {
#         accept  => ["image/png", "image/jpeg"],
#         maxSize => 1000000,
#         type    => "blob",
#       },
#       createdAt => { format => "datetime", type => "string" },
#       description => { maxGraphemes => 300, maxLength => 3000, type => "string" },
#       descriptionFacets => {
#         items => { ref => "app.bsky.richtext.facet", type => "ref" },
#         type  => "array",
#       },
#       did => { format => "did", type => "string" },
#       displayName => { maxGraphemes => 24, maxLength => 240, type => "string" },
#       labels => { refs => ["com.atproto.label.defs#selfLabels"], type => "union" },
#     },
#     required => ["did", "displayName", "createdAt"],
#     type => "object",
#   },
#   type => "record",
# }
class At::Lexicon::app::bsky::feed::generator {

    # here at trash.pl line 292.
    field $labels : param = ();

    # here at trash.pl line 292.
    field $descriptionFacets : param = ();

    # here at trash.pl line 292.
    field $avatar : param = ();

    # here at trash.pl line 292.
    field $description : param = ();

    # here at trash.pl line 292.
    field $did : param;

    # here at trash.pl line 292.
    field $displayName : param;

    # here at trash.pl line 292.
    field $createdAt : param;
    ADJUST { }    # TODO: handle types such as string maxlen, etc.

    # perlclass does not have :reader yet
    method labels            {$labels}
    method descriptionFacets {$descriptionFacets}
    method avatar            {$avatar}
    method description       {$description}
    method did               {$did}
    method displayName       {$displayName}
    method createdAt         {$createdAt}

    method _raw() {
        {   labels            => $labels,
            descriptionFacets => $descriptionFacets,
            avatar            => $avatar,
            description       => $description,
            did               => $did,
            displayName       => $displayName,
            createdAt         => $createdAt,
        }
    }
}

# app.bsky.feed.getActorFeeds at trash.pl line 204.
# trash.pl:205: {
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
class At::Lexicon::app::bsky::feed;

method getActorFeeds() {
    use Carp qw[confess];
    $client->http->session // confess 'creating a post requires an authenticated client';

    # trash.pl:216: {
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
    my $res = $client->http->get( sprintf( '%s/xrpc/%s', $client->host(), 'app.bsky.feed.getActorFeeds' ) );
    $res->{uri} = URI->new( $res->{uri} ) if defined $res->{uri};
    $res;
}

# app.bsky.feed.getActorLikes at trash.pl line 204.
# trash.pl:205: {
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
class At::Lexicon::app::bsky::feed;

method getActorLikes() {
    use Carp qw[confess];
    $client->http->session // confess 'creating a post requires an authenticated client';

    # trash.pl:216: {
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
    my $res = $client->http->get( sprintf( '%s/xrpc/%s', $client->host(), 'app.bsky.feed.getActorLikes' ) );
    $res->{uri} = URI->new( $res->{uri} ) if defined $res->{uri};
    $res;
}

# app.bsky.feed.getAuthorFeed at trash.pl line 204.
# trash.pl:205: {
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
class At::Lexicon::app::bsky::feed;

method getAuthorFeed() {
    use Carp qw[confess];
    $client->http->session // confess 'creating a post requires an authenticated client';

    # trash.pl:216: {
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
    my $res = $client->http->get( sprintf( '%s/xrpc/%s', $client->host(), 'app.bsky.feed.getAuthorFeed' ) );
    $res->{uri} = URI->new( $res->{uri} ) if defined $res->{uri};
    $res;
}

# app.bsky.feed.getFeed at trash.pl line 204.
# trash.pl:205: {
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
class At::Lexicon::app::bsky::feed;

method getFeed() {
    use Carp qw[confess];
    $client->http->session // confess 'creating a post requires an authenticated client';

    # trash.pl:216: {
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
    my $res = $client->http->get( sprintf( '%s/xrpc/%s', $client->host(), 'app.bsky.feed.getFeed' ) );
    $res->{uri} = URI->new( $res->{uri} ) if defined $res->{uri};
    $res;
}

# app.bsky.feed.getFeedGenerator at trash.pl line 204.
# trash.pl:205: {
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
class At::Lexicon::app::bsky::feed;

method getFeedGenerator() {
    use Carp qw[confess];
    $client->http->session // confess 'creating a post requires an authenticated client';

    # trash.pl:216: {
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
    my $res = $client->http->get( sprintf( '%s/xrpc/%s', $client->host(), 'app.bsky.feed.getFeedGenerator' ) );
    $res->{uri} = URI->new( $res->{uri} ) if defined $res->{uri};
    $res;
}

# app.bsky.feed.getFeedGenerators at trash.pl line 204.
# trash.pl:205: {
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
class At::Lexicon::app::bsky::feed;

method getFeedGenerators() {
    use Carp qw[confess];
    $client->http->session // confess 'creating a post requires an authenticated client';

    # trash.pl:216: {
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
    my $res = $client->http->get( sprintf( '%s/xrpc/%s', $client->host(), 'app.bsky.feed.getFeedGenerators' ) );
    $res->{uri} = URI->new( $res->{uri} ) if defined $res->{uri};
    $res;
}

# app.bsky.feed.getFeedSkeleton at trash.pl line 204.
# trash.pl:205: {
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
class At::Lexicon::app::bsky::feed;

method getFeedSkeleton() {
    use Carp qw[confess];
    $client->http->session // confess 'creating a post requires an authenticated client';

    # trash.pl:216: {
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
    my $res = $client->http->get( sprintf( '%s/xrpc/%s', $client->host(), 'app.bsky.feed.getFeedSkeleton' ) );
    $res->{uri} = URI->new( $res->{uri} ) if defined $res->{uri};
    $res;
}

# app.bsky.feed.getLikes at trash.pl line 204.
# trash.pl:205: {
#   properties => {
#     actor => { ref => "app.bsky.actor.defs#profileView", type => "ref" },
#     createdAt => { format => "datetime", type => "string" },
#     indexedAt => { format => "datetime", type => "string" },
#   },
#   required => ["indexedAt", "createdAt", "actor"],
#   type => "object",
# }
class At::Lexicon::app::bsky::feed::getLikes::like {

    # here at trash.pl line 239.
    # trash.pl:240: { format => "datetime", type => "string" }
    field $indexedAt : param;

    # here at trash.pl line 239.
    # trash.pl:240: { format => "datetime", type => "string" }
    field $createdAt : param;

    # here at trash.pl line 239.
    # trash.pl:240: { ref => "app.bsky.actor.defs#profileView", type => "ref" }
    field $actor : param;
    ADJUST {    # TODO: handle types such as string maxlen, etc.

        # trash.pl:99: { format => "datetime", type => "string" }
        $indexedAt = At::Protocol::Timestamp->new( timestamp => $indexedAt ) unless builtin::blessed $indexedAt;

        # trash.pl:99: { format => "datetime", type => "string" }
        $createdAt = At::Protocol::Timestamp->new( timestamp => $createdAt ) unless builtin::blessed $createdAt;

        # trash.pl:92: { ref => "app.bsky.actor.defs#profileView", type => "ref" }
    }

    # perlclass does not have :reader yet
    method indexedAt {$indexedAt}
    method createdAt {$createdAt}
    method actor     {$actor}

    method _raw() {
        { indexedAt => $indexedAt->as_string, createdAt => $createdAt->as_string, actor => $actor->_raw, }
    }
}

# app.bsky.feed.getLikes at trash.pl line 204.
# trash.pl:205: {
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
class At::Lexicon::app::bsky::feed;

method getLikes() {
    use Carp qw[confess];
    $client->http->session // confess 'creating a post requires an authenticated client';

    # trash.pl:216: {
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
    my $res = $client->http->get( sprintf( '%s/xrpc/%s', $client->host(), 'app.bsky.feed.getLikes' ) );
    $res->{uri} = URI->new( $res->{uri} ) if defined $res->{uri};
    $res;
}

# app.bsky.feed.getListFeed at trash.pl line 204.
# trash.pl:205: {
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
class At::Lexicon::app::bsky::feed;

method getListFeed() {
    use Carp qw[confess];
    $client->http->session // confess 'creating a post requires an authenticated client';

    # trash.pl:216: {
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
    my $res = $client->http->get( sprintf( '%s/xrpc/%s', $client->host(), 'app.bsky.feed.getListFeed' ) );
    $res->{uri} = URI->new( $res->{uri} ) if defined $res->{uri};
    $res;
}

# app.bsky.feed.getPostThread at trash.pl line 204.
# trash.pl:205: {
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
class At::Lexicon::app::bsky::feed;

method getPostThread() {
    use Carp qw[confess];
    $client->http->session // confess 'creating a post requires an authenticated client';

    # trash.pl:216: {
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
    my $res = $client->http->get( sprintf( '%s/xrpc/%s', $client->host(), 'app.bsky.feed.getPostThread' ) );
    $res->{uri} = URI->new( $res->{uri} ) if defined $res->{uri};
    $res;
}

# app.bsky.feed.getPosts at trash.pl line 204.
# trash.pl:205: {
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
class At::Lexicon::app::bsky::feed;

method getPosts() {
    use Carp qw[confess];
    $client->http->session // confess 'creating a post requires an authenticated client';

    # trash.pl:216: {
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
    my $res = $client->http->get( sprintf( '%s/xrpc/%s', $client->host(), 'app.bsky.feed.getPosts' ) );
    $res->{uri} = URI->new( $res->{uri} ) if defined $res->{uri};
    $res;
}

# app.bsky.feed.getRepostedBy at trash.pl line 204.
# trash.pl:205: {
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
class At::Lexicon::app::bsky::feed;

method getRepostedBy() {
    use Carp qw[confess];
    $client->http->session // confess 'creating a post requires an authenticated client';

    # trash.pl:216: {
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
    my $res = $client->http->get( sprintf( '%s/xrpc/%s', $client->host(), 'app.bsky.feed.getRepostedBy' ) );
    $res->{uri} = URI->new( $res->{uri} ) if defined $res->{uri};
    $res;
}

# app.bsky.feed.getSuggestedFeeds at trash.pl line 204.
# trash.pl:205: {
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
class At::Lexicon::app::bsky::feed;

method getSuggestedFeeds() {
    use Carp qw[confess];
    $client->http->session // confess 'creating a post requires an authenticated client';

    # trash.pl:216: {
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
    my $res = $client->http->get( sprintf( '%s/xrpc/%s', $client->host(), 'app.bsky.feed.getSuggestedFeeds' ) );
    $res->{uri} = URI->new( $res->{uri} ) if defined $res->{uri};
    $res;
}

# app.bsky.feed.getTimeline at trash.pl line 204.
# trash.pl:205: {
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
class At::Lexicon::app::bsky::feed;

method getTimeline() {
    use Carp qw[confess];
    $client->http->session // confess 'creating a post requires an authenticated client';

    # trash.pl:216: {
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
    my $res = $client->http->get( sprintf( '%s/xrpc/%s', $client->host(), 'app.bsky.feed.getTimeline' ) );
    $res->{uri} = URI->new( $res->{uri} ) if defined $res->{uri};
    $res;
}

# app.bsky.feed.like at trash.pl line 204.
# trash.pl:205: {
#   description => "A declaration of a like.",
#   key => "tid",
#   record => {
#     properties => {
#       createdAt => { format => "datetime", type => "string" },
#       subject   => { ref => "com.atproto.repo.strongRef", type => "ref" },
#     },
#     required => ["subject", "createdAt"],
#     type => "object",
#   },
#   type => "record",
# }
class At::Lexicon::app::bsky::feed::like {

    # here at trash.pl line 292.
    field $subject : param;

    # here at trash.pl line 292.
    field $createdAt : param;
    ADJUST { }    # TODO: handle types such as string maxlen, etc.

    # perlclass does not have :reader yet
    method subject   {$subject}
    method createdAt {$createdAt}

    method _raw() {
        { subject => $subject, createdAt => $createdAt, }
    }
}

# app.bsky.feed.repost at trash.pl line 204.
# trash.pl:205: {
#   description => "A declaration of a repost.",
#   key => "tid",
#   record => {
#     properties => {
#       createdAt => { format => "datetime", type => "string" },
#       subject   => { ref => "com.atproto.repo.strongRef", type => "ref" },
#     },
#     required => ["subject", "createdAt"],
#     type => "object",
#   },
#   type => "record",
# }
class At::Lexicon::app::bsky::feed::repost {

    # here at trash.pl line 292.
    field $createdAt : param;

    # here at trash.pl line 292.
    field $subject : param;
    ADJUST { }    # TODO: handle types such as string maxlen, etc.

    # perlclass does not have :reader yet
    method createdAt {$createdAt}
    method subject   {$subject}

    method _raw() {
        { createdAt => $createdAt, subject => $subject, }
    }
}

# app.bsky.feed.searchPosts at trash.pl line 204.
# trash.pl:205: {
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
class At::Lexicon::app::bsky::feed;

method searchPosts() {
    use Carp qw[confess];
    $client->http->session // confess 'creating a post requires an authenticated client';

# trash.pl:216: {
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
    my $res = $client->http->get( sprintf( '%s/xrpc/%s', $client->host(), 'app.bsky.feed.searchPosts' ) );
    $res->{uri} = URI->new( $res->{uri} ) if defined $res->{uri};
    $res;
}

# app.bsky.feed.threadgate at trash.pl line 204.
# trash.pl:205: {
#   description => "Allow replies from actors you follow.",
#   properties => {},
#   type => "object",
# }
class At::Lexicon::app::bsky::feed::threadgate::followingRule {
    ADJUST {    # TODO: handle types such as string maxlen, etc.
    }

    # perlclass does not have :reader yet
    method _raw() {
        {}
    }
}

# app.bsky.feed.threadgate at trash.pl line 204.
# trash.pl:205: {
#   description => "Allow replies from actors on a list.",
#   properties => { list => { format => "at-uri", type => "string" } },
#   required => ["list"],
#   type => "object",
# }
class At::Lexicon::app::bsky::feed::threadgate::listRule {

    # here at trash.pl line 239.
    # trash.pl:240: { format => "at-uri", type => "string" }
    field $list : param;
    ADJUST {    # TODO: handle types such as string maxlen, etc.

        # trash.pl:99: { format => "at-uri", type => "string" }
        $list = URI->new($list) unless builtin::blessed $list;
    }

    # perlclass does not have :reader yet
    method list {$list}

    method _raw() {
        { list => $list->as_string, }
    }
}

# app.bsky.feed.threadgate at trash.pl line 204.
# trash.pl:205: {
#   description => "Defines interaction gating rules for a thread. The rkey of the threadgate record should match the rkey of the thread's root post.",
#   key => "tid",
#   record => {
#     properties => {
#       allow => {
#         items => {
#           refs => ["#mentionRule", "#followingRule", "#listRule"],
#           type => "union",
#         },
#         maxLength => 5,
#         type => "array",
#       },
#       createdAt => { format => "datetime", type => "string" },
#       post => { format => "at-uri", type => "string" },
#     },
#     required => ["post", "createdAt"],
#     type => "object",
#   },
#   type => "record",
# }
class At::Lexicon::app::bsky::feed::threadgate {

    # here at trash.pl line 292.
    field $post : param;

    # here at trash.pl line 292.
    field $allow : param = ();

    # here at trash.pl line 292.
    field $createdAt : param;
    ADJUST { }    # TODO: handle types such as string maxlen, etc.

    # perlclass does not have :reader yet
    method post      {$post}
    method allow     {$allow}
    method createdAt {$createdAt}

    method _raw() {
        { post => $post, allow => $allow, createdAt => $createdAt, }
    }
}

# app.bsky.feed.threadgate at trash.pl line 204.
# trash.pl:205: {
#   description => "Allow replies from actors mentioned in your post.",
#   properties => {},
#   type => "object",
# }
class At::Lexicon::app::bsky::feed::threadgate::mentionRule {
    ADJUST {    # TODO: handle types such as string maxlen, etc.
    }

    # perlclass does not have :reader yet
    method _raw() {
        {}
    }
}



=end todo

=cut



    class At::Lexicon::app::bsky::feed::post {
        field $createdAt : param;      # timestamp, required
        field $embed : param  = ();    # union
        field $facets : param = ();    # array of app.bsky.richtext.facet
        field $labels : param = ();    # com.atproto.label.defs#selfLabels
        field $langs : param  = ();    # array of strings, 3 elements max
        field $reply : param  = ();    # #replyRef
        field $tags : param   = ();    # array of strings
        field $text : param;           # string, required, max 300 graphemes, max length 3000
        ADJUST {
            use Carp;
            use experimental 'try';
            $createdAt = At::Protocol::Timestamp->new( timestamp => $createdAt ) unless builtin::blessed $createdAt;
            $embed     = [
                map {
                    return $_ if builtin::blessed $_;
                    if ( defined $_->{'$type'} ) {
                        my $type = delete $_->{'$type'};
                        return $_ = At::Lexicon::app::bsky::embed::images->new(%$_)          if $type eq 'app.bsky.embed.images';
                        return $_ = At::Lexicon::app::bsky::embed::external->new(%$_)        if $type eq 'app.bsky.embed.external';
                        return $_ = At::Lexicon::app::bsky::embed::record->new(%$_)          if $type eq 'app.bsky.embed.record';
                        return $_ = At::Lexicon::app::bsky::embed::recordWithMedia->new(%$_) if $type eq 'app.bsky.embed.recordWithMedia';
                    }
                    try {
                        $_ = At::Lexicon::app::bsky::embed::images->new(%$_);
                    }
                    catch ($e) {
                        try {
                            $_ = At::Lexicon::app::bsky::embed::external->new(%$_);
                        }
                        catch ($e) {
                            try {
                                $_ = At::Lexicon::app::bsky::embed::record->new(%$_);
                            }
                            catch ($e) {
                                try {
                                    $_ = At::Lexicon::app::bsky::embed::recordWithMedia->new(%$_);
                                }
                                catch ($e) {
                                    Carp::croak 'malformed embed: ' . $e;
                                }
                            }
                        }
                    }
                } @$embed
                ]
                if defined $embed;
            $facets = [ map { $_ = At::Lexicon::app::bsky::richtext::facet->new(%$_)      unless builtin::blessed $_ } @$facets ] if defined $facets;
            $labels = [ map { $_ = At::Lexicon::app::atproto::label::selfLabels->new(%$_) unless builtin::blessed $_ } @$labels ] if defined $labels;
            Carp::cluck q[too many languages; 3 max] if defined $langs && scalar @$langs > 3;
            $reply = At::Lexicon::app::bsky::feed::post::replyRef->new(%$reply) if defined $reply && !builtin::blessed $reply;
            if ( defined $tags ) {
                Carp::cluck q[too many tags; expected 8 max]               if grep { length $_ > 640 } @$tags;
                Carp::cluck q[tag is too long; expected 64 characters max] if grep { length $_ > 640 } @$tags;
                Carp::cluck q[tag is too long; expected 640 bytes max]     if grep { bytes::length $_ > 640 } @$tags;
            }
            Carp::cluck q[text is too long; expected 3000 bytes or fewer]     if bytes::length $text> 3000;
            Carp::cluck q[text is too long; expected 300 characters or fewer] if length $text > 300;
        }

        # perlclass does not have :reader yet
        method createdAt {$createdAt}
        method embed     {$embed}
        method facets    {$facets}
        method labels    {$labels}
        method langs     {$langs}
        method reply     {$reply}
        method tags      {$tags}
        method text      {$text}

        method _raw() {
            {   '$type'   => 'app.bsky.feed.post',
                createdAt => $createdAt->_raw,
                defined $embed  ? ( embed  => $embed ) : (), defined $facets                       ? ( facets => [ map { $_->_raw } @$facets ] ) : (),
                defined $labels ? ( labels => [ map { $_->_raw } @$labels ] ) : (), defined $langs ? ( langs => $langs )                         : (),
                defined $reply  ? ( reply  => $reply->_raw )                  : (), defined $tags  ? ( tags  => $tags ) : (), text => $text
            }
        }
    }

    class At::Lexicon::app::bsky::feed::post::replyRef {
        field $parent : param;    # strongRef, required
        field $root : param;      # strongRef, required
        ADJUST {
            $parent = At::Lexicon::com::atproto::repo::strongRef->new(%$parent) unless builtin::blessed $parent;
            $root   = At::Lexicon::com::atproto::repo::strongRef->new(%$root)   unless builtin::blessed $root;
        }

        # perlclass does not have :reader yet
        method parent {$parent}
        method root   {$root}

        method _raw() {
            { parent => $parent->_raw, root => $root->_raw }
        }
    }
};
1;
__END__

=encoding utf-8

=head1 NAME

At::Lexicon::app::bsky::feed - Post Declarations

=head1 See Also

https://atproto.com/

https://en.wikipedia.org/wiki/Bluesky_(social_network)

=head1 LICENSE

Copyright (C) Sanko Robinson.

This library is free software; you can redistribute it and/or modify it under the terms found in the Artistic License
2. Other copyrights, terms, and conditions may apply to data transmitted through this module.

=head1 AUTHOR

Sanko Robinson E<lt>sanko@cpan.orgE<gt>

=cut
