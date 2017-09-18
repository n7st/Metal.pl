package Metal::Role::Cache;

use Cache::File;
use Moose::Role;

################################################################################

has cache => (is => 'ro', isa => 'Cache::File', lazy_build => 1);

################################################################################

sub clear_runlist {
    my $self = shift;

    my @runlist = qw/list_is_running/;

    $self->cache->set($_, 0) foreach @runlist;

    return 1;
}

################################################################################

sub _build_cache {
    my $self = shift;

    return Cache::File->new(
        cache_root => '/tmp/metal_cache',

        # expires_in => ...?
    );
}

################################################################################

no Moose;
1;
__END__

=head1 NAME

Metal::Role::Cache

=head1 DESCRIPTION

Quick access to Metal's cache file.

=head2 USAGE

    use Moose;
    use Storable qw/freeze thaw/;

    with 'Metal::Role::Cache';

    sub save_something {
        my $self = shift;

        return $self->cache->set('something', freeze(\%some_hash));
    }

    sub load_something {
        my $self = shift;

        return thaw($self->cache->get('something'));
    }

=head2 METHODS

=over 4

=item C<clear_runlist()>

Items in the list in this subroutine are set by the program when a long-running
event is occurring. If we restart the bot whilst one is running, the events
won't be allowed to run again unless they're cleared at bot start.

=item C<_build_cache()>

Create the cache.

=back

=head1 AUTHOR

Mike Jones L<email:mike@netsplit.org.uk>

