#!/bin/bash

# Author : Halim
# Title: Multi-tab Opener
# Opens a bunch of tabs in firefox private window...
# Use script by invoking ./open-tabs-ff.sh
# Script starts here:

# List of websites to open
URLS=""https://wiki.mozilla.org/Firefox/CommandLineOptions" "https://github.com/wheresmyweekend/""

# Invoke ff command
for URL in ${URLS}; do
    firefox -private-window ${URL}
    sleep 0.1
done