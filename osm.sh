# !/usr/bin/env bash

# """
# Script for filtering OSM data and save as JSON

# Source OSM: http://download.geofabrik.de/

# Author: @developmentseed

# Run:
#     ./osm.sh
# """

outputDir=${OUTPUT_DIR}/osm
mkdir -p ${outputDir}
osmURLFile=$1
country=$2

# ###########################################################################
# ##### Get OSM tiles coverage
# ###########################################################################

[[ ! -f "${outputDir}/${country}.osm.pbf" ]] &&
        wget ${osmURLFile} -O ${outputDir}/${country}.osm.pbf

${GEOKIT_CONTAINER} osmosis \
        \
        --read-pbf ${outputDir}/${country}.osm.pbf \
        --tf accept-ways highway=* building=* sport=* amenity=* leisure=* landuse=residential \
        --used-node \
        --tf accept-relations \
        \
        --read-pbf ${outputDir}/${country}.osm.pbf \
        --tf accept-nodes building=* sport=* amenity=* leisure=* landuse=residential place=* \
        --tf reject-relations \
        --tf reject-ways \
        \
        --merge \
        --write-xml ${outputDir}/${country}.osm

# ###########################################################################
# ##### Convert OSM to json format
# ###########################################################################

outputFile="${OUTPUT_DIR}/${country}_osm.json"
${GEOKIT_CONTAINER} minjur \
        ${outputDir}/${country}.osm >${outputFile}

echo "OSM data... ${outputFile}"
