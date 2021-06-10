# Population tile coverage

These are scripts to get data from [OSM](http://download.geofabrik.de/) and [WORLDPOP](https://www.worldpop.org/project/categories?id=3) and cobined them, in order to get the Tile coverage for population

## Build container

```sh

# Build container
cd project-connect / && docker-compose build
cd phase3/ml_util_data/population-tile-coverage/

# Process raster file, output a JSON file
./raster.sh \
    rwanda \
    ftp://ftp.worldpop.org.uk/GIS/Population/Global_2000_2020/2020/RWA/rwa_ppp_2020.tif

# Process PBF fil filtering object to get a JSON file
./osm.sh \
    rwanda \
    http://download.geofabrik.de/africa/rwanda-latest.osm.pbf

# Process raster and OSM data to get the coverage
./mbtiles.sh \
    rwanda

```

The output will be a shapefile zipped "rwanda_population_coverage_z16.shp.zip". Also the script could take time on processing, e.g for Sierra-Leone size country can take around 10 minutes a local machine(4 CPUs and 16 RAM).


![image](https://user-images.githubusercontent.com/1152236/93103839-bb760500-f672-11ea-8850-c4f6fb79ee93.png)
