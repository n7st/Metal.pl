package Metal::Roles::Routes;

use Moose::Role;

use Metal::Handler::Concert;
use Metal::Handler::Event;
use Metal::Handler::LastFM;
use Metal::Handler::Pizza;
use Metal::Handler::Releases;
use Metal::Handler::Text;
use Metal::Handler::WolframAlpha;

################################################################################

has routes => (is => 'ro', isa => 'HashRef', lazy_build => 1);

use constant {
    BASIC    => 'Metal::Handler::Text',
    CONCERT  => 'Metal::Handler::Concert',
    EVENT    => 'Metal::Handler::Event',
    LASTFM   => 'Metal::Handler::LastFM',
    PIZZA    => 'Metal::Handler::Pizza',
    RELEASES => 'Metal::Handler::Releases',
    WA       => 'Metal::Handler::WolframAlpha',
};

################################################################################

sub _build_routes {
    my $self = shift;

    # Modules in this mapping hash must be used by this module
    return {
        # Metal::Handler::Text
        'dadjoke' => {
            class   => $self->BASIC,
            routine => 'dadjoke',
        },
        'damson' => {
            class   => $self->BASIC,
            routine => 'damson',
        },
        'eatpizza' => {
            class   => $self->BASIC,
            routine => 'eatpizza',
        },
        'flen' => {
            class   => $self->BASIC,
            routine => 'flenny',
        },
        'lemmy' => {
            class   => $self->BASIC,
            routine => 'lemmy',
        },
        'lenny' => {
            class   => $self->BASIC,
            routine => 'lenny',
        },

        # Metal::Handler::Concert
        'addband' => {
            class   => $self->CONCERT,
            routine => 'add_band',
        },
        'addfestival' => {
            class   => $self->CONCERT,
            routine => 'add_festival',
        },
        'bandinfo' => {
            class   => $self->CONCERT,
            routine => 'band_info',
        },
        'concerthelp' => {
            class   => $self->CONCERT,
            routine => 'help',
        },
        'concerthighscores' => {
            class   => $self->CONCERT,
            routine => 'highscores',
        },
        'usershows' => {
            class   => $self->CONCERT,
            routine => 'user_band_total',
        },

        # Metal::Handler::Event
        'addevent' => {
            class   => $self->EVENT,
            routine => 'create',
        },

        # Metal::Handler::LastFM
        'setuser' => {
            class   => $self->LASTFM,
            routine => 'add_user',
        },
        'l' => {
            class   => $self->LASTFM,
            routine => 'now_playing',
        },
        'np' => {
            class   => $self->LASTFM,
            routine => 'now_playing',
        },
        'artist' => {
            class   => $self->LASTFM,
            routine => 'artist_info',
        },
        'band' => {
            class   => $self->LASTFM,
            routine => 'artist_info',
        },
        'aplays' => {
            class   => $self->LASTFM,
            routine => 'album_scrobble_count',
        },
        'plays' => {
            class   => $self->LASTFM,
            routine => 'artist_scrobble_count',
        },
        'topa' => {
            class   => $self->LASTFM,
            routine => 'top_all',
        },
        'topw' => {
            class   => $self->LASTFM,
            routine => 'top_week',
        },
        'topm' => {
            class   => $self->LASTFM,
            routine => 'top_month',
        },
        'topy' => {
            class   => $self->LASTFM,
            routine => 'top_year',
        },
        'userinfo' => {
            class   => $self->LASTFM,
            routine => 'user_info',
        },

        # Metal::Handler::Pizza
        'pizza++' => {
            class   => $self->PIZZA,
            routine => 'add_new_pizza',
        },
        'pizza--' => {
            class   => $self->PIZZA,
            routine => 'remove_last_pizza',
        },
        'pizzagods' => {
            class   => $self->PIZZA,
            routine => 'highscores',
        },
        'pizzainfo' => {
            class   => $self->PIZZA,
            routine => 'info',
        },
        'pizzahelp' => {
            class   => $self->PIZZA,
            routine => 'help',
        },
        'legacypizza' => {
            class   => $self->PIZZA,
            routine => 'legacy_count',
        },
        'mypizzascore' => {
            class   => $self->PIZZA,
            routine => 'user_stats',
        },

        # Metal::Handler::Releases
        'releases' => {
            class   => $self->RELEASES,
            routine => 'today',
        },

        'wa' => {
            class   => $self->WA,
            routine => 'query',
        },
    };
}

################################################################################

no Moose;
1;
__END__

=head1 NAME

Metal::Roles::Routes

=head1 DESCRIPTION

Maps a command to a class and routine.

