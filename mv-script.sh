#!/bin/bash

# Author : Halim
# Title: My First Script
# Use script by invoking ./mv-script.sh [YEAR]
# Script starts here:
YEAR="$1"
MONTHS=""01" "02" "03" "04" "05" "06" "07" "08" "09" "10" "11" "12""
PREFIXES=" "IMG_$YEAR" "IMG-$YEAR" "PHOTO_$YEAR" "Screenshot_$YEAR-" "Screenshot_$YEAR" "SmartSelect_$YEAR" "SmartSelectImage_$YEAR-" "Ultimate_HDR_Camera_Original_$YEAR" "Ultimate_HDR_Camera_$YEAR" "VID_$YEAR" "VID-$YEAR" "
for MONTH in $MONTHS
do
    if [ ! -d $MONTH/ ]; then
        mkdir "$MONTH"/
    fi
    for PREFIX in $PREFIXES
    do
        mv --verbose "$PREFIX$MONTH"* "$MONTH"/
    done
    mv --verbose "$YEAR$MONTH"* "$MONTH"/
done

