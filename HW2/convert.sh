#!/bin/bash

# Convert JSON to CSV

# Set input and output files
input_file='file1'
output_file='output'


echo 'test'
# Set field separator
IFS=','

# Set record separator
RS='\n'

# Read the first line to get the field names
read -r header

# Split fields and store in an array
fields=($header)

# Read the rest of the lines
while read -r line; do
  # Split fields
  values=($line)
  
  # Output values with field names as headers
  for i in "${!fields[@]}"; do
    printf '%s,%s\n' "${fields[i]}" "${values[i]}"
  done
done < "$input_file" > "$output_file"

echo 'Done!'