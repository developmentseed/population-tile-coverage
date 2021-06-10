"""
Script for processing raster file to get the population data as points por polygons

Author: @developmentseed

Run:
    python3 raster2points.py <input>.tif <output>.geojson

"""

import geopandas as gpd
import pandas as pd
import rasterio
import shapely
import unrasterize
from shapely.geometry import box
import os
import click
import mercantile


def tile_centroid(point, zoom):
    tile = mercantile.tile(point.x, point.y, zoom)
    t = f'{"-".join(str(n) for n in tile)}'
    # bounds = mercantile.bounds(*tile)
    # poly = box(*bounds)
    return t


def set_geometry(tile):
    tile = tile.split("-")
    x = int(tile[0])
    y = int(tile[1])
    z = int(tile[2])
    return box(*mercantile.bounds(x, y, z)).centroid


@click.command(
    short_help="Script for processing raster file to get the population data as points por polygons"
)
@click.argument("raster_path", nargs=1)
@click.option(
    "--geojson_file_points",
    help="Points geojson file",
    default="geojson_file_points.geojson",
    type=str,
)
@click.option(
    "--geojson_file_tiles",
    help="tiles geojson file",
    default="geojson_file_tiles.geojson",
    type=str,
)
@click.option(
    "--mask_width",
    help="The number of pixels around an already selected pixel in which a new pixel will not be chosen",
    default=2,
    type=int,
)
@click.option(
    "--threshold",
    help="The value in the raster data below which points will not be chosen",
    default=0.2,
    type=float,
)
@click.option("--zoom", help="Zoom to get the tiles", default=16, type=int)
def main(
    raster_path, geojson_file_points, geojson_file_tiles, mask_width, threshold, zoom
):
    print(f"Getting population from {raster_path} -> {geojson_file_points}")
    try:
        raster_data = rasterio.open(raster_path)
        # mask_width: The number of pixels around an already selected pixel in which a new pixel will not be chosen.
        # In the following example, this number is 10, indicating a minimum spacing of 5 pixels * 100 m / pixels = 500m  between adjacent pixels in the same raster window.
        # threshold: The value in the raster data below which points will not be chosen.
        # In this case, the threshold of 0.2 indicates that points estimated to have fewer than 0.2 people per 100m x 100m pixel will not be selected.
        unrasterizer = unrasterize.WindowedUnrasterizer(
            mask_width=mask_width, threshold=threshold
        )
        unrasterizer.select_representative_pixels(raster_data, n_jobs=-1)
        gdf = unrasterizer.to_geopandas(
            value_attribute_name="population", crs=raster_data.crs
        )

        gdf["tile"] = gdf.apply(lambda x: tile_centroid(x.geometry, zoom), axis=1)
        gdf_sum = gdf.groupby(["tile"]).sum()
        gdf_sum["population"] = gdf.groupby(["tile"]).sum()["population"]
        gdf_sum = gdf_sum.reset_index()
        gdf_sum["geometry"] = gdf_sum.apply(lambda x: set_geometry(x.tile), axis=1)
        gdf.to_file(geojson_file_points, driver="GeoJSON")
        gdf_sum.to_file(geojson_file_tiles, driver="GeoJSON")

    except RuntimeError:
        print(f"RuntimeError ...{raster_path}")


if __name__ == "__main__":
    main()
