FROM mariadb:10.11.4-jammy

ENV APIVER 111
ENV BIOPERLVER release-1-6-924

RUN  apt update  \
     && apt -y install git libdbd-mysql-perl libtry-tiny-perl libxml-simple-perl tabix \
     && cd /usr/local/src \
     && git clone https://github.com/Ensembl/ensembl-git-tools.git \
     && export PATH=/usr/local/src/ensembl-git-tools/bin:$PATH \
     && git ensembl --clone api \
     && git ensembl --checkout --branch release/$APIVER api \
     && git clone -b $BIOPERLVER --depth 1 https://github.com/bioperl/bioperl-live.git

ENV PERL5LIB=${PERL5LIB}:/usr/local/src/ensembl/modules
ENV PERL5LIB=${PERL5LIB}:/usr/local/src/ensembl-compara/modules
ENV PERL5LIB=${PERL5LIB}:/usr/local/src/ensembl-variation/modules
ENV PERL5LIB=${PERL5LIB}:/usr/local/src/ensembl-funcgen/modules
ENV PERL5LIB=${PERL5LIB}:/usr/local/src/ensembl-io/modules
ENV PERL5LIB=${PERL5LIB}:/usr/local/src/bioperl-live
ENV PERL5LIB=${PERL5LIB}:/usr/local/lib/ebi2gus

COPY ./lib/perl /usr/local/lib/ebi2gus
COPY ./bin/* /usr/local/bin/
COPY ./conf/ensembl_registry.conf.sample /usr/local/etc/ensembl_registry.conf
COPY ./conf/chromosomeMap.conf.sample /usr/local/etc/chromosomeMap.conf
COPY ./lib/xml/gusSchemaDefinitions.xml /usr/local/etc/gusSchemaDefinitions.xml
COPY ./conf/seq_region_maps /usr/local/etc/seq_region_maps

HEALTHCHECK CMD mysqladmin ping --silent
