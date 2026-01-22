use v5.42;
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
__END__

=pod

=encoding utf-8

=head1 NAME

At::Error - Specialized Exception Class for AT Protocol

=head1 SYNOPSIS

    use At::Error qw[throw];

    # Create and throw
    At::Error->new( message => 'Something went wrong', fatal => 1 )->throw;

    # Using the exported throw helper
    throw At::Error->new( message => 'Oops' );

=head1 DESCRIPTION

C<At::Error> is the primary exception class used by L<At>. It supports stack traces and can be fatal or non-fatal
(warnings).

=head1 METHODS

=head2 C<new( message => ..., [ description => ..., fatal => ... ] )>

Constructor. C<message> is required.

=head2 C<message()>

Returns the error message.

=head2 C<description()>

Returns the optional error description (often from the server).

=head2 C<fatal()>

Returns true if the error is considered fatal.

=head2 C<throw()>

Throws the error. If C<fatal> is true, it uses C<die>. Otherwise, it uses C<warn>.

=head1 FUNCTIONS

=head2 C<register( $name, $is_fatal )>

Registers a new error constructor in the caller's namespace.

=head1 AUTHOR

Sank Robinson E<lt>sanko@cpan.orgE<gt>

=head1 LICENSE

Copyright (c) 2024-2026 Sanko Robinson. License: Artistic License 2.0.

=cut
