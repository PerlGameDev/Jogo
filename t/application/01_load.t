use Test::More;
use strict;
use warnings;

use_ok('Jogo');

eval {
    package Test;
    use base 'Jogo';
};
ok(!$@, 'Could declare a test class');

my $game = Test->new;
ok(!$game->initialized, 'Game starts as not initialized.');

done_testing;
