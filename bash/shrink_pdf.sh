#!/bin/bash
###############
# Author : Matthew McCourry
# Contact: mbmcc@github.com
# Title : 
# Description : use GhostScript to shrink a PDF 
# 
# Created : 
# Last modified : 
###############

input_file="$1"
#echo "$1, $input_file"

if [[ $input_file -eq false ]]; then
    echo -e "Provide a file name to convert, and this script will \n produce an output.pdf"
else
    gs -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -dPDFSETTINGS=/ebook \
    -dNOPAUSE -dBATCH -dColorImageResolution=150 \
    -sOutputFile=output.pdf "$input_file"
fi
