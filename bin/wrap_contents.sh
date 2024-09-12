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
header_file_name="${header_footer_name}_header.html"
footer_file_name="${header_footer_name}_footer.html"

# Find the header and footer files
header_file=$(find . -name "$header_file_name" 2>/dev/null | head -n 1)
footer_file=$(find . -name "$footer_file_name" 2>/dev/null | head -n 1)
input_file=$(find . -name "$input_file" 2>/dev/null | head -n 1)

# Check if header and footer files exist
if [ -z "$header_file" ] || [ -z "$footer_file" ]; then
    echo "Header or footer file not found!"
    exit 1
fi

# Combine the header, input file, and footer into the output file
cat "$header_file" "$input_file" "$footer_file" > "$output_file"

echo "Content wrapped successfully into $output_file"