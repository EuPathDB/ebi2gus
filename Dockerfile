FROM mariadb/server

ENV APIVER 95
ENV BIOPERLVER release-1-6-924

RUN  apt-get update \
     && apt -y install git \
     && cd /usr/local/src \
     && git clone https://github.com/Ensembl/ensembl-git-tools.git \
     && export PATH=/usr/local/src/ensembl-git-tools/bin:$PATH \
     && git ensembl --clone api \
     && git ensembl --checkout --branch release/$APIVER api \
     && git clone -b $BIOPERLVER --depth 1 https://github.com/bioperl/bioperl-live.git

COPY ./lib /usr/local/lib/ebi2gus



