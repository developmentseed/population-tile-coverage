# !/usr/bin/env bash

# """
# Script for processing json of raster files data and json OSM data to get the tile coverage.

# Author: @developmentseed

# Run:
#     ./mbtiles.sh
# """

outputDir=data/tmp
mkdir -p $outputDir
geokit="docker run --rm -v ${PWD}:/mnt/data developmentseed/geokit:population"

country=$1

osm_data=$outputDir/../osm/${country}_osm_school.json
raster_data=$outputDir/../population/${country}_population.json

# # # # # ###########################################################################
# # # # # ##### Merge OSM and Population files
# # # # # ###########################################################################

cat $osm_data $raster_data >$outputDir/${country}_osm_population.json

# # # # # # # ###########################################################################
# # # # # # # ##### Create Mbtiles
# # # # # # # ###########################################################################
$geokit tippecanoe \
        -l osm -z16 -Z16 -fo $outputDir/${country}.mbtiles \
        $outputDir/${country}_osm_population.json

# # # # ###########################################################################
# # # # ##### Get tiles coverage
# # # # ###########################################################################
$geokit osmcov \
        $outputDir/${country}.mbtiles \
        --zoom=16 \
        --types=highway,building,sport,amenity,leisure,landuse,population >$outputDir/${country}_tile.json

# # # # ###########################################################################
# # # # ##### Row features to geojson
# # # # ###########################################################################
mkdir -p $outputDir/../results_z16/

cat $outputDir/${country}_tile.json | jq '{"type":"FeatureCollection","features":.}' \
        --slurp -c >$outputDir/${country}_population_coverage_z16.geojson

docker run --rm -v ${PWD}:/opt/src developmentseed/project_connect:v1 ogr2ogr \
        -nlt POLYGON -skipfailures \
        $outputDir/${country}_population_coverage_z16.shp \
        $outputDir/${country}_population_coverage_z16.geojson

zip -r $outputDir/../results_z16/${country}_population_coverage_z16.shp.zip \
        $outputDir/${country}_population_coverage_z16.shx \
        $outputDir/${country}_population_coverage_z16.prj \
        $outputDir/${country}_population_coverage_z16.shp \
        $outputDir/${country}_population_coverage_z16.dbf
