FROM postgis/postgis:15-3.3

RUN apt-get update && apt-get install -y wget build-essential cmake postgresql-server-dev-15 git lsb-release \
    #libgeos-c1v5 \
    libgeos++-dev \
#    libproj19 libproj-dev \ #wird aus Quellen kompiliert
    #gdal-bin \
    libgdal-dev \
    #libxml2 \
    libxml2-dev
#    libjson-c5 libjson-c-dev #wird aus Quellen kompiliert

#RUN ls -alh /usr/lib/x86_64-linux-gnu/cmake/json-c
#RUN ls -alh /usr/include/json-c

RUN echo "########## json-c ###########################################################################"
WORKDIR /download
#RUN git clone https://github.com/json-c/json-c.git
RUN wget https://github.com/json-c/json-c/archive/refs/tags/json-c-0.12.1-20160607.tar.gz
RUN tar -xf json-c-0.12.1-20160607.tar.gz
WORKDIR /download/json-c-json-c-0.12.1-20160607
RUN CFLAGS=-Wno-error ./configure
RUN make
RUN make install

#build proj4
RUN echo "########## proj4 ###########################################################################"
WORKDIR /download
RUN wget https://download.osgeo.org/proj/proj-4.9.3.tar.gz
RUN tar -xf proj-4.9.3.tar.gz
WORKDIR proj-4.9.3
RUN ./configure
RUN make
RUN make install

#build postgis
RUN echo "########## postgis ###########################################################################"
WORKDIR /download
#RUN wget https://download.osgeo.org/postgis/source/postgis-2.1.7.tar.gz 
#RUN tar -xf postgis-2.1.7.tar.gz

COPY ./source/postgis-2.1.7/ /download/postgis-2.1.7
WORKDIR /download/postgis-2.1.7

RUN ./configure 
#--with-jsondir=/usr/local
#--with-jsondir=/download/json-c
# --with-projdir=/download/proj-4.9.3
RUN make
RUN make install
