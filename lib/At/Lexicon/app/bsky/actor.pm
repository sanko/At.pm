package At::Lexicon::app::bsky::actor 0.18 {
    use v5.40.0;
    use Object::Pad;
    no warnings 'experimental::builtin';    # Be quiet.
    use Carp;
    use URI;
    use Path::Tiny;
    #
    class At::Lexicon::app::bsky::actor::profileViewBasic {
        field $did : param : reader;                   # string, did, required
        field $handle : param : reader;                # string, handle, required
        field $displayName : param : reader //= ();    # string
        field $avatar : param : reader      //= ();    # string
        field $viewer : param : reader      //= ();    # ::viewerState
        field $labels : param : reader      //= ();    # array of com.atproto.label.defs#label
        ADJUST {
            $did    = At::Protocol::DID->new( uri => $did )      unless builtin::blessed $did;
            $handle = At::Protocol::Handle->new( id => $handle ) unless builtin::blessed $handle;
            Carp::cluck q[displayName is too long] if defined $displayName && ( length $displayName > 640 || At::_glength($displayName) > 64 );
            $viewer = At::Lexicon::app::bsky::actor::viewerState->new(%$viewer) if defined $viewer && !builtin::blessed $viewer;
            $labels = [ map { $_ = At::Lexicon::com::atproto::label->new(%$_) unless builtin::blessed $_ } @$labels ] if defined $labels;
        }

        method _raw() {
            +{  did    => $did->_raw,
                handle => $handle->_raw,
                defined $displayName ? ( displayName => $displayName )  : (), defined $avatar ? ( avatar => $avatar )                       : (),
                defined $viewer      ? ( viewer      => $viewer->_raw ) : (), defined $labels ? ( labels => [ map { $_->_raw } @$labels ] ) : ()
            };
        }
    }

    class At::Lexicon::app::bsky::actor::profileView {
        field $did : param : reader;                   # string, did, required
        field $handle : param : reader;                # string, handle, required
        field $displayName : param : reader //= ();    # string, 64 grapheme, 640 len
        field $description : param : reader //= ();    # string, 256 grapheme, 2560 len
        field $avatar : param : reader      //= ();    # string
        field $indexedAt : param : reader   //= ();    # datetime
        field $viewer : param : reader      //= ();    # viewState
        field $labels : param : reader      //= ();    # array of labels
        ADJUST {
            $did    = At::Protocol::DID->new( uri => $did ) if defined $did && !builtin::blessed $did;
            $handle = At::Protocol::Handle->new( id => $handle ) unless builtin::blessed $handle;
            Carp::cluck q[displayName is too long] if defined $displayName && length $displayName > 64;
            Carp::cluck q[description is too long] if defined $description && ( length $description > 256 || At::_glength($description) > 2560 );
            $indexedAt = At::Protocol::Timestamp->new( timestamp => $indexedAt ) if defined $indexedAt && !builtin::blessed $indexedAt;
            $labels    = [ map { $_ = At::Lexicon::com::atproto::label->new(%$_) unless builtin::blessed $_ } @$labels ] if defined $labels;
            $viewer    = At::Lexicon::app::bsky::actor::viewerState->new(%$viewer) if defined $viewer && !builtin::blessed $viewer;
        }

        method _raw() {
            +{  did    => $did->_raw,
                handle => $handle->_raw,
                defined $displayName ? ( displayName => $displayName )  : (), defined $description ? ( description => $description )             : (),
                defined $avatar      ? ( avatar      => $avatar )       : (), defined $indexedAt   ? ( indexedAt   => $indexedAt->_raw )         : (),
                defined $viewer      ? ( viewer      => $viewer->_raw ) : (), defined $labels      ? ( labels => [ map { $_->_raw } @$labels ] ) : ()
            };
        }
    }

    class At::Lexicon::app::bsky::actor::profileViewDetailed {
        field $did : param : reader;                      # string, did, required
        field $handle : param : reader;                   # handle, required
        field $displayName : param : reader    //= ();    # string, len 640 max, grapheme 64 max
        field $description : param : reader    //= ();    # string, len 2560 max, grapheme 256 max
        field $avatar : param : reader         //= ();    # string
        field $banner : param : reader         //= ();    # string
        field $followersCount : param : reader //= ();    # int
        field $followsCount : param : reader   //= ();    # int
        field $postsCount : param : reader     //= ();    # int
        field $indexedAt : param : reader      //= ();    # datetime
        field $viewer : param : reader         //= ();    # viewerState
        field $labels : param : reader         //= ();    # array of lables
        ADJUST {
            $did    = At::Protocol::DID->new( uri => $did )      unless builtin::blessed $did;
            $handle = At::Protocol::Handle->new( id => $handle ) unless builtin::blessed $handle;
            Carp::cluck q[displayName is too long] if defined $displayName && ( length $displayName > 64  || At::_glength($displayName) > 640 );
            Carp::cluck q[description is too long] if defined $description && ( length $description > 256 || At::_glength($description) > 2560 );
            $indexedAt = At::Protocol::Timestamp->new( timestamp => $indexedAt )   if defined $indexedAt && !builtin::blessed $indexedAt;
            $viewer    = At::Lexicon::app::bsky::actor::viewerState->new(%$viewer) if defined $viewer    && !builtin::blessed $viewer;
            $labels    = [ map { $_ = At::Lexicon::com::atproto::label->new(%$_) unless builtin::blessed $_ } @$labels ] if defined $labels;
        }

        method _raw() {
            +{  did    => $did->_raw,
                handle => $handle->_raw,
                defined $displayName    ? ( displayName    => $displayName )    : (), defined $description  ? ( description  => $description )  : (),
                defined $avatar         ? ( avatar         => $avatar )         : (), defined $banner       ? ( banner       => $banner )       : (),
                defined $followersCount ? ( followersCount => $followersCount ) : (), defined $followsCount ? ( followsCount => $followsCount ) : (),
                defined $postsCount     ? ( postsCount     => $postsCount )     : (), defined $indexedAt    ? ( indexedAt => $indexedAt->_raw ) : (),
                defined $viewer ? ( viewer => +{ %{ $viewer->_raw } } ) : (), defined $labels ? ( labels => [ map { $_->_raw } @$labels ] )     : ()
            };
        }
    }

    class At::Lexicon::app::bsky::actor::profileAssociated {
        field $lists : reader : param        //= ();    # integer
        field $feedgens : reader : param     //= ();    # integer
        field $starterPacks : reader : param //= ();    # integer
        field $labeler : reader : param      //= ();    # bool
        field $chat : reader : param         //= ();    # #profileAssociatedChat
        ADJUST {
            $labeler = !!$labeler                                                        if defined $labeler;
            $chat    = At::Lexicon::app::bsky::actor::profileAssociatedChat->new(%$chat) if defined $chat && !builtin::blessed $chat;
        }

        method _raw() {
            +{  defined $lists        ? ( lists        => $lists )        : (),
                defined $feedgens     ? ( feedgens     => $feedgens )     : (),
                defined $starterPacks ? ( starterPacks => $starterPacks ) : (),
                defined $labeler      ? ( labeler      => $labeler )      : (),
                defined $chat         ? ( chat         => $chat )         : ()
            };
        }
    }

    class At::Lexicon::app::bsky::actor::profileAssociatedChat {
        field $allowIncoming : reader : param;    # emum, required
        ADJUST {
            require Carp;
            Carp::cluck q[unknown value for allowIncoming] if !grep { $allowIncoming eq $_ } qw[all none following];
        }

        method _raw() {
            +{ allowIncoming => $allowIncoming };
        }
    }

    class At::Lexicon::app::bsky::actor::viewerState {
        field $muted : param : reader          //= ();    # bool
        field $mutedByList : param : reader    //= ();    # app.bsky.graph.defs#listViewBasic
        field $blockedBy : param : reader      //= ();    # bool
        field $blocking : param : reader       //= ();    # at-uri
        field $blockingByList : param : reader //= ();    # app.bsky.graph.defs#listViewBasic
        field $following : param : reader      //= ();    # at-uri
        field $followedBy : param : reader     //= ();    # at-uri
        ADJUST {
            $muted       = !!$muted                                                         if defined $muted       && builtin::blessed $muted;
            $mutedByList = At::Lexicon::app::bsky::graph::listViewBasic->new(%$mutedByList) if defined $mutedByList && !builtin::blessed $mutedByList;
            $blockedBy   = !!$blockedBy                                                     if defined $blockedBy   && builtin::blessed $blockedBy;
            $blocking    = URI->new($blocking)                                              if defined $blocking    && !builtin::blessed $blocking;
            $blockingByList = At::Lexicon::app::bsky::graph::listViewBasic->new(%$blockingByList)
                if defined $blockingByList && !builtin::blessed $blockingByList;
            $following  = URI->new($following)  if defined $following  && !builtin::blessed $following;
            $followedBy = URI->new($followedBy) if defined $followedBy && !builtin::blessed $followedBy;
        }

        method _raw() {
            +{  defined $muted          ? ( muted          => \$muted )                : (),
                defined $mutedByList    ? ( mutedByList    => $mutedByList->_raw )     : (),
                defined $blockedBy      ? ( blockedBy      => \$blockedBy )            : (),
                defined $blocking       ? ( blocking       => $blocking->as_string )   : (),
                defined $blockingByList ? ( blockingByList => $blockingByList->_raw )  : (),
                defined $following      ? ( following      => $following->as_string )  : (),
                defined $followedBy     ? ( followedBy     => $followedBy->as_string ) : ()
            };
        }
    }

    class At::Lexicon::app::bsky::actor::knownFollowers {
        field $count : reader : param;        # integer, required
        field $followers : reader : param;    # array of #profileViewBasic, required
        ADJUST {
            require Carp;
            $followers = [ map { $_ = At::Lexicon::app::bsky::actor::profileViewBasic->new(%$_) unless builtin::blessed $_ } @$followers ];
        }

        method _raw() {
            +{ followers => [ map { $_->_raw } @$followers ] };
        }
    }

    class At::Lexicon::app::bsky::actor::preferences {
        field $items : param : reader //= ();    # array of unions
        ADJUST {
            $items = [ map { At::_topkg( $_->{'$type'} )->new(%$_) if !builtin::blessed $_ && defined $_->{'$type'}; } @$items ] if defined $items;
        }

        method _raw() {
            +[ map { $_->_raw } @$items ];
        }
    }

    class At::Lexicon::app::bsky::actor::adultContentPref {
        field $type : param($type) : reader;     # record field
        field $enabled : reader : param;         # bool, required, false by default
        ADJUST {
            $enabled = !!$enabled if builtin::blessed $enabled;
        }

        method _raw() {
            +{ '$type' => $type, enabled => \$enabled };
        }
    }

    class At::Lexicon::app::bsky::actor::contentLabelPref {
        field $type : param($type) : reader;     # record field
        field $label : param : reader;           # string, required
        field $visibility : param : reader;      # string, union
        ADJUST {
            Carp::carp q[unknown value for visibility] unless grep { $visibility eq $_ } qw[show warn hide];
        }

        method _raw() {
            +{ '$type' => $type, label => $label, visibility => $visibility };
        }
    }

    class At::Lexicon::app::bsky::actor::savedFeed {
        field $id : param : reader;              # string, required
        field $type : param : reader;            # string enum, required
        field $value : param : reader;           # string, required
        field $pinned : param : reader;          # bool, required
        ADJUST {
            Carp::carp q[unknown value for type] unless grep { $type eq $_ } qw[feed list timeline];
            $pinned = !!$pinned if builtin::blessed $pinned;
        }

        method _raw() {
            +{ $id => $id, type => $type, value => $value, pinned => $pinned };
        }
    }

    class At::Lexicon::app::bsky::actor::savedFeedsPrefV2 {
        field $items : param : reader;           # array of #safedFeed, required
        ADJUST {
            $items = [ map { $_ = At::Lexicon::app::bsky::actor::savedFeed->new(%$_) unless builtin::blessed $_ } @$items ];
        }

        method _raw() {
            +{ items => [ map { $_->_raw } @$items ] };
        }
    }

    class At::Lexicon::app::bsky::actor::savedFeedsPref {
        field $type : param($type) : reader;             # record field
        field $pinned : param : reader;                  # array, at-uri, required
        field $saved : param : reader;                   # array, at-uri, required
        field $timelineIndex : param : reader //= ();    # integer
        ADJUST {
            $pinned = [ map { $_ = URI->new($_) unless builtin::blessed $_ } @$pinned ];
            $saved  = [ map { $_ = URI->new($_) unless builtin::blessed $_ } @$saved ];
        }

        method _raw() {
            +{  '$type' => $type,
                pinned  => [ map { $_->as_string } @$pinned ],
                saved   => [ map { $_->as_string } @$saved ],
                defined $timelineIndex ? ( timelineIndex => $timelineIndex ) : ()
            };
        }
    }

    class At::Lexicon::app::bsky::actor::personalDetailsPref {
        field $type : param($type) : reader;         # record field
        field $birthDate : param : reader //= ();    # datetime
        ADJUST {
            $birthDate = At::Protocol::Timestamp->new( timestamp => $birthDate ) unless builtin::blessed $birthDate;
        }

        method _raw() {
            +{ '$type' => $type, birthDate => $birthDate->_raw };
        }
    }

    class At::Lexicon::app::bsky::actor::feedViewPref {
        field $type : param($type) : reader;                       # record field
        field $feed : param : reader;                              # string, required
        field $hideReplies : param : reader             //= ();    # bool
        field $hideRepliesByUnfollowed : param : reader //= ();    # bool
        field $hideRepliesByLikeCount : param : reader  //= ();    # int
        field $hideReposts : param : reader             //= ();    # bool
        field $hideQuotePosts : param : reader          //= ();    # bool
        ADJUST {
            $hideReplies             = !!$hideReplies             if defined $hideReplies             && builtin::blessed $hideReplies;
            $hideRepliesByUnfollowed = !!$hideRepliesByUnfollowed if defined $hideRepliesByUnfollowed && builtin::blessed $hideRepliesByUnfollowed;
            $hideReposts             = !!$hideReposts             if defined $hideReposts             && builtin::blessed $hideReposts;
            $hideQuotePosts          = !!$hideQuotePosts          if defined $hideQuotePosts          && builtin::blessed $hideQuotePosts;
        }

        method _raw() {
            +{  '$type' => $type,
                feed    => $feed,
                defined $hideReplies             ? ( hideReplies             => \$hideReplies )             : (),
                defined $hideRepliesByUnfollowed ? ( hideRepliesByUnfollowed => \$hideRepliesByUnfollowed ) : (),
                defined $hideRepliesByLikeCount  ? ( hideRepliesByLikeCount  => $hideRepliesByLikeCount )   : (),
                defined $hideReposts ? ( hideReposts => \$hideReposts ) : (), defined $hideQuotePosts ? ( hideQuotePosts => \$hideQuotePosts ) : ()
            };
        }
    }

    class At::Lexicon::app::bsky::actor::threadViewPref {
        field $type : param($type) : reader;                       # record field
        field $sort : param : reader                    //= ();    # string, enum
        field $prioritizeFollowedUsers : param : reader //= ();    # bool
        ADJUST {
            Carp::cluck q[unknown value for sort] if defined $sort && !grep { $sort eq $_ } qw[oldest newest most-likes random];
            $prioritizeFollowedUsers = !!$prioritizeFollowedUsers if defined $prioritizeFollowedUsers && builtin::blessed $prioritizeFollowedUsers;
        }

        method _raw() {
            +{  '$type' => $type,
                defined $sort                    ? ( sort                    => $sort )                     : (),
                defined $prioritizeFollowedUsers ? ( prioritizeFollowedUsers => \$prioritizeFollowedUsers ) : ()
            };
        }
    }

    class At::Lexicon::app::bsky::actor::interestsPref {
        field $type : param($type) : reader;    # record field
        field $tags : param : reader;           # array requiredm
        ADJUST {
            Carp::cluck q[too many tags; 100 max] if scalar @$tags > 100;
            grep { Carp::cluck q[tag "] . $_ . q[" is too long] if length $_ > 640 || At::_glength($_) > 64; } @$tags;
        }

        method _raw() {
            +{ '$type' => $type, tags => $tags };
        }
    }

    class At::Lexicon::app::bsky::actor::mutedWord {
        field $id : param : reader;             # string, required
        field $value : param : reader;          # string
        field $targets : param : reader;        # array of string enum, required
        field $actorTarget : param : reader;    # string enum
        field $expiresAt : param : reader;      # datetime
        ADJUST {
            # Carp::cluck q[too many tags; 100 max] if scalar @$tags > 100;
            # grep { Carp::cluck q[tag "] . $_ . q[" is too long] if length $_ > 640 || At::_glength($_) > 64; } @$tags;
        }

        method _raw() {
            +{ id => $id, value => $value, targets => [ map { $_->_raw } @$targets ], actorTarget => $actorTarget, expiresAt => $expiresAt->_raw };
        }
    }

    # A declaration of a profile.
    class At::Lexicon::app::bsky::actor::profile {
        field $displayName : param : reader //= ();    # string, 64 graphemes max, 640 bytes max
        field $description : param : reader //= ();    # string, 256 graphemes max, 2560 bytes max
        field $avatar : param : reader      //= ();    # blob, 1000000 bytes max, png or jpeg
        field $banner : param : reader      //= ();    # blob, 1000000 bytes max, png or jpeg
        field $labels : param : reader      //= ();    # union (why?) of selfLabels
        ADJUST {
            Carp::confess 'displayName is too long' if defined $displayName && ( length $displayName > 640  || At::_glength($displayName) > 64 );
            Carp::confess 'description is too long' if defined $description && ( length $description > 2560 || At::_glength($description) > 256 );
            $avatar = path($avatar)->slurp_utf8     if defined $avatar && -f $avatar;
            Carp::confess 'avatar is more than 1000000 bytes'                               if defined $avatar && length $avatar > 1000000;
            $banner = path($banner)->slurp_utf8                                             if defined $banner && -f $banner;
            Carp::confess 'banner is more than 1000000 bytes'                               if defined $banner && length $banner > 1000000;
            $labels = At::Lexicon::com::atproto::label::selfLabel->new( values => $labels ) if defined $labels && !builtin::blessed $labels;
        }

        method _raw() {
            +{  '$type' => 'app.bsky.actor.profile',
                defined $displayName ? ( displayName => $displayName )  : (), defined $description ? ( description => $description ) : (),
                defined $avatar      ? ( avatar      => $avatar )       : (), defined $banner      ? ( banner      => $banner )      : (),
                defined $labels      ? ( labels      => $labels->_raw ) : ()
            };
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
