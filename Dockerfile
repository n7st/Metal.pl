FROM       perl:5.22
MAINTAINER Mike Jones <mike@netsplit.org.uk>

ENV DEBIAN_FRONTEND=noninteractive LANG=en_US.UTF-8 LC_ALL=C.UTF-8 LANGUAGE=en_US.UTF-8

ADD . /opt/Metal/

RUN [ "apt-get", "-q", "update" ]
RUN [ "apt-get", "-qy", "--force-yes", "upgrade" ]
RUN [ "apt-get", "install", "-y", "sqlite3" ]

RUN curl -L http://cpanmin.us | perl - App::cpanminus
RUN [ "cpanm", "install", "--force", "POE::Component::SSLify" ]
RUN [ "cpanm", "--quiet", "--notest", "--skip-satisfied", "Dist::Zilla" ]

WORKDIR /opt/Metal

RUN git config --global user.name "Metal User"
RUN git config --global user.email "metal@netsplit.uk"

RUN dzil authordeps --missing | cpanm
RUN dzil listdeps --author --missing | cpanm
RUN dzil smoke --release --author

RUN [ "chmod", "+x", "/opt/Metal/script/metal.pl" ]

ENTRYPOINT [ "/opt/Metal/script/metal.pl" ]

