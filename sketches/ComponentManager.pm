package MyGame::View::Screen;
use base 'Jogo::ComponentManager';
use strict;
use warnings;

### to get a new instance of a component
# $c->component($name, %override_args)

### to get an existing instance of a component, usually used for
### singleton components
# $c->instance($name, $refaddr?)

### to get an array ref of all existing instances of a given component
# $c->instances($name)

### to remove an instance from the manager, causing it to, eventually,
### get garbage-collected.
# $c->release($name, $refaddr?)

# this is based in the return of the "component_map" routine.

# Every component should be instantiated by the component manager, so
# the manager can propagate the event of its creation.

# the connect_map routine defines how components here relate to
# components in other managers.

sub component_map {
    return
      { Background =>
        { class => 'Jogo::View::Plane',
          args => { color => 0xFFFFFFFF },
          depends => ['Camera'],
        },
        Hero =>
        { class => 'Jogo::View::Sprite',
          args => { image => 'hero.png',
                    width => 32,
                    height => 49
                  },
          depends => ['Camera']
        },
        Zombie =>
        { class => 'Jogo::View::Sprite',
          args => { image => 'zombie.png',
                    width => 32,
                    height => 49 }
          depends => ['Camera'],
        },
        Bullet =>
        { class => 'Jogo::View::Sprite',
          args => { image => 'bullet.png',
                    width => 20,
                    height => 20 }
          depends => ['Camera'],
        },
        MapObject =>
        { class => 'Jogo::View::Sprite',
          args => { image => 'tilemap.png',
                    width => 32,
                    height => 32 },
          depends => ['Camera']
        }
        Camera =>
        { class => 'Jogo::View::Camera',
          args => { dpi => 96 },
        }
      };
}

sub connect_map {
    return
      { 'Jogo::Model::Hero' =>
        [ { component => 'Hero',
            listener => [qw(moved changedstate)]
          }
        ],
        'Jogo::Model::Zombie' =>
        [ { component => 'Zombie',
            listener => [qw(moved changedstate)]
          }
        ],
        'Jogo::Model::Bullet' =>
        [ { component => 'Bullet',
            listener => [qw(moved changedstate)]
          }
        ],
      };
}
