package Jogo;
use strict;
use warnings;
use SDLx::App;
use SDL::Event;
use UNIVERSAL::require;

use constant EVENT_MAJOR_STATE_CHANGE => SDL_NUMEVENTS - 1;
use constant default_width => 800;
use constant default_height => 600;

use Class::XSAccessor
  replace        => 1,
  constructor    => 'new',
  accessors      => { main_surface => 'main_surface',
                      config => 'config',
                      state => 'state',
                      active => 'active',
                    },
  predicates     => { initialized => 'main_surface',
                    };


sub setup {
    my $self = shift;
    $self->setup_controllers;
    $self->setup_settings;
    $self->setup_main_surface;
}

sub setup_controllers {
    my $self = shift;
    foreach my $state (keys %{$self->state_map}) {
        my $name = $self->state_map->{$state}{controller};
        my $class = $self->controller_name($name);
        my $package_glob = $class.'::';
        $class->require;
        no strict 'refs'; # make the check a bit softer, we don't
                          # require a file to exist, but rather check
                          # if there is a constructor method there.
        die $@ unless exists ${$package_glob}{new};
    }
}

sub setup_settings {
}

sub setup_main_surface {
    my $self = shift;
    $self->main_surface(SDLx::App->new(width => $self->default_width,
                                       height => $self->default_height));
}

sub run {
    my $self = shift;
    unless ($self->active) {
        $self->transition('start');
    }

    my $event = SDL::Event->new;
    while ((my $state = $self->state) ne 'end' && SDL::Events::wait_event($event)) {
        my $type = $event->type();
        if ($type == EVENT_MAJOR_STATE_CHANGE) {
            my $transition = $event->user_data1;
            if (exists $self->state_map->{$state}{transitions}{$transition}) {
                my $destination = $self->state_map->{$state}{transitions}{$transition};
                if (ref $destination eq 'CODE') {
                    $destination->($self);
                } else {
                    $self->transition($destination);
                }
            } else {
                warn 'ignoring out-of-order game state transition request: '.$transition;
            }
        } else {
            $self->active->handle_event($self, $event);
        }
    }
}

sub controller_name {
    my ($self, $name) = @_;
    $name =~ /^\+/ ? $name : ref($self).'::Controller::'.$name;
}

sub request_transition {
    my ($self, $state) = @_;
    my $e = SDL::Event->new;
    $e->type(Jogo::EVENT_MAJOR_STATE_CHANGE);
    $e->user_data1($state);
    SDL::Events::push_event($e);
}

sub transition {
    my ($self, $state, %options) = @_;
    $self->state($state);
    $self->active->deactivate if $self->active;
    if ($state eq 'end') {
        $self->active(undef);
    } else {
        my $name = $self->controller_name($self->state_map->{$state}{controller});
        $self->active($name->new(%options));
        $self->active->activate;
    }
}

1;

__END__

=head1 NAME

Jogo - Perl Game Framework

=head1 DESCRIPTION

This is the main class for a game application, it holds reference to
all the game controllers and manages the major game states.

=head1 TODO

Docs still to be done.

=cut
