# !/usr/bin/env bash

# """
# Script for getting population files from TIF files as points or polygons
# Source: WORLDPOP : https://www.worldpop.org/geodata/listing?id=29

# Author: @developmentseed

# Run:
#     ./worldpop.sh
# """

outputDir=${OUTPUT_DIR}/worldpop
mkdir -p ${outputDir}
worldpopURLFile=$1
country=$2
zoom=$3

# # # # ###########################################################################
# # # # ##### Download worldpop data
# # # # ###########################################################################
[ ! -f ${outputDir}/${country}.tif ] && while true; do
        wget -T 15 -c ${worldpopURLFile} -O ${outputDir}/${country}.tif && break
        sleep 3
done

# # # # ###########################################################################
# # # # ##### Chop tif files in case those a huge files
# # # # ###########################################################################

${PTC_CONTAINER} python chopchop.py \
        ${outputDir}/${country}.tif \
        --prefix ${country} \
        --width 2000 \
        --height 2000

# # # # ###########################################################################
# # # # ##### Get population data, this step will execute all process at once
# # # # ###########################################################################

for tifFile in $outputDir/${country}_*.tif; do
        baseName=$(basename ${tifFile%.*})
        $PTC_CONTAINER python raster2points.py \
                ${tifFile} \
                --geojson_file_points=$outputDir/${baseName}_points.geojson \
                --geojson_file_tiles=$outputDir/${baseName}_tiles.geojson \
                --zoom=${zoom} \
                --mask_width=2 \
                --threshold=0.2 &
done
wait
echo "All process  raster -> geojson have completed"

# # # # ###########################################################################
# # # # ##### Merge population points in one
# # # # ###########################################################################

outputFile=${OUTPUT_DIR}/${country}_worldpop_points.geojson
echo '' >${outputFile}
for geojsonFile in ${outputDir}/${country}*_points.geojson; do
        echo "Merging ${geojsonFile} to ${outputFile}"
        cat ${geojsonFile} | jq '.features[] | .' -c >>${outputFile}
done

# # # # ###########################################################################
# # # # ##### Merge population polygon tiles in one
# # # # ###########################################################################

outputFile=${OUTPUT_DIR}/${country}_worldpop.json
echo '' >${outputFile}
for geojsonFile in ${outputDir}/${country}*_tiles.geojson; do
        echo "Merging ${geojsonFile} to ${outputFile}"
        cat ${geojsonFile} | jq '.features[] | .' -c >>${outputFile}
done

