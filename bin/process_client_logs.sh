#!/bin/bash

# Check if directory is provided
if [ -z "$1" ]; then
  echo "Usage: $0 <directory>"
  exit 1
fi

# Move to the specified directory
cd "$1" || exit

# Process log files and generate failed_login_data.txt
find . -type f -exec cat {} + | awk '
  /Failed password for invalid user/ {
    split($0, a, " ")
    print a[1], a[2], substr(a[3], 1, 2), a[11], a[13]
  }
  /Failed password for/ && !/invalid user/ {
    split($0, a, " ")
    print a[1], a[2], substr(a[3], 1, 2), a[9], a[11]
  }
' > failed_login_data.txt