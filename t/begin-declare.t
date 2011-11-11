use strict;
use warnings;
use Test::More tests => 20;

use lib '../lib';

use Begin::Declare;

{
    MY $x = 3; eval 'is $x, 3'; BEGIN {eval 'is $x, 3'}

    MY ($y, $z) = (4, 5); eval 'is "$x $y $z", "3 4 5"'; BEGIN {eval 'is "$x $y $z", "3 4 5"'}

    MY @array = 1 .. 4; eval 'is "@array", "1 2 3 4"';   BEGIN {eval 'is "@array", "1 2 3 4"'}

    MY ($q, %hash) = ('qqq', a => 1, b => 2);
    BEGIN {
        eval 'is $q, "qqq"';
        eval 'is join(" ", sort keys %hash), "a b"';
    }
    eval 'is $q, "qqq"';
    eval 'is join(" ", sort keys %hash), "a b"';
}

{
    OUR $x = 3; eval 'is $x, 3'; BEGIN {eval 'is $x, 3'}

    OUR ($y, $z) = (4, 5); eval 'is "$x $y $z", "3 4 5"'; BEGIN {eval 'is "$x $y $z", "3 4 5"'}

    OUR @array = 1 .. 4; eval 'is "@array", "1 2 3 4"';   BEGIN {eval 'is "@array", "1 2 3 4"'}

    OUR ($q, %hash) = ('qqq', a => 1, b => 2);
    BEGIN {
        eval 'is $q, "qqq"';
        eval 'is join(" ", sort keys %hash), "a b"';
    }
    eval 'is $q, "qqq"';
    eval 'is join(" ", sort keys %hash), "a b"';
}
