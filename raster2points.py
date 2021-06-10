
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


@click.command(short_help="Script for processing raster file to get the population data as points por polygons")
@click.argument('raster_path', nargs=1)
@click.argument('geojson_file', nargs=1)
@click.option('--mask_width', help='he number of pixels around an already selected pixel in which a new pixel will not be chosen', default=2, type=int)
@click.option('--threshold', help='The value in the raster data below which points will not be chosen', default=0.2, type=float)
@click.option('--point_buffer', help='Save output as buffer according to the population number', default=False, type=bool)
def main(raster_path, geojson_file, mask_width, threshold, point_buffer):
    print(f'Getting population from {raster_path} -> {geojson_file}')
    try:
        raster_data = rasterio.open(raster_path)
        # mask_width: The number of pixels around an already selected pixel in which a new pixel will not be chosen.
        # In the following example, this number is 10, indicating a minimum spacing of 5 pixels * 100 m / pixels = 500m  between adjacent pixels in the same raster window.
        # threshold: The value in the raster data below which points will not be chosen.
        # In this case, the threshold of 0.2 indicates that points estimated to have fewer than 0.2 people per 100m x 100m pixel will not be selected.
        unrasterizer = unrasterize.WindowedUnrasterizer(mask_width=mask_width, threshold=threshold)
        unrasterizer.select_representative_pixels(raster_data, n_jobs=-1)
        gdf = unrasterizer.to_geopandas(value_attribute_name='population', crs=raster_data.crs)
        buffe_divided=10000
        if point_buffer:
            gdf['geometry'] = gdf.apply(lambda x: box(*x.geometry.buffer(x.population/buffe_divided).bounds), axis=1)
        gdf.to_file(geojson_file, driver="GeoJSON")

    except RuntimeError:
        print(f'RuntimeError ...{raster_path}')


if __name__ == "__main__":
    main()
