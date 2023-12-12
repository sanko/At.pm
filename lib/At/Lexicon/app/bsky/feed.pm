package At::Lexicon::app::bsky::feed 0.02 {
    use v5.38;
    no warnings 'experimental::class', 'experimental::builtin';    # Be quiet.
    use feature 'class';
    use bytes;
    our @CARP_NOT;

    #~ use At::Lexicon::app::bsky::richtext;
    #
    class At::Lexicon::app::bsky::feed::postView {
        field $author : param;                # ::actor::profileViewBasic, required
        field $cid : param;                   # cid, required
        field $embed : param //= ();          # union
        field $indexedAt : param;             # timestamp, required
        field $labels : param    //= ();      # array of ::com::atproto::label::selfLabels
        field $likeCount : param //= ();      # int
        field $record : param;                # unknown, required
        field $replyCount : param  //= ();    # int
        field $repostCount : param //= ();    # int
        field $threadgate : param  //= ();    # ::threadgateView
        field $uri : param;                   # uri, required
        field $viewer : param //= ();         # ::viewerState
        ADJUST {
            use Carp;
            use experimental 'try';
            $author = At::Lexicon::app::bsky::profileViewBasic->new(%$author) unless builtin::blessed $author;
            $embed  = [
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
            $indexedAt  = At::Protocol::Timestamp->new( timestamp => $indexedAt ) unless builtin::blessed $indexedAt;
            $labels     = [ map { $_ = At::Lexicon::app::atproto::label->new(%$_) unless builtin::blessed $_ } @$labels ] if defined $labels;
            $threadgate = At::Lexicon::app::bsky::feed::post::threadgateView->new(%$threadgate)
                if defined $threadgate && !builtin::blessed $threadgate;
            $uri = URI->new($uri) unless builtin::blessed $uri;
        }

        # perlclass does not have :reader yet
        method author      {$author}
        method cid         {$cid}
        method embed       {$embed}
        method indexedAt   {$indexedAt}
        method labels      {$labels}
        method likeCount   {$likeCount}
        method record      {$record}
        method replyCount  {$replyCount}
        method repostCount {$repostCount}
        method threadgate  {$threadgate}
        method uri         {$uri}
        method viewer      {$viewer}

        method _raw() {
            {   author => $author,
                defined $cid ? ( cid => $cid ) : (), defined $embed ? ( embed => $embed ) : (),
                indexedAt => $indexedAt,
                defined $labels ? ( labels => [ map { $_->_raw } @$labels ] ) : (), defined $likeCount ? ( likeCount => $likeCount ) : (),
                record => ( builtin::blessed $record? $record->_raw : $record ),
                defined $replyCount ? ( replyCount => $replyCount ) : (), defined $threadgate ? ( threadgate => $threadgate ) : (),
                uri => $uri->as_string,
                defined $viewer ? ( viewer => $viewer->_raw ) : ()
            }
        }
    }

    class At::Lexicon::app::bsky::feed::blockedAuthor {
        field $did : param;            # did, required
        field $viewer : param = ();    # ::actor::viewerState
        ADJUST {
            $did    = At::Protocol::DID->new( uri => $did ) unless builtin::blessed $did;
            $viewer = At::Lexicon::app::bsky::actor::viewerState->new(%$viewer) if defined $viewer && !builtin::blessed $viewer;
        }

        # perlclass does not have :reader yet
        method did    {$did}
        method viewer {$viewer}

        method _raw() {
            { did => $did->_raw, defined $viewer ? ( viewer => $viewer->_raw ) : () }
        }
    }

    class At::Lexicon::app::bsky::feed::blockedPost {
        field $author : param;         # ::blockedAuthor, required
        field $uri : param;            # at-uri, required
        field $blocked : param = 1;    # bool, const true, required
        ADJUST {
            $author = At::Lexicon::app::bsky::feed::blockedAuthor->new(%$author) unless builtin::blessed $author;
            $uri    = URI->new($uri)                                             unless builtin::blessed $uri;
        }

        # perlclass does not have :reader yet
        method author  {$author}
        method uri     {$uri}
        method blocked {$blocked}

        method _raw() {
            { author => $author->_raw, uri => $uri->as_string, blocked => \$blocked }
        }
    }

    class At::Lexicon::app::bsky::feed::feedViewPost {
        use experimental 'try';
        field $reason : param = ();    # union
        field $reply : param  = ();    # replyRef
        field $post : param;           # postView, required
        ADJUST {
            $reason = sub ($r) {
                return $r if builtin::blessed $r;

                #~ if ( defined $_->{'$type'} ) {
                #~ my $type = delete $_->{'$type'};
                #~ return $r = At::Lexicon::app::bsky::feed::reasonRepost->new(%$_) if $type eq 'app.bsky.embed.images';
                #~ }
                try {
                    $r = At::Lexicon::app::bsky::feed::reasonRepost->new(%$_);
                }
                catch ($e) {
                    Carp::croak 'malformed reply: ' . $e;
                }
                $r;
                }
                ->($reason) if defined $reason;
            $reply = At::Lexicon::app::bsky::feed::replyRef->new(%$reply) if defined $reply && !builtin::blessed $reply;
            $post  = At::Lexicon::app::bsky::feed::postView->new(%$post) unless builtin::blessed $post;
        }

        # perlclass does not have :reader yet
        method reason {$reason}
        method reply  {$reply}
        method post   {$post}

        method _raw() {
            {
                defined $reason ? ( reason => $reason->_raw ) : (), defined $reply ? ( reply => $reply->_raw ) : (),
                    post => $post->_raw,
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
        field $avatar : param = ();               # string
        field $cid : param;                       # cid, required
        field $creator : param;                   # ::actor::profileView, required
        field $description : param       = ();    # string, max graphemes: 300, max length: 3000
        field $descriptionFacets : param = ();    # array of facets
        field $did : param;                       # did, required
        field $displayName : param;               # string, required
        field $indexedAt : param;                 # datetime, required
        field $likeCount : param = ();            # int, min 0
        field $uri : param;                       # uri, required
        field $viewer : param = ();               # ::generatorViewerState
        ADJUST {
            $creator = At::Lexicon::app::bsky::author::profileView->new(%$creator) unless builtin::blessed $creator;
            $did     = At::Protocol::DID->new( uri => $did )                       unless builtin::blessed $did;

            # trash.pl:99: { maxGraphemes => 300, maxLength => 3000, type => "string" }
            Carp::cluck q[description is too long; expected 300 characters or fewer] if length $description > 300;
            Carp::cluck q[description is too long; expected 3000 bytes or fewer]     if bytes::length $description > 3000;
            $indexedAt = At::Protocol::Timestamp->new( timestamp => $indexedAt ) unless builtin::blessed $indexedAt;

            # trash.pl:92: { ref => "#generatorViewerState", type => "ref" }
            # trash.pl:86: { minimum => 0, type => "integer" }
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
            {   did       => $did->_raw,
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
                cid    => $cid
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
        ADJUST {
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
        ADJUST {
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
        ADJUST {
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
        ADJUST {
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
        ADJUST {
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

    class At::Lexicon::app::bsky::feed::skeletonReasonRepost {
        field $repost : param;    # at-uri, required
        ADJUST {
            $repost = URI->new($repost) unless builtin::blessed $repost;
        }

        # perlclass does not have :reader yet
        method repost {$repost}

        method _raw() {
            { repost => $repost->as_string }
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
        #   refs => ["#threadViewPost", "#notFoundPost", "#blockedPost"],
        #   type => "union",
        # }
        field $parent : param = ();

        # here at trash.pl line 239.
        # trash.pl:240: { ref => "#postView", type => "ref" }
        field $post : param;

        # here at trash.pl line 239.
        # trash.pl:240: {
        #   items => {
        #              refs => ["#threadViewPost", "#notFoundPost", "#blockedPost"],
        #              type => "union",
        #            },
        #   type  => "array",
        # }
        field $replies : param = ();
        ADJUST {
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
        ADJUST {
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
        ADJUST {
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
        ADJUST {
            # trash.pl:99: { format => "at-uri", type => "string" }
            $uri = URI->new($uri) unless builtin::blessed $uri;
        }

        # perlclass does not have :reader yet
        method uri {$uri}

        method _raw() {
            { uri => $uri->as_string, }
        }
    }

    class At::Lexicon::app::bsky::feed::describeFeedGenerator::links {
        field $privacyPolicy : param  = ();    # string
        field $termsOfService : param = ();    # string

        # perlclass does not have :reader yet
        method privacyPolicy  {$privacyPolicy}
        method termsOfService {$termsOfService}

        method _raw() {
            { privacyPolicy => $privacyPolicy, termsOfService => $termsOfService }
        }
    }

    # app.bsky.feed.generator at trash.pl line 204.
    # trash.pl:205: {
    #   description => "",
    #   key => "any",
    #   record => {
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
    #~ Intro/choruse:
    #~ |---------------------------------------|
    #~ |------3-33-----------------------------|
    #~ |-5-55------4-44-5-5----353---3-33-1-11-|
    #~ |-------------------33-5---33-----------|
    # A declaration of the existence of a feed generator.
    class At::Lexicon::app::bsky::feed::generator {
        field $avatar : param = ();    # blob, max 1000000, png or jpeg
        field $createdAt : param;      # datetime, required

        # here at trash.pl line 292.
        field $labels : param = ();

        # here at trash.pl line 292.
        field $descriptionFacets : param = ();

        # here at trash.pl line 292.
        # here at trash.pl line 292.
        field $description : param = ();

        # here at trash.pl line 292.
        field $did : param;

        # here at trash.pl line 292.
        field $displayName : param;

        # here at trash.pl line 292.
        ADJUST {
            use Carp;
            Carp::confess 'avatar is too large; expected 1000000 bytes' if defined $avatar && bytes::length $avatar > 1000000;
            $createdAt = At::Protocol::Timestamp->new( timestamp => $createdAt ) unless builtin::blessed $createdAt;
        }

        # perlclass does not have :reader yet
        method labels            {$labels}
        method descriptionFacets {$descriptionFacets}
        method avatar            {$avatar}
        method description       {$description}
        method did               {$did}
        method displayName       {$displayName}
        method createdAt         {$createdAt}

        method _raw() {
            {
                defined $avatar ? ( avatar => $avatar ) : (),
                    createdAt         => $createdAt->_raw,
                    labels            => $labels,
                    descriptionFacets => $descriptionFacets,
                    description       => $description,
                    did               => $did,
                    displayName       => $displayName,
            }
        }
    }

    class At::Lexicon::app::bsky::feed::getLikes::like {
        field $indexedAt : param;    # datetime, required
        field $createdAt : param;    # datetime, required
        field $actor : param;        # ::actor::profileView, required
        ADJUST {
            $actor     = At::Protocol::app::bsky::actor::profileView->new(%$actor) unless builtin::blessed $actor;
            $createdAt = At::Protocol::Timestamp->new( timestamp => $createdAt ) unless builtin::blessed $createdAt;
            $indexedAt = At::Protocol::Timestamp->new( timestamp => $indexedAt ) unless builtin::blessed $indexedAt;
        }

        # perlclass does not have :reader yet
        method indexedAt {$indexedAt}
        method createdAt {$createdAt}
        method actor     {$actor}

        method _raw() {
            { actor => $actor->_raw, createdAt => $createdAt->_raw, indexedAt => $indexedAt->_raw }
        }
    }

    # A declaration of a like.
    class At::Lexicon::app::bsky::feed::like {
        field $createdAt : param;    # datetime, required
        field $subject : param;      # ::com::atproto::repo::strongRef, required
        ADJUST {
            $createdAt = At::Protocol::Timestamp->new( timestamp => $createdAt )    unless builtin::blessed $createdAt;
            $subject   = At::Lexicon::com::atproto::repo::strongRef->new(%$subject) unless builtin::blessed $subject;
        }

        # perlclass does not have :reader yet
        method subject   {$subject}
        method createdAt {$createdAt}

        method _raw() {
            { '$type' => 'app.bsky.feed.like', createdAt => $createdAt->_raw, subject => $subject->_raw }
        }
    }

    # Allow replies from actors mentioned in your post.
    class At::Lexicon::app::bsky::feed::threadgate::mentionRule {

        # perlclass does not have :reader yet
        method _raw() {
            { '$type' => 'app.bsky.feed.threadgate.mentionRule' }
        }
    }

    # A declaration of a repost.
    class At::Lexicon::app::bsky::feed::repost {
        field $createdAt : param;    # datetime, required
        field $subject : param;      # ::com::atproto::repo::strongRef, required
        ADJUST {
            $createdAt = At::Protocol::Timestamp->new( timestamp => $createdAt )    unless builtin::blessed $createdAt;
            $subject   = At::Lexicon::com::atproto::repo::strongRef->new(%$subject) unless builtin::blessed $subject;
        }

        # perlclass does not have :reader yet
        method subject   {$subject}
        method createdAt {$createdAt}

        method _raw() {
            { '$type' => 'app.bsky.feed.repost', createdAt => $createdAt->_raw, subject => $subject->_raw }
        }
    }

    # Allow replies from actors you follow.
    class At::Lexicon::app::bsky::feed::threadgate::followingRule {

        method _raw() {
            { '$type' => 'app.bsky.feed.threadgate.followingRule' }
        }
    }

    # Allow replies from actors on a list.
    class At::Lexicon::app::bsky::feed::threadgate::listRule {
        field $list : param;    # at-uri, required
        ADJUST {
            $list = URI->new($list) unless builtin::blessed $list;
        }

        # perlclass does not have :reader yet
        method list {$list}

        method _raw() {
            { '$type' => 'app.bsky.feed.threadgate.listRule', list => $list->as_string }
        }
    }

    # Defines interaction gating rules for a thread. The rkey of the threadgate record should match the rkey of the thread's root post.
    class At::Lexicon::app::bsky::feed::threadgate {
        field $allow : param = ();    # array of union, max 5
        field $createdAt : param;     # timestamp, required
        field $post : param;          # at-uri, required
        ADJUST {
            use Carp;
            if ( defined $allow ) {
                Carp::cluck 'too many elements in allow; expected 5 max, found ' . scalar @$allow if scalar @$allow > 5;
                $allow = [
                    map {
                        return $_ if builtin::blessed $_;
                        my $type = delete $_->{'$type'};
                        return $_ = At::Lexicon::app::bsky::feed::threadgate::followingRule->new(%$_)
                            if $type eq 'app.bsky.feed.threadgate.followingRule';
                        return $_ = At::Lexicon::app::bsky::feed::threadgate::listRule->new(%$_) if $type eq 'app.bsky.feed.threadgate.listRule';
                        return $_ = At::Lexicon::app::bsky::feed::threadgate::mentionRule->new(%$_)
                            if $type eq 'app.bsky.feed.threadgate.mentionRule';
                        Carp::confess 'unknown type in allow: ' . $type;
                    } @$allow
                ];
            }
            $createdAt = At::Protocol::Timestamp->new( timestamp => $createdAt ) unless builtin::blessed $createdAt;
            $allow     = URI->new($allow)                                        unless builtin::blessed $allow;
        }

        # perlclass does not have :reader yet
        method allow     {$allow}
        method createdAt {$createdAt}
        method post      {$post}

        method _raw() {
            {
                defined $allow ? ( allow => [ map { $_->_raw } @$allow ] ) : (),
                    createdAt => $createdAt->_raw,
                    post      => $post->as_string
            }
        }
    }

    class At::Lexicon::app::bsky::feed::post {
        field $createdAt : param;      # timestamp, required
        field $embed : param  = ();    # union
        field $facets : param = ();    # array of app.bsky.richtext.facet
        field $labels : param = ();    # array of ::com::atproto::label::selfLabels
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

                    # fallback
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
