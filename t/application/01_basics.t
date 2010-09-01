use Test::More tests => 10;
use strict;
use warnings;

{ package TestGame;
  use base 'Jogo';
  use constant state_map =>
    { start =>
      { controller => 'Test',
        transitions =>
        { wait => sub {
              my $self = shift;
              ::pass('doing the wait transition');
              # make sure there's an event in the queue..
              SDL::Events::push_event(SDL::Event->new());
          },
          done => 'end' }
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

  my $first_cicle = 1;
  sub handle_event {
      my ($self, $app, $event) = @_;
      ::pass('Called handle event');
      if ($first_cicle--) {
          $app->request_transition('wait');
      } else {
          $app->request_transition('done');
      }
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
