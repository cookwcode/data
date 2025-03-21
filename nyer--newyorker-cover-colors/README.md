# New Yorker Cover Colors

Dataset of colors of the New Yorker for one hundred years

## Dataset

Data is available as `nyer_colors.csv`. Every row is a pixel count of a hex color from a given issue.

- date: date of the issue
- count: number of pixels with given color
- color: hex color (FF for alpha channel)

## Method

Color is defined using image magick, getting the top n colors in an image. Note that this method can alter colors, but does a good job at an approximation (can run into some trouble for images with very few colors) ([src](https://usage.imagemagick.org/quantize/#quantize_not_exact)).

Python script `fetchCovers.py` loops through date range to grab covers. Can run to get selected covers.

Shell script `colorize.sh` outputs colors for given image. Can use `colorizeAll.sh` to loop through covers and construct raw text file.

Text file was prepped, modifying file paths as dates and defining column names.
