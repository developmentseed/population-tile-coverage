#!/bin/bash -x

python3 index.py \
    --country=burkina_fasso \
    --zoom=15 \
    --worldpop_url=https://data.worldpop.org/GIS/Population/Global_2000_2020/2020/BFA/bfa_ppp_2020.tif \
    --osm_pbf_url=http://download.geofabrik.de/africa/burkina-faso-latest.osm.pbf

python3 index.py \
    --country=mauritania \
    --zoom=15 \
    --worldpop_url=https://data.worldpop.org/GIS/Population/Global_2000_2020/2020/MRT/mrt_ppp_2020.tif \
    --osm_pbf_url=http://download.geofabrik.de/africa/mauritania-latest.osm.pbf

python3 index.py \
    --country=niger \
    --zoom=15 \
    --worldpop_url=https://data.worldpop.org/GIS/Population/Global_2000_2020/2020/NER/ner_ppp_2020.tif \
    --osm_pbf_url=http://download.geofabrik.de/africa/niger-latest.osm.pbf

python3 index.py \
    --country=sudan \
    --zoom=15 \
    --worldpop_url=https://data.worldpop.org/GIS/Population/Global_2000_2020/2020/SDN/sdn_ppp_2020.tif \
    --osm_pbf_url=http://download.geofabrik.de/africa/sudan-latest.osm.pbf

python3 index.py \
    --country=niger \
    --zoom=15 \
    --worldpop_url=https://data.worldpop.org/GIS/Population/Global_2000_2020/2020/TCD/tcd_ppp_2020.tif \
    --osm_pbf_url=http://download.geofabrik.de/africa/chad-latest.osm.pbf
