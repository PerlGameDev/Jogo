use strict;
use warnings;
use threads;
use Test::More tests => 14;

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

   my $counter = 0;
   sub enqueue {
       my ($self, $ctrl, $app, $event_type, $data) = @_;
       return ::fail('was not expecting '.$event_type.' events')
           if $event_type ne 'Controls';

       my $control = $data->{control};
       my $status  = $data->{status};

       if ($counter == 0) {
           ::is($control, 'fire', 'Fire event...');
       } elsif ($counter == 1) {
           ::is($control, 'move_up', 'Changed the state of the move_up control');
           ::ok($status,  'moving up...');
       } elsif ($counter == 2) {
           ::is($control, 'move_left', 'Changed the state of the move_left control');
           ::ok($status,  'moving left...');
       } elsif ($counter == 3) {
           ::is($control, 'move_left', 'Changed the state of the move_left control');
           ::ok(!$status,  'not moving left anymore...');
       } elsif ($counter == 4) {
           ::is($control, 'move_up', 'Changed the state of the move_up control');
           ::ok(!$status,  'not moving up anymore...');
       } else {
           ::is($control, 'fire', 'Fire event...');
           $app->request_transition('done');
       }
       $counter++;
   };

   sub activate {}
   sub deactivate {}
};

pass('declarations worked');
my $game = MyGame->new;
ok($game, 'Game instantiated');
$game->setup;
ok($game->initialized, 'Game initialized');

my $th = async {
    use SDL;
    use SDL::Events;
    use SDL::Event;
    SDL::delay(50);
    my $event = SDL::Event->new;
    $event->type(SDL_KEYDOWN);
    $event->key_sym(SDLK_SPACE);
    SDL::Events::push_event($event);
    $event->type(SDL_KEYDOWN);
    $event->key_sym(SDLK_UP);
    SDL::Events::push_event($event);
    $event->type(SDL_KEYDOWN);
    $event->key_sym(SDLK_LEFT);
    SDL::Events::push_event($event);
    $event->type(SDL_KEYUP);
    $event->key_sym(SDLK_LEFT);
    SDL::Events::push_event($event);
    $event->type(SDL_KEYUP);
    $event->key_sym(SDLK_UP);
    SDL::Events::push_event($event);
    $event->type(SDL_KEYDOWN);
    $event->key_sym(SDLK_SPACE);
    SDL::Events::push_event($event);
};

$game->run;
$th->join;
pass('game out of runloop');
undef $game;
done_testing;
