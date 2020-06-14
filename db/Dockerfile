FROM postgres:12

# Install Groonga
RUN apt update
RUN apt install -y -V wget
RUN wget https://packages.groonga.org/debian/groonga-archive-keyring-latest-stretch.deb
RUN apt install -y -V ./groonga-archive-keyring-latest-stretch.deb


# Install PGroonga
RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ stretch-pgdg main" | tee /etc/apt/sources.list.d/pgdg.list
RUN wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -
RUN apt update
RUN apt install -y -V postgresql-12-pgroonga

# Install MeCab Tokenizer
RUN apt install -y -V groonga-tokenizer-mecab

CMD [ "postgres" ]
