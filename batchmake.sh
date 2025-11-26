#!/bin/bash

# Check if filename was provided
if [ $# -eq 0 ]; then
  echo "Usage: $0 <filename>"
  exit 1
fi

INPUT="$1"

if [ ! -r "$INPUT" ]; then
  echo "Error: File '$INPUT' is not readable."
  exit 1
fi

sanitize_filename() {
  local input="$1"
  local cleaned_name

  # Replace spaces and other common separators with hyphens
  cleaned_name=$(echo "$input" | tr ' ' '-' | tr '_."' '-')

  # Remove any characters that are not alphanumeric or hyphens
  cleaned_name=$(echo "$cleaned_name" | sed 's/[^a-zA-Z0-9-]//g')

  # Convert to lowercase (optional, but good for consistency)
  cleaned_name=$(echo "$cleaned_name" | tr '[:upper:]' '[:lower:]')

  # Remove duplicate hyphens
  #cleaned_name=$(echo "$cleaned_name" | sed 's/-\{2,\}/-/g')

  # Remove leading/trailing hyphens
  cleaned_name=$(echo "$cleaned_name" | sed 's/^-//;s/-$//')

  echo "$cleaned_name"
}

while IFS= read -r item ; do
  file=part_$(sanitize_filename "$item").stl
  echo "Processing badge: $item to $file"
  # Build the OpenSCAD command
  # -D defines a variable in the script
  # -o specifies the output file name
  /Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD \
      --enable textmetrics --enable lazy-union \
      -D font="\"sd prostreet\"" -D MakerWorld_Customizer_Environment=false \
      -D magnet_depth=2 -D plate_labels_1="\"$item\"" \
      -o $file MagneticLabelMaker.scad || { echo "failed"; exit 1; }
done < $INPUT
