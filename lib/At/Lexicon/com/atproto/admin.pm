package At::Lexicon::com::atproto::admin 0.02 {

    #~ https://github.com/bluesky-social/atproto/blob/main/lexicons/com/atproto/admin/defs.json
    use v5.38;
    use lib '../../../../../lib';
    no warnings 'experimental::class', 'experimental::builtin', 'experimental::try';    # Be quiet.
    use feature 'class', 'try';
    #
    class At::Lexicon::com::atproto::admin::statusAttr 1 {
        field $applied : param;
        field $ref : param = ();
    };

    class At::Lexicon::com::atproto::admin::actionView 1 {
        use At::Lexicon::com::atproto::repo::strongRef;
        use Carp;
        field $id : param;
        field $action : param;
        field $durationInHours : param = ();
        field $subject : param;
        field $subjectBlobCids : param;
        field $createLabelVals : param   = ();
        field $negativeLabelVals : param = ();
        field $reason : param;
        field $createdBy : param;
        field $createdAt : param;
        field $reversal : param = ();
        field $resolvedReportIds : param;
        ADJUST {
            $action = At::Lexicon::com::atproto::admin::actionType->new( action => $action ) unless builtin::blessed $action;
            if ( !builtin::blessed $subject ) {
                try { $subject = At::Lexicon::com::atproto::admin::repoRef->new(%$subject) }
                catch ($e) {
                    try { $subject = At::Lexicon::com::atproto::repo::strongRef->new(%$subject) }
                    catch ($e) {
                        Carp::cluck 'subject must be of type com.atproto.admin.repoRef or com.atproto.repo.strongRef'
                    }
                }
            }
            $createdBy         = At::Protocol::DID->new( uri => $createdBy )                       unless builtin::blessed $createdBy;
            $createdAt         = At::Protocol::Timestamp->new( timestamp => $createdAt )           unless builtin::blessed $createdAt;
            $reversal          = At::Lexicon::com::atproto::admin::actionReversal->new(%$reversal) unless builtin::blessed $reversal;
            $resolvedReportIds = []                                                                unless defined $resolvedReportIds;
        }
    };

    class At::Lexicon::com::atproto::admin::actionViewDetail 1 {
        use Carp;
        field $id : param;
        field $action : param;
        field $durationInHours : param = ();
        field $subject : param;
        field $subjectBlobs : param;
        field $createLabelVals : param   = ();
        field $negativeLabelVals : param = ();
        field $reason : param;
        field $createdBy : param;
        field $createdAt : param;
        field $reversal : param = ();
        field $resolvedReports : param;
        ADJUST {
            $action = At::Lexicon::com::atproto::admin::actionType->new( action => $action ) unless builtin::blessed $action;
            if ( !builtin::blessed $subject ) {
                try { $subject = At::Lexicon::com::atproto::admin::repoView->new(%$subject) }
                catch ($e) {
                    try {
                        $subject = At::Lexicon::com::atproto::repo::repoViewNotFound->new(%$subject)
                    }
                    catch ($e) {
                        try {
                            $subject = At::Lexicon::com::atproto::repo::recordView->new(%$subject)
                        }
                        catch ($e) {
                            try {
                                $subject = At::Lexicon::com::atproto::repo::recordViewNotFound->new(%$subject)
                            }
                            catch ($e) {
                                Carp::cluck
                                    'subject must be of type com.atproto.admin.repoView, com.atproto.admin.repoViewNotFound, or com.atproto.admin.recordView, or com.atproto.repo.recordViewNotFound'
                            }
                        }
                    }
                }
            }
            $subjectBlobs    = At::Lexicon::com::atproto::admin::blobView->new(%$subjectBlobs)   unless builtin::blessed $subjectBlobs;
            $createdBy       = At::Protocol::DID->new( uri => $createdBy )                       unless builtin::blessed $createdBy;
            $createdAt       = At::Protocol::Timestamp->new( timestamp => $createdAt )           unless builtin::blessed $createdAt;
            $reversal        = At::Lexicon::com::atproto::admin::actionReversal->new(%$reversal) unless builtin::blessed $reversal;
            $resolvedReports = [ map { builtin::blessed $_ ? $_ : At::Lexicon::com::atproto::admin::reportView->new(%$_) } @$resolvedReports ];
        }
    }

    class At::Lexicon::com::atproto::admin::actionViewCurrent 1 {
        field $id : param;
        field $action : param;
        field $durationInHours : param = ();
        ADJUST {
            $action = At::Lexicon::com::atproto::admin::actionType->new( action => $action ) unless builtin::blessed $action;
        }
    }

    class At::Lexicon::com::atproto::admin::actionReversal 1 {
        field $reason : param;
        field $createdBy : param;
        field $createdAt : param;
        ADJUST {
            $createdAt = At::Protocol::Timestamp->new( timestamp => $createdAt ) unless builtin::blessed $createdAt;
        }
    }

    class At::Lexicon::com::atproto::admin::actionType 1 {
        field $action : param;
        ADJUST {
            use Carp;
            Carp::croak 'known values are #takedown, #flag, #acknowledge, and #escalate'
                unless grep { '#' . $_ eq $action }
                qw[takedown flag acknowledge escalate]
        }
    }

    class At::Lexicon::com::atproto::admin::reportView 1 {
        field $id : param;
        field $reasonType : param;
        field $reason : param            = ();
        field $subjectRepoHandle : param = ();
        field $subject : param;
        field $reportedBy : param;
        field $createdAt : param;
        field $resolvedByActionIds : param;
        ADJUST {
            $reasonType = At::Lexicon::com::atproto::moderation::reasonType->new(%$reasonType) unless builtin::blessed $reasonType;
            if ( !builtin::blessed $subject ) {
                try { $subject = At::Lexicon::com::atproto::admin::repoRef->new(%$subject) }
                catch ($e) {
                    try { $subject = At::Lexicon::com::atproto::repo::strongRef->new(%$subject) }
                    catch ($e) {
                        Carp::cluck 'subject must be of type com.atproto.admin.repoRef or com.atproto.repo.strongRef'
                    }
                }
            }
            $createdAt = At::Protocol::Timestamp->new( timestamp => $createdAt ) unless builtin::blessed $createdAt;
        }
    }

    class At::Lexicon::com::atproto::admin::reportViewDetail 1 {
        field $id : param;
        field $reasonType : param;
        field $reason : param = ();
        field $subject : param;
        field $reportedBy : param;
        field $createdAt : param;
        field $resolvedByActionIds : param;
        ADJUST {
            $reasonType = At::Lexicon::com::atproto::moderation::reasonType->new(%$reasonType) unless builtin::blessed $reasonType;
            if ( !builtin::blessed $subject ) {
                try { $subject = At::Lexicon::com::atproto::admin::repoView->new(%$subject) }
                catch ($e) {
                    try {
                        $subject = At::Lexicon::com::atproto::repo::repoViewNotFound->new(%$subject)
                    }
                    catch ($e) {
                        try {
                            $subject = At::Lexicon::com::atproto::repo::recordView->new(%$subject)
                        }
                        catch ($e) {
                            try {
                                $subject = At::Lexicon::com::atproto::repo::recordViewNotFound->new(%$subject)
                            }
                            catch ($e) {
                                Carp::cluck
                                    'subject must be of type com.atproto.admin.repoView, com.atproto.admin.repoViewNotFound, or com.atproto.admin.recordView, or com.atproto.repo.recordViewNotFound'
                            }
                        }
                    }
                }
            }
            $createdAt = At::Protocol::Timestamp->new( timestamp => $createdAt ) unless builtin::blessed $createdAt;
        }
    }

    class At::Lexicon::com::atproto::admin::repoView 1 {
        field $did : param;
        field $handle : param;
        field $email : param = ();
        field $relatedRecords : param;
        field $indexAt : param;
        field $moderation : param;
        field $invitedBy : param;
        field $invitesDisabled : param;
        field $inviteNote : param;
        ADJUST {
            $indexAt    = At::Protocol::Timestamp->new( timestamp => $indexAt )           unless builtin::blessed $indexAt;
            $moderation = At::Lexicon::com::atproto::admin::moderation->new(%$moderation) unless builtin::blessed $moderation;
            $invitedBy  = At::Lexicon::com::atproto::server::inviteCode->new(%$invitedBy) unless builtin::blessed $invitedBy;
        }
    }

    class At::Lexicon::com::atproto::admin::repoViewDetail 1 {
        field $did : param;
        field $handle : param;
        field $email : param = ();
        field $relatedRecords : param;
        field $indexedAt : param;
        field $moderation : param;
        field $labels : param           = [];
        field $invitedBy : param        = ();
        field $invites : param          = [];
        field $invitesDisabled : param  = ();
        field $inviteNote : param       = ();
        field $emailConfirmedAt : param = ();
        ADJUST {
            $indexedAt        = At::Protocol::Timestamp->new( timestamp => $indexedAt )               unless builtin::blessed $indexedAt;
            $moderation       = At::Lexicon::com::atproto::admin::moderationDetail->new(%$moderation) unless builtin::blessed $moderation;
            $labels           = [ map { $_ = At::Lexicon::com::atproto::label->new(%$_) unless builtin::blessed $_; } @$labels ];
            $invitedBy        = At::Lexicon::com::atproto::server::inviteCode->new(%$invitedBy) unless builtin::blessed $invitedBy;
            $invites          = [ map { $_ = At::Lexicon::com::atproto::server::inviteCode->new(%$_) unless builtin::blessed $_; } @$invites ];
            $emailConfirmedAt = At::Protocol::Timestamp->new( timestamp => $emailConfirmedAt )
                if defined $emailConfirmedAt && !builtin::blessed $emailConfirmedAt;
        }
    }

    class At::Lexicon::com::atproto::admin::accountView 1 {
        field $did : param;
        field $handle : param;
        field $email : param = ();
        field $indexAt : param;
        field $invitedBy : param        = ();
        field $invites : param          = [];
        field $invitesDisabled : param  = ();
        field $emailConfirmedAt : param = ();
        field $inviteNote : param       = ();
        ADJUST {
            $invitedBy        = At::Lexicon::com::atproto::server::inviteCode->new(%$invitedBy) unless builtin::blessed $invitedBy;
            $invites          = [ map { $_ = At::Lexicon::com::atproto::server::inviteCode->new(%$_) unless builtin::blessed $_; } @$invites ];
            $indexAt          = At::Protocol::Timestamp->new( timestamp => $indexAt )          unless builtin::blessed $indexAt;
            $emailConfirmedAt = At::Protocol::Timestamp->new( timestamp => $emailConfirmedAt ) unless builtin::blessed $emailConfirmedAt;
        }
    }

    class At::Lexicon::com::atproto::admin::repoViewNotFound 1 {
        field $did : param;
    }

    class At::Lexicon::com::atproto::admin::repoRef 1 {
        field $did : param;
    }

    class At::Lexicon::com::atproto::admin::repoBlobRef 1 {
        field $did : param;
        field $cid : param;
        field $recordUri : param = ();
        ADJUST {
            use URI;
            $recordUri = URI->new($recordUri) if defined $recordUri && !builtin::blessed $recordUri;
        }
    }

    class At::Lexicon::com::atproto::admin::recordView 1 {
        field $uri : param;
        field $cid : param;
        field $value : param;
        field $blobCids : param;
        field $indexAt : param;
        field $moderation : param;
        field $repo : param;
        ADJUST {
            use URI;
            $uri        = URI->new($uri)                                                  unless builtin::blessed $uri;
            $indexAt    = At::Protocol::Timestamp->new( timestamp => $indexAt )           unless builtin::blessed $indexAt;
            $moderation = At::Lexicon::com::atproto::admin::moderation->new(%$moderation) unless builtin::blessed $moderation;
            $repo       = At::Lexicon::com::atproto::admin::repoView->new(%$repo)         unless builtin::blessed $repo;
        }
    }

    class At::Lexicon::com::atproto::admin::recordViewDetail 1 {
        field $uri : param;
        field $cid : param;
        field $value : param;
        field $blobs : param;
        field $labels : param = [];
        field $indexAt : param;
        field $moderation : param;
        field $repo : param;
        ADJUST {
            use URI;
            $uri        = URI->new($uri) unless builtin::blessed $uri;
            $blobs      = [ map { $_ = At::Lexicon::com::atproto::admin::blobView->new(%$_) unless builtin::blessed $_; } @$blobs ];
            $labels     = [ map { $_ = At::Lexicon::com::atproto::label->new(%$_)           unless builtin::blessed $_; } @$labels ];
            $indexAt    = At::Protocol::Timestamp->new( timestamp => $indexAt )                 unless builtin::blessed $indexAt;
            $moderation = At::Lexicon::com::atproto::admin::moderationDetail->new(%$moderation) unless builtin::blessed $moderation;
            $repo       = At::Lexicon::com::atproto::admin::repoView->new(%$repo)               unless builtin::blessed $repo;
        }
    }

    class At::Lexicon::com::atproto::admin::recordViewNotFound 1 {
        field $uri : param;
        ADJUST {
            use URI;
            $uri = URI->new($uri) unless builtin::blessed $uri;
        }
    }

    class At::Lexicon::com::atproto::admin::moderation 1 {
        field $currentAction : param = [];
        ADJUST {
            $currentAction = At::Lexicon::com::atproto::admin::actionViewCurrent->new(%$currentAction) unless builtin::blessed $currentAction;
        }
    }

    class At::Lexicon::com::atproto::admin::moderationDetail 1 {
        field $currentAction : param = [];
        field $actions : param;
        field $reports : param;
        ADJUST {
            $currentAction = At::Lexicon::com::atproto::admin::actionViewCurrent->new(%$currentAction) unless builtin::blessed $currentAction;
            $actions       = [ map { builtin::blessed $_ ? $_ : At::Lexicon::com::atproto::admin::actionView->new(%$_) } @$actions ];
            $reports       = [ map { builtin::blessed $_ ? $_ : At::Lexicon::com::atproto::admin::reportView->new(%$_) } @$reports ];
        }
    }

    class At::Lexicon::com::atproto::admin::blobView 1 {
        field $cid : param;
        field $memeType : param;
        field $size : param;
        field $createdAt : param;
        field $details : param    = ();
        field $moderation : param = ();
        ADJUST {
            $createdAt = At::Protocol::Timestamp->new( timestamp => $createdAt ) unless builtin::blessed $createdAt;
            if ( !builtin::blessed $details ) {
                try { $details = At::Lexicon::com::atproto::admin::imageDetails->new(%$details) }
                catch ($e) {
                    try { $details = At::Lexicon::com::atproto::repo::videoDetails->new(%$details) }
                    catch ($e) {
                        Carp::cluck 'details must be of type com.atproto.admin.imageDetails or com.atproto.admin.videoDetails'
                    }
                }
            }
            $moderation = At::Lexicon::com::atproto::admin::moderation->new(%$moderation) unless builtin::blessed $moderation
        }
    }

    class At::Lexicon::com::atproto::admin::imageDetails 1 {
        field $width : param;
        field $height : param;
    }

    class At::Lexicon::com::atproto::admin::videoDetails 1 {
        field $width : param;
        field $height : param;
        field $length : param;
    }
}
1;
__END__

=encoding utf-8

=head1 NAME

At::Lexicon::com::atproto::admin - Core Admin Classes

=head1 See Also

L<https://atproto.com/>

L<https://github.com/bluesky-social/atproto/blob/main/lexicons/com/atproto/admin/defs.json>

=head1 LICENSE

Copyright (C) Sanko Robinson.

This library is free software; you can redistribute it and/or modify it under the terms found in the Artistic License
2. Other copyrights, terms, and conditions may apply to data transmitted through this module.

=head1 AUTHOR

Sanko Robinson E<lt>sanko@cpan.orgE<gt>

=cut
