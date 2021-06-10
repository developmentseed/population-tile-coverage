#!/bin/bash -x
# # # ############################################
# # # Monaco
# # # ############################################

python3 index.py \
    --country=monaco \
    --zoom=16 \
    --worldpop_url=https://data.worldpop.org/GIS/Population/Global_2000_2020/2020/MCO/mco_ppp_2020.tif \
    --osm_pbf_url=http://download.geofabrik.de/europe/monaco-latest.osm.pbf