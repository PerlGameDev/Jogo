use strict;
use warnings;
use Test::More tests => 13;

{  package MyGame;
   use base 'Jogo';
   use constant state_map =>
     { start =>
       { controller => 'Test',
         transitions =>
         { done => 'end' }
       }
     };
};

{  package MyGame::Controller::Test;
   use base 'Jogo::Controller';
   use constant managers_map =>
     { 'View'  => [ 'Model', 'SDL' ],
       'Model' => 'SDL',
     };
};

{  package MyGame::Manager::View;

   sub new {
       ::pass('initializes view manager');
       return bless {}, shift;
   };

   sub activate {
       ::pass('view manager activated')
   }

   sub deactivate {
       ::pass('view manager deactivated')
   }

   sub add_listener {
       ::fail('nobody listens to the view');
   };

   sub enqueue {
       my ($self, $ctrl, $app, $event_type, $data) = @_;
       ::is($event_type, 'sdl', 'received an sdl event');
       $app->request_transition('done');
   };
};

{  package MyGame::Manager::Model;
   sub new {
       ::pass('initializes model manager');
       return bless {}, shift;
   };

   sub activate {
       ::pass('model manager activated')
   }

   sub deactivate {
       ::pass('model manager deactivated')
   }

   sub add_listener {
       my $self = shift;
       ::pass('The view listens to the model');
   };

   sub enqueue {
       my ($self, $ctrl, $app, $event_type, $data) = @_;
       ::is($event_type, 'sdl', 'the model should receive the event as well');
   };
};

pass('declarations worked');
my $game = MyGame->new;
ok($game, 'Game instantiated');
$game->setup;
ok($game->initialized, 'Game initialized');
$game->run;
pass('game out of runloop');
undef $game;
done_testing;
