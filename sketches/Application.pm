package MyGame;
use base 'Jogo';
use strict;
use warnings;

# "start" and "end" states are special.  The framework transitions to
# "start" at the beggining, and it will quit the game when the state
# is "end".

# if the value of the transition is a string, it is assumed to
# represent a state change. if it's a code, then the code is executed
# and nothing else is done. That code can change the current state and
# the active controller.

# $self->controller($name) instantiates a controller
# $self->active() is the accessor for the currently active controller.
# $self->state() is the accessor for the current state name.

sub state_map {
    return
      { start =>
        { controller => 'Menu',
          transitions =>
          { start => 'ingame',
            quit => 'end',
          }
        },
        ingame =>
        { controller => 'InGame',
          transitions =>
          { pause => sub {
                my $self = shift;
                my $paused = $self->controller('Pause', resume => $self->active);
                $self->state('paused');
                $self->active($paused);
            },
            youwin => 'finish',
            youlose => 'finish',
          },
        },
        paused =>
        { controller => 'Pause',
          transitions =>
          { abandon => 'start'
            resume => sub {
                my $self = shift;
                my $resume = $self->active->resume;
                $self->active($resume);
                $self->state('ingame');
            },
            quit => 'end'
          },
        },
        finish =>
        { controller => 'EndScreen',
          transitions =>
          { continue => 'start',
            quit => 'end'
          }
        }
      };
}

1;
