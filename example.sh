#!/bin/bash -x
# # # ############################################
# # # Monaco
# # # ############################################

python3 index.py \
    --country=monaco \
    --worldpop_url=https://data.worldpop.org/GIS/Population/Global_2000_2020/2020/MCO/mco_ppp_2020.tif

python3 index.py \
    --country=monaco \
    --osm_pbf_url=http://download.geofabrik.de/europe/monaco-latest.osm.pbf

