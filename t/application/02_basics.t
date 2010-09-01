use Test::More tests => 6;
use strict;
use warnings;
use SDL::Event;
use SDL::Events ':all';

{ package TestGame;
  use base 'Jogo';
  use constant state_map =>
    { start =>
      { controller => 'Test',
        transitions =>
        { done => 'end' }
      }
    };
};

{ package TestGame::Controller::Test;

  sub new {
      ::ok('controller initialized.');
      return bless {}, shift;
  }

  sub handle_event {
      my ($self, $app, $event) = @_;
      ::ok('Called handle event');
      $app->request_transition('done');
  }

  sub DESTROY {
      ::ok('controller destroyed');
  }
};

my $game = TestGame->new;
ok(!$game->initialized, 'game starts non initialized');

$game->setup();
ok($game->initialized,'$game->setup');

$game->run();
is($game->state, 'end', 'game ended');
