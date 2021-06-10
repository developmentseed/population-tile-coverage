# !/usr/bin/env bash

# """
# Script for processing json of raster files data and json OSM data to get the tile coverage.

# Author: @developmentseed

# Run:
#     ./mbtiles.sh
# """
country=$1
zoom=$2
outputDir=${OUTPUT_DIR}/tiles
mkdir -p $outputDir
# ###########################################################################
# # # # # ##### Merge OSM and Population files
# # # # # ###########################################################################

cat $3 $4 >${outputDir}/tile_coverage.json

# # # # # # # # ###########################################################################
# # # # # # # # ##### Create Mbtiles
# # # # # # # # ###########################################################################
$PTC_CONTAINER tippecanoe \
        -l osm \
        -z${zoom} \
        -Z${zoom} \
        -fo $outputDir/${country}.mbtiles \
        ${outputDir}/tile_coverage.json

# # # # # ###########################################################################
# # # # # ##### Get tiles coverage
# # # # # ###########################################################################
$GEOKIT_CONTAINER osmcov \
        $outputDir/${country}.mbtiles \
        --zoom=${zoom} \
        --types=highway,building,sport,amenity,leisure,landuse,population >$outputDir/${country}_tiles.json

# # # # # ###########################################################################
# # # # # ##### Row features to geojson
# # # # # ###########################################################################

cat $outputDir/${country}_tiles.json | jq '{"type":"FeatureCollection","features":.}' \
        --slurp -c >${OUTPUT_DIR}/${country}_population_tiles_${zoom}.geojson

$PTC_CONTAINER ogr2ogr \
        -nlt POLYGON -skipfailures \
        ${OUTPUT_DIR}/${country}_population_tiles_${zoom}.shp \
        ${OUTPUT_DIR}/${country}_population_tiles_${zoom}.geojson

zip -r ${OUTPUT_DIR}/${country}_population_tiles_${zoom}.zip \
        ${OUTPUT_DIR}/${country}_population_tiles_${zoom}.shx \
        ${OUTPUT_DIR}/${country}_population_tiles_${zoom}.prj \
        ${OUTPUT_DIR}/${country}_population_tiles_${zoom}.shp \
        ${OUTPUT_DIR}/${country}_population_tiles_${zoom}.dbf
