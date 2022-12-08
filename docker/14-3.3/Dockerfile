FROM postgis/postgis:14-3.3

#locale
RUN localedef -i de_DE -c -f UTF-8 -A /usr/share/locale/locale.alias de_DE.UTF-8
ENV LANG de_DE.utf8
RUN locale -a

#apt
RUN apt-get update && apt-get install -y \
    postgresql-14-mysql-fdw \
    postgresql-14-pgrouting \
    postgresql-server-dev-14 \
    alien \
    apt-utils \
    build-essential \
    libaio1 \
    libaio-dev \
    locales \
    locales-all \
    ntp \
    htop \
#    glances \
    wget \
    nano \
    tzdata \
    tree

#Postgres Extensions
ADD sources /usr/local

WORKDIR /usr/local

RUN alien -i oracle-instantclient11.2-basic-11.2.0.1.0-1.x86_64.rpm && \
    alien -i oracle-instantclient11.2-devel-11.2.0.1.0-1.x86_64.rpm && \
    alien -i oracle-instantclient11.2-sqlplus-11.2.0.1.0-1.x86_64.rpm

RUN cp /usr/lib/oracle/11.2/client64/lib/libclntsh.so.11.1 /usr/lib && \
    cp /usr/lib/oracle/11.2/client64/lib/libnnz11.so /usr/lib

ENV ORACLE_HOME "/usr/lib/oracle/11.2/client64"
ENV LD_LIBRARY_PATH "/usr/lib/oracle/11.2/client64/lib:/usr/lib/oracle/11.2/client64"

RUN wget https://github.com/laurenz/oracle_fdw/archive/refs/tags/ORACLE_FDW_2_4_0.tar.gz && \
    tar xvfz ORACLE_FDW_2_4_0.tar.gz

WORKDIR /usr/local/oracle_fdw-ORACLE_FDW_2_4_0

RUN make && \
    make install

#Timezone
RUN rm /etc/localtime
RUN ln -s /usr/share/zoneinfo/Europe/Berlin /etc/localtime

#alias
RUN sed -i \
        -e "s|# alias ls=|alias ls=|g" \
        -e "s|# alias ll=|alias ll=|g" \
        -e "s|# alias rm=|alias rm=|g" \
        ~/.bashrc

#rm package lists
RUN rm -rf /var/lib/apt/lists/*

WORKDIR /
