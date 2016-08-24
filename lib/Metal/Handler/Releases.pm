package Metal::Handler::Releases;

use Moose;
use LWP::Simple;
use JSON;
use Data::Printer;
use Modern::Perl;
use DateTime;

################################################################################

has json         => (is => 'ro', isa => 'JSON', lazy_build => 1);
has ua           => (is => 'ro', isa => 'LWP::UserAgent', lazy_build => 1);
has all_releases => (is => 'rw', isa => 'ArrayRef', lazy_build => 1);
has releases     => (is => 'rw', isa => 'ArrayRef');
has total        => (is => 'rw', isa => 'Int', default => 1);
has cache_file   => (is => 'ro', isa => 'Str', lazy_build => 1);

################################################################################

sub today {
    my $self  = shift;
    my $today = $self->_get_today();
    my @output;

    return 'None' unless scalar @{$today};

    foreach (@{$today}) {
        push @output, $_->{artist}.' - '.$_->{title}.' ('.$_->{type}.')';

        last if scalar @output == 6;
    }

    my $out = DateTime->now->ymd().': '.join (', ', @output);

    if (scalar @{$today} > 7) {
        my $missing = scalar @{$today} - 7;

        $out .= ' (+'.$missing.' more - see http://netsplit.uk/today.html)';
    }

    return $out;
}

################################################################################

sub _get_today {
    my $self = shift;
    my $inp  = shift // $self->all_releases;
    my @today;

    foreach (@{$inp}) {
        next if $_->{type} eq 'Split' || $_->{type} eq 'Single';

        push @today, $_ if $_->{iso_date} eq DateTime->now->ymd();
    }

    return \@today;
}

sub _read_cache_file {
    my $self = shift;

    return [] unless -e $self->cache_file;

    my $data = do {
        open (my $fh, '<:encoding(UTF-8)', $self->cache_file) || die $!;
        local $/;
        <$fh>;
    };

    my $output = $self->json->decode($data);

    return $output;
}

sub _write_cache_file {
    my $self  = shift;
    my $input = shift;

    open (my $fh, '>:encoding(UTF-8)', $self->cache_file) || die $!;
    print $fh $input;
    close $fh;

    return;
}

sub _write_web_page {
    my $self         = shift;
    my $today        = shift;
    my $web_location = '/home/mike/web/netsplit.uk/today.html';
    my @lines;

    my $output = '<!DOCTYPE html><html><head><meta charset="utf-8">'
        .'<title>'.DateTime->now->ymd().'</title>'
        .'</head><body><ul>';

    foreach (@{$today}) {
        my @row = (
            '<li>', $_->{artist}, ' - ', $_->{title}, ' (', $_->{type}, ')</li>'
        );

        push(@lines, join('', @row));
    }

    $output .= join('', @lines);
    $output .= '</ul></body></html>';

    open (my $fh, '>:encoding(UTF-8)', $web_location) || die $!;
    print $fh $output;
    close $fh;

    return;
}

sub _retrieve_release_data {
    my $self      = shift;
    my $start     = shift || 0;
    my $timestamp = time();
    my $year      = DateTime->now->year();
    my $month     = DateTime->now->month();

    my @url = (
        'http://www.metal-archives.com/search/ajax-advanced/searching/albums',
        '?releaseYearFrom=2016&releaseMonthFrom='.$month,
        '&releaseYearTo='.$year.'&releaseMonthTo='.$month,
        '&sEcho=1&_='.$timestamp,
        '&iColumns=4&mDataProp_0=0&mDataProp_1=1',
        '&mDataProp_2=2&mDataProp_3=3',
        '&iDisplayStart='.$start,
        '&iDisplayLength=200',
    );

    return $self->ua->get(join('', @url));
}

sub _clean_releases {
    my $self  = shift;
    my $input = shift;
    my @output;

    foreach (@{$input}) {
        my ($iso_date) = $_->[3] =~ /<!-- (\d{4}-\d{2}-\d{2}) -->/;
        my $type;

        if ($_->[2] eq 'Full-length') {
            $type = 'LP';
        } elsif ($_->[2] eq 'Live album') {
            $type = 'Live';
        } else {
            $type = $_->[2];
        }

        push @output, {
            'artist'   => $self->_value_from_html($_->[0]),
            'title'    => $self->_value_from_html($_->[1]),
            'date'     => $_->[3] // 'None',
            'iso_date' => $iso_date,
            'type'     => $type,
        };
    }

    return \@output;
}

sub _value_from_html {
    my $self  = shift;
    my $input = shift;

    return $input =~ />(.+)<\//;
}

sub _build_json { JSON->new(); }

sub _build_ua {
    my $ua = LWP::UserAgent->new();
    
    $ua->agent('Mozilla/5.0 (X11; Ubuntu; Linux x86 64 rv:43.0) Gecko/20100101 Firefox/43.0');
    $ua->timeout(10);
    $ua->env_proxy;

    return $ua;
}

sub _build_all_releases {
    my $self = shift;

    my $cache = $self->_read_cache_file();

    return $cache if scalar @{$cache};

    my $output = $self->_get_all_releases();

    #$self->_write_web_page($self->_get_today($output));
    $self->_write_cache_file($self->json->encode($output));

    return $output;
}

sub _get_all_releases {
    my $self = shift;
    my @output;

    until (scalar @output >= $self->total) {
        my $r = $self->_retrieve_release_data(scalar @output);
        my $c = $self->json->decode($r->{_content});

        $self->total($c->{iTotalRecords});

        my $cleaned = $self->_clean_releases($c->{aaData});

        push @output, @{$cleaned};
    }

    return \@output;
}

sub _build_cache_file { 'data/cache/'.DateTime->now->ymd().'.json'; }

################################################################################

no Moose;
1;
__END__

=head1 NAME

Metal::Handler::Releases

=head1 DESCRIPTION

Daily release digests using data from the Encyclopedia Metallum.

=head1 AUTHOR

Mike Jones <mike@netsplit.org.uk>

