package At::Lexicon::app::bsky::actor 0.02 {
    use v5.38;
    no warnings 'experimental::class', 'experimental::builtin';    # Be quiet.
    use feature 'class';
    our @CARP_NOT;
    #
    class At::Lexicon::app::bsky::actor::profileViewBasic {
        use Carp;
        use bytes;
        field $labels : param = ();         # array of com.atproto.label.defs#label
        field $did : param;                 # string
        field $handle : param;              # string
        field $displayName : param = ();    # string
        field $avatar : param      = ();    # string
        field $viewer : param      = ();    # ::viewerState
        ADJUST {                            # TODO: handle types such as string maxlen, etc.
            $labels = [ map { $_ = At::Lexicon::com::atproto::label->new(%$_) unless builtin::blessed $_ } @$labels ] if defined $labels;
            $did    = At::Protocol::DID->new( uri => $did )      unless builtin::blessed $did;
            $handle = At::Protocol::Handle->new( id => $handle ) unless builtin::blessed $handle;
            Carp::cluck q[displayName is too long; expected 64 bytes or fewer]       if defined $displayName && bytes::length $displayName > 64;
            Carp::cluck q[displayName is too long; expected 640 characters or fewer] if defined $displayName && length $displayName > 640;
            $viewer = At::Lexicon::app::bsky::actor::viewerState->new(%$viewer)      if defined $viewer && !builtin::blessed $viewer;
        }

        # perlclass does not have :reader yet
        method labels      {$labels}
        method did         {$did}
        method handle      {$handle}
        method displayName {$displayName}
        method avatar      {$avatar}
        method viewer      {$viewer}

        method _raw() {
            {   labels      => defined $labels ? [ map { $_->_raw } @$labels ] : undef,
                did         => $did->_raw,
                handle      => $handle->_raw,
                displayName => $displayName,
                avatar      => $avatar,
                viewer      => defined $viewer ? $viewer->_raw : undef
            };
        }
    }

    class At::Lexicon::app::bsky::actor::profileView {
        field $handle : param;              # string, handle, required
        field $labels : param      = ();    # array of labels
        field $description : param = ();    # string, 256 grapheme, 2560 len
        field $avatar : param      = ();    # string
        field $displayName : param = ();    # string, 64 grapheme, 640 len
        field $indexedAt : param   = ();    # datetime
        field $did : param;                 # did, required
        field $viewer : param = ();         # viewState
        ADJUST {
            $handle = At::Protocol::Handle->new( id => $handle ) unless builtin::blessed $handle;
            $labels = [ map { $_ = At::Lexicon::com::atproto::label->new(%$_) unless builtin::blessed $_ } @$labels ] if defined $labels;
            Carp::cluck q[description is too long; expected 2560 bytes or fewer]     if defined $description && bytes::length $description > 2560;
            Carp::cluck q[description is too long; expected 256 characters or fewer] if defined $description && length $description > 256;
            Carp::cluck q[displayName is too long; expected 640 bytes or fewer]      if defined $displayName && bytes::length $displayName > 640;
            Carp::cluck q[displayName is too long; expected 64 characters or fewer]  if defined $displayName && length $displayName > 64;
            $indexedAt = At::Protocol::Timestamp->new( timestamp => $indexedAt )   if defined $indexedAt && !builtin::blessed $indexedAt;
            $did       = At::Protocol::DID->new( uri => $did )                     if defined $did       && !builtin::blessed $did;
            $viewer    = At::Lexicon::app::bsky::actor::viewerState->new(%$viewer) if defined $viewer    && !builtin::blessed $viewer;
        }

        # perlclass does not have :reader yet
        method handle      {$handle}
        method labels      {$labels}
        method description {$description}
        method avatar      {$avatar}
        method displayName {$displayName}
        method indexedAt   {$indexedAt}
        method did         {$did}
        method viewer      {$viewer}

        method _raw() {
            {   handle      => $handle->_raw,
                labels      => defined $labels ? [ map { $_->_raw } @$labels ] : undef,
                description => $description,
                avatar      => $avatar,
                displayName => $displayName,
                indexedAt   => defined $indexedAt ? $indexedAt->_raw : undef,
                did         => $did->_raw,
                viewer      => defined $viewer ? $viewer->_raw : undef
            }
        }
    }

    class At::Lexicon::app::bsky::actor::profileViewDetailed {
        field $banner : param         = ();    # string
        field $followersCount : param = ();    # int
        field $description : param    = ();    # string, len 2560 max, grapheme 256 max
        field $indexedAt : param      = ();    # datetime
        field $did : param;                    # string, did, required
        field $viewer : param = ();            # viewerState
        field $labels : param = ();            # array of lables
        field $handle : param;                 # handle, required
        field $avatar : param       = ();      # string
        field $displayName : param  = ();      # string, len 640 max, grapheme 64 max
        field $followsCount : param = ();      # int
        field $postsCount : param   = ();      # int
        ADJUST {
            use Carp;
            Carp::cluck q[description is too long; expected 2560 bytes or fewer]     if defined $description && bytes::length $description > 2560;
            Carp::cluck q[description is too long; expected 256 characters or fewer] if defined $description && length $description > 256;
            $indexedAt = At::Protocol::Timestamp->new( timestamp => $indexedAt ) if defined $indexedAt && !builtin::blessed $indexedAt;
            $did       = At::Protocol::DID->new( uri => $did ) unless builtin::blessed $did;
            $viewer    = At::Lexicon::app::bsky::actor::viewerState->new(%$viewer) if defined $viewer && !builtin::blessed $viewer;
            $labels    = [ map { $_ = At::Lexicon::com::atproto::label->new(%$_) unless builtin::blessed $_ } @$labels ] if defined $labels;
            $handle    = At::Protocol::Handle->new( id => $handle ) unless builtin::blessed $handle;
            Carp::cluck q[displayName is too long; expected 640 bytes or fewer]     if defined $displayName && bytes::length $displayName > 640;
            Carp::cluck q[displayName is too long; expected 64 characters or fewer] if defined $displayName && length $displayName > 64;
        }

        # perlclass does not have :reader yet
        method banner         {$banner}
        method followersCount {$followersCount}
        method description    {$description}
        method indexedAt      {$indexedAt}
        method did            {$did}
        method viewer         {$viewer}
        method labels         {$labels}
        method handle         {$handle}
        method avatar         {$avatar}
        method displayName    {$displayName}
        method followsCount   {$followsCount}
        method postsCount     {$postsCount}

        method _raw() {
            {   banner         => $banner,
                followersCount => $followersCount,
                description    => $description,
                indexedAt      => defined $indexedAt ? $indexedAt->_raw : undef,
                did            => $did->_raw,
                viewer         => defined $viewer ? $viewer->_raw : undef,
                labels         => [ map { $_->_raw } @$labels ],
                handle         => $handle->_raw,
                avatar         => $avatar,
                displayName    => $displayName,
                followsCount   => $followsCount,
                postsCount     => $postsCount
            }
        }
    }

    class At::Lexicon::app::bsky::actor::viewerState {
        field $mutedByList : param    = ();    # app.bsky.graph.defs#listViewBasic
        field $muted : param          = ();    # bool
        field $followedBy : param     = ();    # at-uri
        field $blockedBy : param      = ();    # bool
        field $blockingByList : param = ();    # app.bsky.graph.defs#listViewBasic
        field $blocking : param       = ();    # at-uri
        field $following : param      = ();    # at-uri
        ADJUST {                               # TODO: handle types such as string maxlen, etc.
            $mutedByList = At::Lexicon::app::bsky::graph::listViewBasic->new( list => $mutedByList )
                if defined $mutedByList && !builtin::blessed $mutedByList;
            $followedBy     = URI->new($followedBy) if defined $followedBy && !builtin::blessed $followedBy;
            $blockingByList = At::Lexicon::app::bsky::graph::listViewBasic->new( list => $blockingByList )
                if defined $blockingByList && !builtin::blessed $blockingByList;
            $blocking  = URI->new($blocking)  if defined $blocking  && !builtin::blessed $blocking;
            $following = URI->new($following) if defined $following && !builtin::blessed $following;
        }

        # perlclass does not have :reader yet
        method mutedByList    {$mutedByList}
        method muted          {$muted}
        method followedBy     {$followedBy}
        method blockedBy      {$blockedBy}
        method blockingByList {$blockingByList}
        method blocking       {$blocking}
        method following      {$following}

        method _raw() {
            {   mutedByList    => defined $mutedByList ? $mutedByList->_raw : undef,
                muted          => !!$muted,
                followedBy     => defined $followedBy ? $followedBy->as_string : undef,
                blockedBy      => !!$blockedBy,
                blockingByList => defined $blockingByList ? $blockingByList->_raw : undef,
                blocking       => defined $blocking       ? $blocking->as_string  : undef,
                following      => defined $following      ? $following->as_string : undef,
            }
        }
    }

    class At::Lexicon::app::bsky::actor::preferences {
        field $items : param = ();    # array of unions
        use Carp;
        our @CARP_NOT;
        use experimental 'try';
        ADJUST {
            our @CARP_NOT;
            $items = [
                map {
                    return $_ if builtin::blessed $_;
                    if ( defined $_->{'$type'} ) {
                        my $type = delete $_->{'$type'};
                        return $_ = At::Lexicon::app::bsky::actor::adultContentPref->new(%$_) if $type eq 'app.bsky.actor.defs#adultContentPref';
                        return $_ = At::Lexicon::app::bsky::actor::contentLabelPref->new(%$_) if $type eq 'app.bsky.actor.defs#contentLabelPref';
                        return $_ = At::Lexicon::app::bsky::actor::savedFeedsPref->new(%$_)   if $type eq 'app.bsky.actor.defs#savedFeedsPref';
                        return $_ = At::Lexicon::app::bsky::actor::personalDetailsPref->new(%$_)
                            if $type eq 'app.bsky.actor.defs#personalDetailsPref';
                        return $_ = At::Lexicon::app::bsky::actor::feedViewPref->new(%$_)   if $type eq 'app.bsky.actor.defs#feedViewPref';
                        return $_ = At::Lexicon::app::bsky::actor::threadViewPref->new(%$_) if $type eq 'app.bsky.actor.defs#threadViewPref';
                    }
                    try {
                        $_ = At::Lexicon::app::bsky::actor::adultContentPref->new(%$_);
                    }
                    catch ($e) {
                        try {
                            $_ = At::Lexicon::app::bsky::actor::contentLabelPref->new(%$_);
                        }
                        catch ($e) {
                            try {
                                $_ = At::Lexicon::app::bsky::actor::savedFeedsPref->new(%$_);
                            }
                            catch ($e) {
                                try {
                                    $_ = At::Lexicon::app::bsky::actor::personalDetailsPref->new(%$_);
                                }
                                catch ($e) {
                                    try {
                                        $_ = At::Lexicon::app::bsky::actor::feedViewPref->new(%$_);
                                    }
                                    catch ($e) {
                                        try {
                                            $_ = At::Lexicon::app::bsky::actor::threadViewPref->new(%$_);
                                        }
                                        catch ($e) {
                                            Carp::croak 'malformed preference: ' . $e;
                                        }
                                    }
                                }
                            }
                        }
                    }
                } @$items
                ]
                if defined $items;
        }

        # perlclass does not have :reader yet
        method items {$items}

        method _raw() {
            [ map { $_->_raw } @$items ]
        }
    }

    class At::Lexicon::app::bsky::actor::adultContentPref {
        field $enabled : param;    # bool, required

        # perlclass does not have :reader yet
        method enabled {$enabled}

        method _raw() {
            { '$type' => 'app.bsky.actor.defs#adultContentPref', enabled => \$enabled }    # bool ref in JSON::Tiny
        }
    }

    class At::Lexicon::app::bsky::actor::contentLabelPref {
        field $label : param;         # string, required
        field $visibility : param;    # string, union

        #
        ADJUST {
            use Carp;
            our @CARP_NOT;
            Carp::carp q[visibility is an unknown value] unless grep { $visibility eq $_ } qw[show warn hide];
        }

        # perlclass does not have :reader yet
        method label      {$label}
        method visibility {$visibility}

        method _raw() {
            { '$type' => 'app.bsky.actor.defs#contentLabelPref', label => $label, visibility => $visibility }
        }
    }

    class At::Lexicon::app::bsky::actor::savedFeedsPref {
        field $saved : param;     # array, at-uri, required
        field $pinned : param;    # array, at-uri, required
        ADJUST {
            use URI;
            $saved  = [ map { $_ = URI->new($_) unless builtin::blessed $_ } @$saved ];
            $pinned = [ map { $_ = URI->new($_) unless builtin::blessed $_ } @$pinned ];
        }

        # perlclass does not have :reader yet
        method saved  {$saved}
        method pinned {$pinned}

        method _raw() {
            {   '$type' => 'app.bsky.actor.defs#savedFeedsPref',
                saved   => [ map { $_->as_string } @$saved ],
                pinned  => [ map { $_->as_string } @$pinned ]
            }
        }
    }

    class At::Lexicon::app::bsky::actor::personalDetailsPref {

        #~ The birth date of account owner.
        field $birthDate : param = ();    # datetime
        ADJUST {
            $birthDate = At::Protocol::Timestamp->new( timestamp => $birthDate ) unless builtin::blessed $birthDate;
        }

        # perlclass does not have :reader yet
        method birthDate {$birthDate}

        method _raw() {
            { '$type' => 'app.bsky.actor.defs#personalDetailsPref', birthDate => $birthDate->as_string }
        }
    }

    class At::Lexicon::app::bsky::actor::feedViewPref {

        #~ Hide replies in the feed.
        field $hideReplies : param = ();    # bool

        #~ Hide quote posts in the feed.
        field $hideQuotePosts : param = ();    # bool

        #~ Hide replies in the feed if they are not by followed users.
        field $hideRepliesByUnfollowed : param = ();    # bool

        #~ The URI of the feed, or an identifier which describes the feed.
        field $feed : param;                            # string, required

        #~ Hide replies in the feed if they do not have this number of likes.
        field $hideRepliesByLikeCount : param = ();     # int

        #~ Hide reposts in the feed.
        field $hideReposts : param = ();                # bool

        # perlclass does not have :reader yet
        method hideReplies             {$hideReplies}
        method hideQuotePosts          {$hideQuotePosts}
        method hideRepliesByUnfollowed {$hideRepliesByUnfollowed}
        method feed                    {$feed}
        method hideRepliesByLikeCount  {$hideRepliesByLikeCount}
        method hideReposts             {$hideReposts}

        method _raw() {
            {   '$type'                 => 'app.bsky.actor.defs#feedViewPref',
                hideReplies             => !!$hideReplies,
                hideQuotePosts          => !!$hideQuotePosts,
                hideRepliesByUnfollowed => !!$hideRepliesByUnfollowed,
                feed                    => $feed,
                hideRepliesByLikeCount  => $hideRepliesByLikeCount,
                hideReposts             => !!$hideReposts
            }
        }
    }

    class At::Lexicon::app::bsky::actor::threadViewPref {

        # Sorting mode for threads.
        field $sort : param = ();    # string, enum

        # Show followed users at the top of all replies.
        field $prioritizeFollowedUsers : param = ();    # bool
        ADJUST {
            use Carp;
            Carp::cluck q[sort is an unknown value] unless grep { $sort eq $_ } qw[oldest newest most-likes random];
        }

        # perlclass does not have :reader yet
        method sort                    {$sort}
        method prioritizeFollowedUsers {$prioritizeFollowedUsers}

        method _raw() {
            { '$type' => 'app.bsky.actor.defs#threadViewPref', sort => $sort, prioritizeFollowedUsers => !!$prioritizeFollowedUsers }
        }
    }

    # A declaration of a profile.
    class At::Lexicon::app::bsky::actor::profile {
        field $avatar : param      = ();    # image, 1000000 bytes max, png or jpeg
        field $description : param = ();    # string, 256 graphemes max, 2560 bytes max
        field $labels : param      = ();    # union (why?) of selfLabels
        field $banner : param      = ();    # image, 1000000 bytes max, png or jpeg
        field $displayName : param = ();    # string, 64 graphemes max, 640 bytes max
        ADJUST {
            use Path::Tiny;
            use Carp;
            $avatar = path($avatar)->slurp_utf8 if defined $avatar && -f $avatar;
            Carp::confess 'avatar is more than 1000000 bytes' if defined $avatar && length $avatar > 1000000;
            $labels = At::Lexicon::com::atproto::label::selfLabel->new( values => $labels ) if defined $labels && !builtin::blessed $labels;
            $banner = path($banner)->slurp_utf8                                             if defined $banner && -f $banner;
            Carp::confess 'banner is more than 1000000 bytes'      if defined $banner      && length $banner > 1000000;
            Carp::confess 'displayName is more than 64 characters' if defined $displayName && length $displayName > 64;
            Carp::confess 'displayName is more than 640 bytes'     if defined $displayName && bytes::length $displayName > 640;
        }

        # perlclass does not have :reader yet
        method avatar      {$avatar}
        method description {$description}
        method labels      {$labels}
        method banner      {$banner}
        method displayName {$displayName}

        method _raw() {
            { avatar => $avatar, description => $description, labels => $labels->_raw, banner => $banner, displayName => $displayName }
        }
    }
};
1;
__END__

=encoding utf-8

=head1 NAME

At::Lexicon::app::bsky::actor - A reference to an actor in the network

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
