#!/bin/bash

# Check if the correct number of arguments are provided
if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <input_file> <header_footer_name> <output_file>"
    exit 1
fi

# Assign input parameters to variables
input_file=$1
header_footer_name=$2
output_file=$3

# Define the header and footer file names
header_file="html_components/${header_footer_name}_header.html"
footer_file="html_components/${header_footer_name}_footer.html"

# Check if header and footer files exist
if [ ! -f "$header_file" ] || [ ! -f "$footer_file" ]; then
    echo "Header or footer file not found!"
    exit 1
fi

# Combine the header, input file, and footer into the output file
cat "$header_file" "$input_file" "$footer_file" > "$output_file"

echo "Content wrapped successfully into $output_file"