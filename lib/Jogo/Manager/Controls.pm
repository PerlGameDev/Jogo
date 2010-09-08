package Jogo::Manager::Controls;
use strict;
use SDL::Events;
use warnings;
use Class::XSAccessor
  replace => 1,
  constructor => 'new',
  accessors => [qw(key_states listeners)]
  ;

sub add_listener {
    my ($self, @l) = @_;
    $self->listeners([]) unless $self->listeners;
    push @{$self->listeners}, @l;
}

sub fire_control_event {
    my $self = shift;
    $self->listeners([]) unless $self->listeners;
    $_->enqueue(@_) for @{$self->listeners};
}

sub enqueue {
    my ($self, $ctrl, $app, $event_type, $data) = @_;
    return unless $event_type eq 'sdl';

    my $type = $data->type;
    if ($type == SDL_KEYDOWN ||
        $type == SDL_KEYUP) {
        $self->key_states({}) unless $self->key_states;
        my $sym  = $data->key_sym;

        foreach my $control (grep { $self->controls_map->{$_}{sym} == $sym }
                             keys %{$self->controls_map}) {
            my $state = $self->key_states->{$control} = $type == SDL_KEYDOWN ? 1 : 0;
            next unless $state or $self->controls_map->{$control}{type} eq 'key_state';
            $self->fire_control_event($ctrl, $app, 'Controls', { control => $control,
                                                                 status  => $state });
        }
    }
}

sub activate {}
sub deactivate {}

1;
