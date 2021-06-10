FROM osgeo/gdal:ubuntu-small-latest
RUN apt-get update && \
    apt-get install -y git bc postgresql-client build-essential libsqlite3-dev zlib1g-dev python3-pip

# Install tippecano
RUN mkdir -p /tmp/tippecanoe-src
RUN git clone https://github.com/mapbox/tippecanoe.git /tmp/tippecanoe-src
WORKDIR /tmp/tippecanoe-src
RUN git checkout 18e53cd7fb9ae6be8b89d817d69d3ce06f30eb9d
RUN make && make install

# Install python modules
RUN pip install mapboxcli
RUN pip install rasterio
RUN pip install rio_cogeo
RUN pip install rio_tiler
RUN pip install fire
RUN pip install unrasterize
RUN pip install mercantile
WORKDIR /mnt
