package Begin::Declare;
    use warnings;
    use strict;
    use Devel::Declare;
    use Carp;

    sub import {
        shift;
        /^(my|our)$/i or croak "not exported: $_" for @_;
        @_ or @_ = qw (MY OUR);
        my $caller = caller;
        Devel::Declare->setup_for ($caller => {
            map {$_  => {const => \&parser}} @_
        });
        no strict 'refs';
        *{$caller.'::'.$_} = sub (@) {} for @_;
    }

    our ($Declarator, $Offset);

    sub skip_declarator {
        my $linestr = Devel::Declare::get_linestr();
        my $length  = Devel::Declare::toke_move_past_token($Offset);
        my $dec     = substr($linestr, $Offset, $length);
        $Offset += $length;
        $dec
    }

    sub skipspace {
        $Offset += Devel::Declare::toke_skipspace($Offset);
    }

    sub strip_parens {
        skipspace;
        my $linestr = Devel::Declare::get_linestr();
        if (substr($linestr, $Offset, 1) eq '(') {
            my $length = Devel::Declare::toke_scan_str($Offset);
            my $proto  = Devel::Declare::get_lex_stuff();
            Devel::Declare::clear_lex_stuff();

            $linestr = Devel::Declare::get_linestr();
            substr($linestr, $Offset, $length) = '';
            Devel::Declare::set_linestr($linestr);
            return $proto;
        }
        return;
    }

    sub strip_to {
        my $to = strip_parens;
        return $to if $to;
        my $linestr = Devel::Declare::get_linestr();
        ($to) = substr($linestr, $Offset) =~ /^([\$\%\@]\w+)/;
        $to or croak "not a variable name: ".substr($linestr, $Offset);
        substr($linestr, $Offset, length $to) = '';
        Devel::Declare::set_linestr($linestr);
        $to
    }

    sub strip_equals {
        skipspace;
        my $linestr = Devel::Declare::get_linestr();
        unless (substr($linestr, $Offset, 1) eq '=') {
            croak "error: next char must be '=': ".substr($linestr, $Offset);
        }
        substr($linestr, $Offset, 1) = '';
        Devel::Declare::set_linestr($linestr);
        skipspace;
    }

    sub inject {
        my $inject  = shift;
        my $linestr = Devel::Declare::get_linestr;
        substr($linestr, $Offset, 0) = $inject;
        Devel::Declare::set_linestr($linestr);
    }

    sub parser {
        local ($Declarator, $Offset) = @_;
        my $dec = lc skip_declarator;
        my $to  = strip_to;
        strip_equals;
        inject ";$dec ($to); use Begin::Declare::Lift ($to) = "
    }

    $INC{'Begin/Declare/Lift.pm'}++;
    sub Begin::Declare::Lift::import {}

    our $VERSION = '0.01';

=head1 NAME

Begin::Declare - compile time my and our

=head1 VERSION

version 0.01

=head1 SYNOPSIS

don't you hate writing:

    my ($foo, @bar);
    BEGIN {
        ($foo, @bar) = ('fooval', 1 .. 10);
    }

when you should be able to write:

    MY ($foo, @bar) = ('fooval', 1 .. 10);

just C< use Begin::Declare; > and you can.

=head1 EXPORT

    use Begin::Declare;

is the same as:

    use Begin::Declare qw (MY OUR);

you can also write:

    use Begin::Declare qw (My Our);

if you prefer those names.

=head1 SUBROUTINES

=head2 MY

works just like the keyword C< my > except it lifts the assignment to compile
time.

    MY $x = 1;            # my $x; BEGIN {$x = 1}
    MY ($y, $z) = (2, 3); # my ($y, $z); BEGIN {($y, $z) = (2, 3)}

=head2 OUR

works just like the keyword C< our > except it lifts the assignment to compile
time.

    OUR ($a, $b, @c) = 1 .. 10;
    # our ($a, $b, @c); BEGIN {($a, $b, @c) = (1 .. 10)}

=head1 AUTHOR

Eric Strom, C<< <asg at cpan.org> >>

=head1 BUGS

please report any bugs or feature requests to C<bug-begin-declare at rt.cpan.org>,
or through the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Begin-Declare>.
I will be notified, and then you'll automatically be notified of progress on your
bug as I make changes.

=head1 ACKNOWLEDGEMENTS

the authors of L<Devel::Declare>

=head1 LICENSE AND COPYRIGHT

copyright 2011 Eric Strom.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

see http://dev.perl.org/licenses/ for more information.

=cut

1
