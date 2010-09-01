use Test::More tests => 14;
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
              $self->transit_to('second');
              # make sure there's an event in the queue..
              SDL::Events::push_event(SDL::Event->new());
          },
        },
      },
      second =>
      { controller => 'Test2',
        transitions =>
        { done => 'end'
        },
      }
    };
};

{ package TestGame::Controller::Test;
  sub new {
      my $self = shift;
      ::pass('controller initialized: '.$self);
      return bless {}, $self;
  }

  sub activate {
      my $self = shift;
      ::pass('controller phasing in: '.ref $self);
  }

  sub handle_event {
      my ($self, $app, $event) = @_;
      ::pass('Called handle event: '.ref $self);
      $app->request_transition('wait');
  }

  sub deactivate {
      my $self = shift;
      ::pass('controller phasing out: '.ref $self);
  }


  sub DESTROY {
      my $self = shift;
      ::pass('controller destroyed: '.ref $self);
  }
};

{ package TestGame::Controller::Test2;
  use base 'TestGame::Controller::Test';
  sub handle_event {
      my ($self, $app, $event) = @_;
      ::pass('Called handle event');
      $app->request_transition('done');
  }
};

my $game = TestGame->new;
ok(!$game->initialized, 'game starts non initialized');

$game->setup();
ok($game->initialized,'$game->setup');

$game->run();
is($game->state, 'end', 'game ended');
