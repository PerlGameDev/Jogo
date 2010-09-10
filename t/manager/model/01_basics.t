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
       'Test'     => 'Model',
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
   use base 'Jogo::Manager::Model';
   use constant components_map =>
     { player =>
       { class => '+Jogo::Model::MovingPoint',
         args =>
         { x => 4,
           y => 4,
           x_vel => 0,
           y_vel => 0
         },
         life_cycle => 'singleton',
         listen =>
         { Controls =>
           { move_up => sub {
                 my ($self, $component, $ctrl, $app, $evt) = @_;
                 $component->y_vel($evt->{status});
             },
             move_down => sub {
                 my ($self, $component, $ctrl, $app, $evt) = @_;
                 $component->y_vel(0 - $evt->{status});
             },
             move_right => sub {
                 my ($self, $component, $ctrl, $app, $evt) = @_;
                 $component->x_vel($evt->{status});
             },
             move_left => sub {
                 my ($self, $component, $ctrl, $app, $evt) = @_;
                 $component->x_vel(0 - $evt->{status});
             },
           }
         },
       },
       bullet =>
       { class => '+Jogo::Model::MovingPoint',
         args => sub {
             my ($self, $ctrl, $app) = @_;
             my $player = $self->component('player');
             my %args =
               ( x => $player->x,
                 y => $player->y,
                 x_vel => $player->x_vel * 10,
                 y_vel => $player->y_vel * 10 );
             $args{x_vel} = 10 unless $args{x_vel} or $args{y_vel};
             return \%args;
         },
         life_cycle => 'instance',
         trigger => { Controls => 'fire' },
         filter_out => sub {
             my ($self, $component, $ctrl, $app) = @_;
             return
               $component->x > -10 && $component->x < 10 &&
                 $component->y > -10 && $component->y > 10;
         }
       }
     };
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
    $event->key_state(SDL_PRESSED);
    SDL::Events::push_event($event);
    SDL::delay(50);
    $event->type(SDL_KEYDOWN);
    $event->key_sym(SDLK_UP);
    $event->key_state(SDL_PRESSED);
    SDL::Events::push_event($event);
    SDL::delay(50);
    $event->type(SDL_KEYDOWN);
    $event->key_sym(SDLK_LEFT);
    $event->key_state(SDL_PRESSED);
    SDL::Events::push_event($event);
    SDL::delay(50);
    $event->type(SDL_KEYUP);
    $event->key_sym(SDLK_LEFT);
    $event->key_state(SDL_RELEASED);
    SDL::Events::push_event($event);
    SDL::delay(50);
    $event->type(SDL_KEYUP);
    $event->key_sym(SDLK_UP);
    $event->key_state(SDL_RELEASED);
    SDL::Events::push_event($event);
    SDL::delay(50);
    $event->type(SDL_KEYDOWN);
    $event->key_sym(SDLK_SPACE);
    $event->key_state(SDL_PRESSED);
    SDL::Events::push_event($event);
};

$game->run;
$th->join;
pass('game out of runloop');
undef $game;
done_testing;
