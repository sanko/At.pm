use v5.42;
use lib '../lib';
use At::UserAgent;
use Crypt::PK::ECC;
use Crypt::JWT qw[decode_jwt];
use Data::Dumper;
my $ua  = At::UserAgent::Tiny->new();
my $key = Crypt::PK::ECC->new();
$key->generate_key('secp256r1');
$ua->set_tokens( undef, undef, 'DPoP', $key );
my $url    = 'https://bsky.social/oauth/par';
my $method = 'POST';
say 'Generating DPoP proof for ' . $method . ' ' . $url;
my $proof = $ua->_generate_dpop_proof( $url, $method );
say 'Proof: $proof';
my $decoded = decode_jwt( token => $proof, key => $key );
say 'Decoded Payload: ' . Dumper($decoded);

# Decode header manually since decode_jwt might not show it easily without extra args
use MIME::Base64 qw(decode_base64url);
use JSON::PP     qw(decode_json);
my ($header_b64) = split /\./, $proof;
my $header       = decode_json( decode_base64url($header_b64) );
say 'Decoded Header: ' . Dumper($header);
