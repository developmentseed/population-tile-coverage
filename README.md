# Population tile coverage

These are scripts to get data from [OSM](http://download.geofabrik.de/) and [WORLDPOP](https://www.worldpop.org/project/categories?id=3) and cobined them, in order to get the Tile coverage for population

# Dependecies

```
apt-get -y install jq wget zip
```

## Build container

```sh
docker-compose build
```

## Execute the script 

```
python3 index.py \
    --country=monaco \
    --zoom=16 \
    --worldpop_url=https://data.worldpop.org/GIS/Population/Global_2000_2020/2020/MCO/mco_ppp_2020.tif \
    --osm_pbf_url=http://download.geofabrik.de/europe/monaco-latest.osm.pbf
```
Argument:
- country, necessary argument
- zoom, for creating the tile coverage
- worldpop_url, url of raster file, get from https://www.worldpop.org/geodata/listing?id=29
- osm_pbf_url, url of pbf file, get from http://download.geofabrik.de/

**Note:**
- In case you want only the worldpop population tile coverage, pass only `worldpop_url` argument.
- In case you want only the OpenStreetMap tile coverage, pass only `osm_pbf_url` argument.

The output will be a zipped shapefile "data/monaco_population_tiles_16.zip". The script could take time on processing, e.g for Sierra-Leone size country can take around 10 minutes a local machine(4 CPUs and 16 RAM).


![image](https://user-images.githubusercontent.com/1152236/93103839-bb760500-f672-11ea-8850-c4f6fb79ee93.png)
