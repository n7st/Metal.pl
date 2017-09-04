package Metal::Module::Role::SpamProtection::Qualification;

use Moose::Role;

requires qw(
    config
    channels
);

################################################################################

has default_min_filter_length => (is => 'ro', isa => 'Int', default => 10);
has default_min_filter_length => (is => 'ro', isa => 'Int', default => 20);
has default_min_word_count    => (is => 'ro', isa => 'Int', default => 5);
has default_highlight_limit   => (is => 'ro', isa => 'Int', default => 5);

################################################################################

sub meets_min_msg_requirements {
    my $self = shift;
    my $msg  = shift;

    return $self->meets_min_msg_length($msg) || $self->meets_min_msg_word_count($msg);
}

sub meets_min_msg_length {
    my $self = shift;
    my $msg  = shift;

    my $min_length = $self->config->{min_filter_len} // $self->default_min_filter_length;

    return length($msg) >= $min_length;
}

sub meets_min_msg_word_count {
    my $self = shift;
    my $msg  = shift;

    # Count the number of spaces in the message
    my $word_count     = () = $msg =~ m/\s/g;
    my $min_word_count = $self->config->{min_word_count} // $self->default_min_word_count;

    return $word_count >= $min_word_count;
}

sub meets_msg_max_highlight_count {
    my $self    = shift;
    my $msg     = shift;
    my $channel = shift;

    my @nicknames = grep {
        $self->channels->{$channel}->{$_} == 1
    } keys %{$self->channels->{$channel}};

    return 0 unless @nicknames;

    my $highlight_limit = $self->config->{highlight_limit} // $self->default_highlight_limit;
    my %args = map { $_ => 1 } split / /, $msg;
    my %seen;

    foreach my $nick (@nicknames) {
        $seen{$nick} = 1 if $args{$nick}
    }

    return scalar keys %seen >= $highlight_limit;
}

################################################################################

no Moose;
1;

