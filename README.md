# Metal [![Build Status](https://travis-ci.org/n7st/Metal.svg?branch=master)](https://travis-ci.org/n7st/Metal)

An IRC bot frame built with Moose and Reflex (with POE).

## Installation

Manual installation requires [`cpanminus`](https://metacpan.org/pod/App::cpanminus)
and [`Dist::Zilla`](https://metacpan.org/pod/Dist::Zilla).

1. Clone the repository.
2. Copy `data/config.yml.example` to `data/config.yml`.
3. Edit `data/config.yml` with your connection information.
4. Install the prerequisites:
    * `dzil authordeps | cpanm`
    * `dzil listdeps | cpanm`
5. Run the bot: `./script/metal.pl`
6. Install the database (should create an SQLite database in `share`):
    * `dbic-migration -Ilib --schema_class=Metal::Schema install_if_needed`

### Using Docker

1. `docker-compose build`
2. Copy `data/config.yml.example` to `data/config.yml` and edit it
3. `docker-compose up`

