use v5.40;
use feature 'class';
no warnings 'experimental::class';

class At::Error 1.1 {
    use Carp qw[];
    use overload
        bool => sub {0},
        '""' => sub ( $s, $u, $q ) { $s->message };
    field $message     : param : reader;
    field $description : param : reader //= ();
    field $fatal       : param : reader //= 0;
    field @stack;
    ADJUST {
        my $i = 0;
        while ( my $info = $self->_caller_info( ++$i ) ) {
            push @stack, $info;
        }
    }

    method _caller_info($i) {
        my ( $package, $filename, $line, $subroutine ) = caller($i);
        return unless $package;
        return { package => $package, file => $filename, line => $line, sub_name => $subroutine };
    }

    method throw() {
        my ( undef, $file, $line ) = caller();
        my $msg = join "\n\t", sprintf( qq[%s at %s line %d\n], $message, $file, $line ),
            map { sprintf q[%s called at %s line %d], $_->{sub_name}, $_->{file}, $_->{line} } @stack;
        $fatal ? die "$msg\n" : warn "$msg\n";
    }

    # Compatibility with old At::Error
    sub import {
        my $class = shift;
        my $from  = caller;
        no strict 'refs';
        my @syms = @_ ? @_ : qw[register throw];
        for my $sym (@syms) {
            if ( $sym eq 'register' ) {
                *{ $from . '::register' } = \&register;
            }
            elsif ( $sym eq 'throw' ) {
                *{ $from . '::throw' } = sub {
                    my $err = shift;
                    if ( builtin::blessed($err) && $err->isa('At::Error') ) {
                        $err->throw;
                    }
                    else {
                        die $err;
                    }
                };
            }
        }
    }

    sub register( $name, $is_fatal = 0 ) {
        my ($from) = caller;
        no strict 'refs';
        *{ $from . '::' . $name } = sub ( $msg, $desc = '' ) {
            At::Error->new( message => $msg, description => $desc, fatal => $is_fatal );
        };
    }
}
1;
