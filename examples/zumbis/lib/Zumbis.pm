package Zumbis;
use base 'Jogo';
use strict;
use warnings;

use constant state_map =>
  { start =>
    { controller => 'Intro',
      transitions =>
      { continue => 'menu',
        abort => 'end'
      },
    },
    menu =>
    { controller => 'Menu',
      transitions =>
      { start_male => sub {
            my $self = shift;
            $self->transition('ingame', gender => 'male');
        },
        start_female => sub {
            my $self = shift;
            $self->transition('ingame', gender => 'female');
        },
        quit => 'credits'
      },
    },
    ingame =>
    { controller => 'InGame',
      transitions =>
      { died => sub {
            my $self = shift;
            my $time = $self->active->time_survived;
            my $score =  $self->active->score;
            $self->transition('gameover',
                              time => $time,
                              score => $score);
        },
        quit => 'menu',
      },
    },
    gameover =>
    { controller => 'GameOver',
      transitions =>
      { finish => 'menu'
      },
    },
    credits =>
    { controller => 'Credits',
      transitions =>
      { finish => 'end'
      },
    },
  };


1;
