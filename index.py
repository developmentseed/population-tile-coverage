#!/usr/bin/env python

import argparse
import subprocess
import os
from os import path
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

parser.add_argument(
    "--zoom",
    help="Zoom to create the tiles",
)

args = parser.parse_args()
pwd = os.getcwd()
os.environ["PTC_CONTAINER"] = f"docker run --network=host -v {pwd}:/mnt devseed/ptc"
os.environ["GEOKIT_CONTAINER"] = f"docker run --rm -v {pwd}:/mnt/data developmentseed/geokit:population"
os.environ["OGR_GEOJSON_MAX_OBJ_SIZE"] = "1000"
output_dir = "./data"
os.environ["OUTPUT_DIR"] = output_dir

subprocess.check_call(["mkdir", "-p", "./data/"])


def worldpop(worldpop_url, country):
    subprocess.check_call(
        [f"./worldpop.sh {worldpop_url} {country}"], shell=True)


def osm(osm_pbf_url, country):
    subprocess.check_call([f"./osm.sh {osm_pbf_url} {country}"], shell=True)


def tiles(country, zoom):
    cmd = ["./tiles.sh", country, zoom]
    worldpop_file = f"{output_dir}/{country}_worldpop.json"
    osm_file = f"{output_dir}/{country}_osm.json"
    if path.exists(worldpop_file):
        cmd.append(worldpop_file)
    if path.exists(osm_file):
        cmd.append(osm_file)

    subprocess.check_call(" ".join(cmd), shell=True)


if args.worldpop_url and args.country:
    worldpop(args.worldpop_url, args.country)

if args.osm_pbf_url and args.country:
    osm(args.osm_pbf_url, args.country)

if args.country and args.zoom:
    tiles(args.country, args.zoom)
