#!/bin/bash

# Check if at least one argument is provided
if [ "$#" -lt 1 ]; then
  echo "Usage: $0 <log_archive1.tgz> <log_archive2.tgz> ..."
  exit 1
fi

# Create a temporary scratch directory
scratch_dir=$(mktemp -d)

# Loop over the compressed tar files provided on the command line
for archive in "$@"; do
  # Extract the client name from the archive name
  client_name=$(basename "$archive" _secure.tgz)
  
  # Create a directory for the client in the scratch directory
  client_dir="$scratch_dir/$client_name"
  mkdir -p "$client_dir"
  
  # Extract the contents of the archive into the client's directory
  tar -xzf "$archive" -C "$client_dir"
  
  # Call process_client_logs.sh on the client's set of logs
  ./bin/process_client_logs.sh "$client_dir"
done

# Call create_username_dist.sh to generate the username distribution
./bin/create_username_dist.sh "$scratch_dir"

# Call create_hours_dist.sh to generate the hours distribution
./bin/create_hours_dist.sh "$scratch_dir"

# Call create_country_dist.sh to generate the country distribution
./bin/create_country_dist.sh "$scratch_dir"

# Call assemble_report.sh to generate the final report
./bin/assemble_report.sh "$scratch_dir"

# Move the resulting failed_login_summary.html file to the original directory
mv "$scratch_dir/failed_login_summary.html" .

# Clean up the temporary scratch directory
rm -rf "$scratch_dir"

echo "Report generated successfully: failed_login_summary.html"