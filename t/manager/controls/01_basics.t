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
     { 'Controls' => 'SDL',
       'Model'    => 'Controls',
     };
};

{  package MyGame::Manager::Controls;
   use base 'Jogo::Manager::Controls';
   use SDL::Events;
   use constant controls_map =>
     { move_up =>
       { type => 'key_state',
         sym  => SDLK_UP
       },
       move_down =>
       { type => 'key_state',
         sym  => SDLK_DOWN
       },
       move_left =>
       { type => 'key_state',
         sym  => SDLK_LEFT
       },
       move_right =>
       { type => 'key_state',
         sym  => SDLK_RIGHT
       },
       fire =>
       { type => 'key_press',
         sym  => SDLK_SPACE
       }
     };
};

{  package MyGame::Manager::Model;
   sub new {
       return bless {}, shift;
   };
   sub add_listener {
       ::fail('nobody listens to the model');
   };
   sub enqueue {
       my ($self, $ctrl, $app, $event_type, $data) = @_;
       ::is($event_type, 'Controls', 'received a controls event');
       $app->request_transition('done');
   };
   sub activate {}
   sub deactivate {}
};
