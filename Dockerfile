FROM n7st/docker-perl-dbix-moose

RUN mkdir /opt/Metal

WORKDIR /opt/Metal
COPY . /opt/Metal

RUN dzil authordeps | xargs -n 5 -P 10 cpanm --verbose --notest --quiet
RUN dzil listdeps --author | xargs -n 5 -P 10 cpanm --verbose --no-interactive --notest --quiet

ENV DBIC_MIGRATION_SCHEMA_CLASS Metal::Schema

RUN dbic-migration -Ilib install_if_needed

