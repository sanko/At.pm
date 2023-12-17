use strict;
use warnings;
use Test2::V0;
use Test2::Tools::Class qw[isa_ok can_ok];
#
BEGIN { chdir '../' if !-d 't'; }
use lib '../lib', 'lib', '../blib/arch', '../blib/lib', 'blib/arch', 'blib/lib', '../../', '.';
#
use At;
subtest 'init' => sub {
    my $at = At->new( host => 'https://bsky.social' );
    ok my $desc = $at->server->describeServer(), '$at->server->describeServer()';
    like $desc->{availableUserDomains}, ['.bsky.social'], '... availableUserDomains';
    like $desc->{inviteCodeRequired},   !!1,              '... inviteCodeRequired';     # XXX - Might be false in the future
    isa_ok $desc->{links}, ['At::Lexicon::com::atproto::server::describeServer::links'], '... links';
    like $desc->{links}->_raw, {
        privacyPolicy  => qr[https://.+],                                               # https://blueskyweb.xyz/support/privacy-policy
        termsOfService => qr[https://.+]                                                # https://blueskyweb.xyz/support/tos
        },
        '... links->_raw';
};
#
subtest 'live' => sub {
    my $at = At->new( host => 'https://bsky.social', identifier => 'atperl.bsky.social', password => 'ck2f-bqxl-h54l-xm3l' );
    subtest 'listAppPasswords' => sub {
        ok my $pws = $at->server->listAppPasswords(), '$at->server->listAppPasswords()';
        isa_ok $pws->{passwords}->[0], ['At::Lexicon::com::atproto::server::listAppPasswords::appPassword'], 'correct type';
    };
    subtest 'getSession' => sub {
        ok my $ses = $at->server->getSession(), '$at->server->getSession()';
        isa_ok $ses->{handle}, ['At::Protocol::Handle'], '...handle';
        isa_ok $ses->{did},    ['At::Protocol::DID'],    '...did';
    };
    subtest '$at->server->can(...)' => sub {
        note 'running these tests are either impossible with an app password session or would modify the account in harmful ways';
        can_ok $at->server, [$_], $_
            for sort
            qw[getAccountInviteCodes updateEmail requestEmailUpdate revokeAppPassword resetPassword reserveSigningKey requestPasswordReset requestEmailConfirmation requestAccountDelete deleteSession deleteAccount createSession createInviteCodes createInviteCode createAppPassword createAccount confirmEmail];
    }
};
#
done_testing;
