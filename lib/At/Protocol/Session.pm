use v5.40;
use feature 'class';
no warnings 'experimental::class';

class At::Protocol::Session {
    field $accessJwt : param : reader //= ();
    field $did          : param : reader;
    field $handle       : param : reader = ();
    field $refreshJwt   : param : reader //= ();
    field $token_type   : param : reader = 'Bearer';
    field $dpop_key_jwk : param : reader = ();
    field $client_id    : param : reader = ();

    # Additional fields returned by server
    field $email           : param : reader = ();
    field $emailConfirmed  : param : reader = ();
    field $emailAuthFactor : param : reader = ();
    field $active          : param : reader = ();
    field $status          : param : reader = ();
    field $didDoc          : param : reader = ();
    field $scope           : param : reader = ();
    ADJUST {
        require At::Protocol::DID;
        $did = At::Protocol::DID->new($did) unless builtin::blessed $did;
    }

    method _raw {
        +{  accessJwt  => $accessJwt,
            did        => $did . "",
            refreshJwt => $refreshJwt,
            defined $handle ? ( handle => $handle . "" ) : (),
            token_type => $token_type,
            defined $dpop_key_jwk ? ( dpop_key_jwk => $dpop_key_jwk ) : (), defined $client_id ? ( client_id => $client_id ) : (),
        };
    }
}
1;
