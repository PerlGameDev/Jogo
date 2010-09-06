package Jogo::Controller;
use strict;
use warnings;
use Scalar::Util 'weaken';
use UNIVERSAL::require;

use Class::XSAccessor
  replace        => 1,
  accessors      => [qw(managers state threads listeners)];

sub new {
    my $self = shift;
    my $app = shift;
    my %args = @_;
    my $class = ref $self || $self;
    $self = bless { managers => {},
                    state => 'initializing',
                    listeners => []}, $class;

    foreach my $manager (keys %{$self->managers_map}) {
        my $class = $self->manager_name($app, $manager);
        $class->require;
        no strict 'refs'; # make the check a bit softer, we don't
                          # require a file to exist, but rather check
                          # if there is a constructor method there.
        die $@ unless $class->can('new');
        $self->managers->{$manager} = $class->new();
    }

    $self->managers->{SDL} = $self;
    weaken $self->managers->{SDL};

    foreach my $manager ((keys %{$self->managers_map}),'SDL') {
        # reverse lookup of all other managers that listen to this
        # manager
        $self->managers->{$manager}->add_listener($self->managers->{$_})
          for
            # finish schwartzian transform
            map { $_->[0] }
              # grep for matching
              grep { grep { $_ eq $manager } @{$_->[1]} }
                # normalize list of "listen_to"
                map { my $v = $self->managers_map->{$_};
                      [ $_ => ref $v ? $v : [$v] ] }
                  # search in the managers_map
                  keys %{$self->managers_map};
    }

    return $self;
}

sub manager_name {
    my ($self, $app, $name) = @_;
    $name =~ s/^\+//g ? $name : ref($app).'::Manager::'.$name;
}

sub activate {
    my ($self, $app) = @_;
    $_->activate($self, $app)
      for
        map { $self->{managers}{$_} }
          grep { $_ ne 'SDL' }
            keys %{$self->{managers}};
}

sub deactivate {
    my ($self, $app) = @_;
    $_->deactivate($self, $app)
      for
        map { $self->{managers}{$_} }
          grep { $_ ne 'SDL' }
            keys %{$self->{managers}};
}

sub add_listener {
    my ($self, @listeners) = @_;
    push @{$self->{listeners}}, @listeners;
}

sub handle_event {
    my ($self, $app, $event) = @_;
    foreach my $l (@{$self->{listeners}}) {
        $l->enqueue($self, $app, 'sdl' => $event);
    }
}

1;
