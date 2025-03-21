#!/bin/bash

for file in covers/*; do
    echo $file
    ./colorize.sh "$file" >> ../nyer_colors.txt
done
