package At::Lexicon::com::atproto::admin 0.02 {

    #~ https://github.com/bluesky-social/atproto/blob/main/lexicons/com/atproto/admin/defs.json
    use v5.38;
    use lib '../../../../../lib';
    no warnings 'experimental::class', 'experimental::builtin', 'experimental::try';    # Be quiet.
    use feature 'class', 'try';
    #
    class At::Lexicon::com::atproto::admin::statusAttr 1 {
        field $applied : param;
        field $ref : param //= ();

        # perlclass does not have :reader yet
        method applied {$applied}
        method ref     {$ref}

        method _raw() {
            +{ applied => \!!$applied, defined $ref ? ( ref => $ref ) : () };
        }
    };

    class At::Lexicon::com::atproto::admin::modEventView 1 {
        field $id : param;                      # int, required
        field $event : param;                   # union, required
        field $subject : param;                 # union, required
        field $subjectBlobCids : param;         # array, required
        field $createdBy : param;               # DID, required
        field $createdAt : param;               # Datetime, required
        field $creatorHandle : param //= ();    # string, required
        field $subjectHandle : param //= ();    # string, required
        ADJUST {
            $event     = At::_topkg( $event->{'$type'} )->new(%$event)     if !builtin::blessed $event   && defined $event->{'$type'};
            $subject   = At::_topkg( $subject->{'$type'} )->new(%$subject) if !builtin::blessed $subject && defined $subject->{'$type'};
            $createdBy = At::Protocol::DID->new( uri => $createdBy )             unless builtin::blessed $createdBy;
            $createdAt = At::Protocol::Timestamp->new( timestamp => $createdAt ) unless builtin::blessed $createdAt;
        }

        # perlclass does not have :reader yet
        method id              {$id}
        method event           {$event}
        method subject         {$subject}
        method subjectBlobCids {$subjectBlobCids}
        method createdBy       {$createdBy}
        method createdAt       {$createdAt}
        method creatorHandle   {$creatorHandle}
        method subjectHandle   {$creatorHandle}

        method _raw() {
            +{  id              => $id,
                event           => $event->_raw,
                subject         => $subject->_raw,
                subjectBlobCids => $subjectBlobCids,
                createdBy       => $createdBy->_raw,
                createdAt       => $createdAt->_raw,
                defined $creatorHandle ? ( creatorHandle => $creatorHandle ) : (), defined $subjectHandle ? ( subjectHandle => $subjectHandle ) : ()
            };
        }
    };

    class At::Lexicon::com::atproto::admin::modEventViewDetail 1 {
        field $id : param;              # int, required
        field $event : param;           # union, required
        field $subject : param;         # union, required
        field $subjectBlobs : param;    # array, required
        field $createdBy : param;       # DID, required
        field $createdAt : param;       # Datetime, required
        ADJUST {
            $event        = At::_topkg( $event->{'$type'} )->new(%$event)     if !builtin::blessed $event   && defined $event->{'$type'};
            $subject      = At::_topkg( $subject->{'$type'} )->new(%$subject) if !builtin::blessed $subject && defined $subject->{'$type'};
            $subjectBlobs = [ map { $_ = At::Lexicon::com::atproto::admin::blobView->new(%$_) unless builtin::blessed $_ } @$subjectBlobs ];
            $createdBy    = At::Protocol::DID->new( uri => $createdBy )             unless builtin::blessed $createdBy;
            $createdAt    = At::Protocol::Timestamp->new( timestamp => $createdAt ) unless builtin::blessed $createdAt;
        }

        # perlclass does not have :reader yet
        method id           {$id}
        method event        {$event}
        method subject      {$subject}
        method subjectBlobs {$subjectBlobs}
        method createdBy    {$createdBy}
        method createdAt    {$createdAt}

        method _raw() {
            +{  id          => $id,
                event       => $event->_raw,
                subject     => $subject->_raw,
                subjectBlob => [ map { $_->_raw } @$subjectBlobs ],
                createdBy   => $createdBy->_raw,
                createdAt   => $createdAt->_raw
            };
        }
    };

    class At::Lexicon::com::atproto::admin::reportView 1 {
        field $id : param;                          # int, required
        field $reasonType : param;                  # ::com::atproto::moderation::reasonType, required
        field $comment : param           //= ();    # string, required
        field $subjectRepoHandle : param //= ();    # string
        field $subject : param;                     # union, required
        field $reportedBy : param;                  # DID, required
        field $createdAt : param;                   # Datetime, required
        field $resolvedByActionIds : param;         # array, required
        ADJUST {
            $reasonType = At::Lexicon::com::atproto::moderation::reasonType->new(%$reasonType) unless builtin::blessed $reasonType;
            $subject    = At::_topkg( $subject->{'$type'} )->new(%$subject) if !builtin::blessed $subject && defined $subject->{'$type'};
            $reportedBy = At::Protocol::DID->new( uri => $reportedBy )            unless builtin::blessed $reportedBy;
            $createdAt  = At::Protocol::Timestamp->new( timestamp => $createdAt ) unless builtin::blessed $createdAt;
        }

        # perlclass does not have :reader yet
        method id                  {$id}
        method reasonType          {$reasonType}
        method comment             {$comment}
        method subjectRepoHandle   {$subjectRepoHandle}
        method subject             {$subject}
        method reportedBy          {$reportedBy}
        method createdAt           {$createdAt}
        method resolvedByActionIds {$resolvedByActionIds}

        method _raw() {
            +{  id         => $id,
                reasonType => $reasonType->_raw,
                comment    => $comment,
                defined $subjectRepoHandle ? ( subjectRepoHandle => $subjectRepoHandle ) : (),
                subject             => $subject->_raw,
                reportedBy          => $reportedBy->_raw,
                createdAt           => $createdAt->_raw,
                resolvedByActionIds => $resolvedByActionIds
            };
        }
    };

    class At::Lexicon::com::atproto::admin::subjectStatusView 1 {
        field $id : param;                          # int, required
        field $subject : param;                     # union, required
        field $subjectBlobCids : param   //= ();    # array
        field $subjectRepoHandle : param //= ();    # string
        field $updatedAt : param;                   # datetime, required
        field $createdAt : param;                   # datetime, required
        field $reviewState : param;                 # ::subjectReviewState, required
        field $comment : param        //= ();       # string
        field $muteUntil : param      //= ();       # datetime
        field $lastReviewedBy : param //= ();       # DID
        field $lastReviewedAt : param //= ();       # datetime
        field $lastReportedAt : param //= ();       # datetime
        field $takendown : param      //= ();       # bool
        field $suspendUntil : param   //= ();       # datetime
        ADJUST {
            $subject        = At::_topkg( $subject->{'$type'} )->new(%$subject) if !builtin::blessed $subject && defined $subject->{'$type'};
            $updatedAt      = At::Protocol::Timestamp->new( timestamp => $updatedAt ) unless builtin::blessed $updatedAt;
            $createdAt      = At::Protocol::Timestamp->new( timestamp => $createdAt ) unless builtin::blessed $createdAt;
            $reviewState    = At::Lexicon::com::atproto::admin::subjectReviewState->new(%$reviewState) unless builtin::blessed $reviewState;
            $muteUntil      = At::Protocol::Timestamp->new( timestamp => $muteUntil ) if defined $muteUntil      && !builtin::blessed $muteUntil;
            $lastReviewedBy = At::Protocol::DID->new( uri => $lastReviewedBy )        if defined $lastReviewedBy && !builtin::blessed $lastReviewedBy;
            $lastReviewedAt = At::Protocol::Timestamp->new( timestamp => $lastReviewedAt )
                if defined $lastReviewedAt && !builtin::blessed $lastReviewedAt;
            $lastReportedAt = At::Protocol::Timestamp->new( timestamp => $lastReportedAt )
                if defined $lastReportedAt && !builtin::blessed $lastReportedAt;
            $suspendUntil = At::Protocol::Timestamp->new( timestamp => $suspendUntil ) if defined $suspendUntil && !builtin::blessed $suspendUntil;
        }

        # perlclass does not have :reader yet
        method id                {$id}
        method subject           {$subject}
        method subjectBlobCids   {$subjectBlobCids}
        method subjectRepoHandle {$subjectRepoHandle}
        method createdAt         {$createdAt}
        method reviewState       {$reviewState}
        method comment           {$comment}
        method muteUntil         {$muteUntil}
        method lastReviewedBy    {$lastReviewedBy}
        method lastReviewedAt    {$lastReviewedAt}
        method lastReportedAt    {$lastReportedAt}
        method takendown         {$takendown}
        method suspendUntil      {$suspendUntil}

        method _raw() {
            +{  id      => $id,
                subject => $subject->_raw,
                defined $subjectBlobCids   ? ( subjectBlobCids   => $subjectBlobCids )   : (),
                defined $subjectRepoHandle ? ( subjectRepoHandle => $subjectRepoHandle ) : (),
                updatedAt   => $updatedAt->_raw,
                createdAt   => $createdAt->_raw,
                reviewState => $reviewState->_raw,
                defined $comment        ? ( comment        => $comment ) : (), defined $muteUntil ? ( muteUntil => $muteUntil->_raw ) : (),
                defined $lastReviewedBy ? ( lastReviewedBy => $lastReviewedBy->_raw ) : (),
                defined $lastReviewedAt ? ( lastReviewedAt => $lastReviewedAt->_raw ) : (),
                defined $lastReportedAt ? ( lastReportedAt => $lastReportedAt->_raw ) : (), defined $takendown ? ( takendown => \!!$takendown ) : (),
                defined $suspendUntil   ? ( suspendUntil   => $suspendUntil->_raw )   : ()
            };
        }
    };

    class At::Lexicon::com::atproto::admin::reportViewDetail 1 {
        field $id : param;                      # int, required
        field $reasonType : param;              # ::reasonType, required
        field $comment : param //= ();          # string
        field $subject : param;                 # union, required
        field $subjectStatus : param //= ();    # ::com::atproto::admin::subjectStatusView
        field $reportedBy : param;              # DID, required
        field $createdAt : param;               # datetime, required
        field $resolvedByActions : param;       # array, required
        ADJUST {
            $reasonType    = At::Lexicon::com::atproto::moderation::reasonType->new(%$reasonType) unless builtin::blessed $reasonType;
            $subject       = At::_topkg( $subject->{'$type'} )->new(%$subject) if !builtin::blessed $subject && defined $subject->{'$type'};
            $subjectStatus = At::Lexicon::com::atproto::subjectStatusView->new(%$subjectStatus)
                if defined $subjectStatus && !builtin::blessed $subjectStatus;
            $reportedBy        = At::Protocol::DID->new( uri => $reportedBy )                             unless !builtin::blessed $reportedBy;
            $createdAt         = At::Protocol::Timestamp->new( timestamp => $createdAt )                  unless builtin::blessed $createdAt;
            $resolvedByActions = At::Lexicon::com::atproto::admin::modEventView->new(%$resolvedByActions) unless builtin::blessed $resolvedByActions;
        }

        # perlclass does not have :reader yet
        method id                {$id}
        method reasonType        {$reasonType}
        method comment           {$comment}
        method subject           {$subject}
        method subjectStatus     {$subjectStatus}
        method reportedBy        {$reportedBy}
        method createdAt         {$createdAt}
        method resolvedByActions {$resolvedByActions}

        method _raw() {
            +{  id         => $id,
                reasonType => $reasonType,
                defined $comment ? ( comment => $comment ) : (),
                subject => $subject->_raw,
                defined $subjectStatus ? ( subjectStatus => $subjectStatus->_raw ) : (),
                reportedBy        => $reportedBy->_raw,
                createdAt         => $createdAt->_raw,
                resolvedByActions => [ map { $_->_raw } @$resolvedByActions ]
            };
        }
    };
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
