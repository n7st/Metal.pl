package Metal::Module::Role::SpamProtection::Qualification;

use Moose::Role;

requires qw(
    config
    channels
);

################################################################################

has default_highlight_limit     => (is => 'ro', isa => 'Int', default => 5);
has default_non_utf8_char_count => (is => 'ro', isa => 'Int', default => 12);
has default_min_filter_length   => (is => 'ro', isa => 'Int', default => 10);
has default_min_filter_length   => (is => 'ro', isa => 'Int', default => 20);
has default_min_word_count      => (is => 'ro', isa => 'Int', default => 5);

################################################################################

sub meets_min_msg_requirements {
    my $self = shift;
    my $msg  = shift;

    return $self->meets_min_msg_length($msg) || $self->meets_min_msg_word_count($msg);
}

sub meets_min_msg_length {
    my $self = shift;
    my $msg  = shift;

    my $min_length = $self->config->{min_filter_len} || $self->default_min_filter_length;

    return length($msg) >= $min_length;
}

sub meets_min_msg_word_count {
    my $self = shift;
    my $msg  = shift;

    # Count the number of spaces in the message
    my $word_count     = () = $msg =~ m/\s/g;
    my $min_word_count = $self->config->{min_word_count} || $self->default_min_word_count;

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

    my $highlight_limit = $self->config->{highlight_limit} || $self->default_highlight_limit;
    my %args = map { $_ => 1 } split / /, $msg;
    my %seen;

    foreach my $nick (@nicknames) {
        $seen{$nick} = 1 if $args{$nick}
    }

    return scalar keys %seen >= $highlight_limit;
}

sub meets_msg_max_non_utf8_count {
    my $self = shift;
    my $msg  = shift;

    my $limit = $self->config->{non_utf8_char_count} || $self->default_non_utf8_char_count;
    my $count = () = $msg =~ m/[^[:print:]]/g;

    return $count >= $limit;
}

################################################################################

no Moose;
1;
__END__

=head1 NAME

Metal::Module::Role::SpamProtection::Qualification - is it spam?

=head1 DESCRIPTION

Validates given messages against known spammy behaviour e.g. mass highlighting,
avoiding filters with strange characters.

=head2 METHODS

=over 4

=item C<meets_msg_min_requirements()>

Checks the incoming message against other methods in this class to see if it
should be spamchecked.

=item C<meets_msg_min_length()>

Checks the message is over a certain character count which is either set in the
config file or defaulted constant attribute C<default_min_filter_length>.

=item C<meets_msg_min_word_count()>

Checks the message has over a certain number of words in it. The minimum number
is set either in the config file or defaulted to attribute
C<default_min_word_count>.

=item C<meets_msg_max_highlight_count()>

Checks the number of nicknames highlighted in a given message against a list
for the channel (must be provided by consumer module!). Again, this references
a config value ('highlight_limit') and falls back to an attribute
(C<default_highlight_limit>).

=item C<meets_msg_max_non_utf8_count()>

Checks if a message contains more than the maximum number of allowed non-utf8
characters to catch spammers avoiding filters set network wide or per channel.

Please note if non_utf8_char_count is set too low, false-positives are possible
with Apple users (with special characters for ' and ").

=back

=head1 AUTHOR

Mike Jones L<email:mike@netsplit.org.uk>

