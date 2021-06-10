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
        --width 5000 \
        --height 5000

# # # # ###########################################################################
# # # # ##### Get population data, this step will execute all process at once
# # # # ###########################################################################

for tifFile in $outputDir/${country}*.tif; do
        $PTC_CONTAINER python raster2points.py \
                $tifFile \
                $tifFile.geojson \
                --mask_width=2 \
                --threshold=0.2 &
done
wait
echo "All process  raster -> geojson have completed"

# # # # ###########################################################################
# # # # ##### Merge population data in one JSON
# # # # ###########################################################################

outputFile=${OUTPUT_DIR}/${country}_worldpop.json
echo '' >${outputFile}
for geojsonFile in ${outputDir}/${country}*.tif.geojson; do
        echo "Merging ${geojsonFile} to ${outputFile}"
        cat ${geojsonFile} | jq '.features[] | .' -c >>${outputFile}
done

echo "Population file...${outputFile}"
