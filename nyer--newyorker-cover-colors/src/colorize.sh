#!/bin/bash

# Check if an image path is provided, otherwise print usage and exit
if [ -z "$1" ]; then
  echo "Usage: $0 <image-path>"
  exit 1
fi

# Get the image path from the first argument
IMAGE_PATH="$1"

# Check if a color count is provided, otherwise default to 10
COLOR_COUNT=${2:-10}

# Run the ImageMagick command and process the output
magick "$IMAGE_PATH" -colors $COLOR_COUNT -format "%c" -depth 8 histogram:info:- | \
awk -v image="$IMAGE_PATH" '{gsub(/:$/, "", $1); print image "," $1 "," $3 }' | head -n $COLOR_COUNT