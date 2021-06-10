"""ChopChop."""
import sys
import math
import click
import rasterio
from rasterio.rio import options
from rasterio.windows import Window
import os


def dims(total, chop):
    """Given a total number of pixels, chop into equal chunks.
    Last one gets truncated so that sum of sizes == total.
    yeilds (offset, size) tuples
    >>> list(dims(512, 256))
    [(0, 256), (256, 256)]
    >>> list(dims(502, 256))
    [(0, 256), (256, 246)]
    >>> list(dims(522, 256))
    [(0, 256), (256, 256), (512, 10)]
    """
    for a in range(int(math.ceil(total / chop))):
        offset = a * chop
        diff = total - offset
        if diff <= chop:
            size = diff
        else:
            size = chop
        yield offset, size


def translate(src, dst, col_off, row_off, width, height, dst_opts=None):
    """Crop and translate dataset."""
    dst_opts = dst_opts or {}
    window = Window(col_off, row_off, width, height)
    with rasterio.open(src) as dsrc:
        meta = dsrc.meta.copy()
        meta.update(**dst_opts)
        meta["count"] = len(dsrc.indexes)
        meta["width"] = width
        meta["height"] = height
        meta["transform"] = dsrc.window_transform(window)
        with rasterio.open(dst, "w", **meta) as ddst:
            ddst.write(dsrc.read(window=window))
    return True


@click.command("Split raster files in chunks, according to the number of pixels")
@options.file_in_arg
@click.option("--prefix", type=str, required=True, help="output file prefix.")
@click.option(
    "--width", "-w", type=int, default=5000, help="Chop width (default: 5000px)"
)
@click.option(
    "--height", "-h", type=int, default=5000, help="Chop height (default: 5000px)"
)
@click.option(
    "--blocksize", type=int, default=256, help="Overwrite profile's tile size."
)
@options.creation_options
def main(input, prefix, width, height, blocksize, creation_options):
    """Chop an input dataset"""
    outputPath = os.path.dirname(input)
    profile = {
        "driver": "GTiff",
        "interleave": "pixel",
        "tiled": True,
        "blockxsize": blocksize,
        "blockysize": blocksize,
        "compress": "DEFLATE",
    }
    if creation_options:
        profile.update(creation_options)
    with rasterio.open(input) as src:
        w = src.meta["width"]
        h = src.meta["height"]
    winds = [
        (coff, wd, roff, ht)
        for roff, ht in dims(h, height)
        for coff, wd in dims(w, width)
    ]
    with click.progressbar(
        winds, length=len(winds), file=sys.stderr, show_percent=True
    ) as blocks:
        for coff, wd, roff, ht in blocks:
            outfile = f"{outputPath}/{prefix}_{coff}_{roff}.tif"
            # ChopChop and convert to tiff
            translate(input, outfile, coff, roff, wd, ht, dst_opts=profile)


if __name__ == "__main__":
    main()
