use Test::More tests => 8;
use strict;
use warnings;

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
      ::pass('controller initialized.');
      return bless {}, shift;
  }

  sub activate {
      my $self = shift;
      ::pass('controller phasing in');
  }

  sub handle_event {
      my ($self, $app, $event) = @_;
      ::pass('Called handle event');
      $app->request_transition('done');
  }

  sub deactivate {
      my $self = shift;
      ::pass('controller phasing out');
  }


  sub DESTROY {
      ::pass('controller destroyed');
  }
};

my $game = TestGame->new;
ok(!$game->initialized, 'game starts non initialized');

$game->setup();
ok($game->initialized,'$game->setup');

$game->run();
is($game->state, 'end', 'game ended');
