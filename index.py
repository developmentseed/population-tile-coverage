#!/usr/bin/env python

import argparse
import subprocess
import os
from sys import platform

parser = argparse.ArgumentParser()
parser.add_argument(
    "--country",
    help="Select country",
)

parser.add_argument(
    "--worldpop_url",
    help="Process worldpop raster file",
)

parser.add_argument(
    "--osm_pbf_url",
    help="OSM pbf url file",
)

args = parser.parse_args()
pwd = os.getcwd()
os.environ["PTC_CONTAINER"] = f"docker run --network=host -v {pwd}:/mnt devseed/ptc"
os.environ["GEOKIT_CONTAINER"] = f"docker run --rm -v {pwd}:/mnt/data developmentseed/geokit:latest"
os.environ["OGR_GEOJSON_MAX_OBJ_SIZE"] = "1000"
os.environ["OUTPUT_DIR"] = "./data"

subprocess.check_call(["mkdir", "-p", "./data/"])

def worldpop(worldpop_url, country):
    subprocess.check_call([f"./worldpop.sh {worldpop_url} {country}"], shell=True)

def osm(osm_pbf_url, country):
    subprocess.check_call([f"./osm.sh {osm_pbf_url} {country}"], shell=True)

# def tiles(osm_url, country):
#     subprocess.check_call([f"./osm.sh {osm_url} {country}"], shell=True)

if args.worldpop_url and args.country:
    worldpop(args.worldpop_url, args.country)

if args.osm_pbf_url and args.country:
    osm(args.osm_pbf_url, args.country)


# if args.tiles and args.country:
#     osm(args.osm_url, args.country)
