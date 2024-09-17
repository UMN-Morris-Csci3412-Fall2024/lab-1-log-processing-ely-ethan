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
    awk '{print $3}' "$dir/failed_login_data.txt" >> "$temp_file"
  fi
done

# Check if temp_file has content
if [ ! -s "$temp_file" ]; then
  echo "No hours found in failed_login_data.txt files." >> debug_output.txt
  rm "$temp_file"
  exit 1
fi

# Sort and count occurrences of each hour
sorted_temp_file=$(mktemp)
sort "$temp_file" > "$sorted_temp_file"

uniq_temp_file=$(mktemp)
uniq -c "$sorted_temp_file" > "$uniq_temp_file"

awk '{print "data.addRow([\x27" $2 "\x27, " $1 "]);"}' "$uniq_temp_file" > "$temp_file"

# Check if temp_file has content after processing
if [ ! -s "$temp_file" ]; then
  echo "No data rows generated." >> debug_output.txt
  rm "$temp_file" "$sorted_temp_file" "$uniq_temp_file"
  exit 1
fi

# Wrap the data with header and footer
./bin/wrap_contents.sh "$temp_file" "hours_dist" "$input_dir/hours_dist.html"

# Check if hours_dist.html was created
if [ ! -f "$input_dir/hours_dist.html" ]; then
  echo "Failed to create hours_dist.html." >> debug_output.txt
  rm "$temp_file" "$sorted_temp_file" "$uniq_temp_file"
  exit 1
fi

# Clean up temporary files
rm "$temp_file" "$sorted_temp_file" "$uniq_temp_file"