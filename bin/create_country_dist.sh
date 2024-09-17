#!/bin/bash

# Check if directory is provided
if [ -z "$1" ]; then
  echo "Usage: $0 <directory>"
  exit 1
fi

# Assign the directory to a variable
input_dir="$1"

# Initialize temporary file for data rows
temp_file=$(mktemp)

# Process each sub-directory
for dir in "$input_dir"/*/; do
  if [ -f "$dir/failed_login_data.txt" ]; then
    awk '{print $5}' "$dir/failed_login_data.txt" >> "$temp_file"
  fi
done

# Check if temp_file has content
if [ ! -s "$temp_file" ]; then
  echo "No IP addresses found in failed_login_data.txt files." >> debug_output.txt
  rm "$temp_file"
  exit 1
fi

# Sort IP addresses
sorted_temp_file=$(mktemp)
sort "$temp_file" > "$sorted_temp_file"

# Join with country_IP_map.txt to get country codes
joined_temp_file=$(mktemp)
join -1 1 -2 1 "$sorted_temp_file" <(sort etc/country_IP_map.txt) > "$joined_temp_file"

# Extract country codes and count occurrences
country_temp_file=$(mktemp)
awk '{print $2}' "$joined_temp_file" | sort | uniq -c > "$country_temp_file"

# Generate data.addRow lines for Geo Chart
awk '{print "data.addRow([\x27" $2 "\x27, " $1 "]);"}' "$country_temp_file" > "$temp_file"

# Check if temp_file has content after processing
if [ ! -s "$temp_file" ]; then
  echo "No data rows generated." >> debug_output.txt
  rm "$temp_file" "$sorted_temp_file" "$joined_temp_file" "$country_temp_file"
  exit 1
fi

# Wrap the data with header and footer
./bin/wrap_contents.sh "$temp_file" "country_dist" "$input_dir/country_dist.html"

# Check if country_dist.html was created
if [ ! -f "$input_dir/country_dist.html" ]; then
  echo "Failed to create country_dist.html." >> debug_output.txt
  rm "$temp_file" "$sorted_temp_file" "$joined_temp_file" "$country_temp_file"
  exit 1
fi

# Clean up temporary files
rm "$temp_file" "$sorted_temp_file" "$joined_temp_file" "$country_temp_file"