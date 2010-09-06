package Jogo::Controller;
use strict;
use warnings;

use Class::XSAccessor
  replace        => 1,
  constructor    => 'new',
  accessors      => { managers => 'managers',
                      state => 'state'
                    },
  predicates     => { initialized => 'managers',
                    };



1;
